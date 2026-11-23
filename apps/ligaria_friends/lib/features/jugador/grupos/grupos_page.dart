import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ligaria_ui/ligaria_ui.dart';
import '../amistosos/amistosos_repositorio.dart';
import '../amistosos/amistosos_seccion.dart';
import '../ligas/ligas_repositorio.dart';
import '../ligas/nuevo_partido.dart';
import '../social/acciones_jugador.dart';
import '../social/jugadores_tab.dart';
import 'grupo_page.dart';
import 'grupos_repositorio.dart';
import '../../../core/idioma.dart';

/// Inicio: tus grupos de amigos, con acciones para crear uno o unirse con un código.
class GruposPage extends StatefulWidget {
  const GruposPage({
    super.key,
    required this.repo,
    required this.ligas,
    required this.amistosos,
  });
  final GruposRepositorio repo;
  final LigasRepositorio ligas;
  final AmistososRepositorio amistosos;
  @override
  State<GruposPage> createState() => _GruposPageState();
}

class _GruposPageState extends State<GruposPage> {
  late Future<_Inicio> _datos = _cargar();
  int _version = 0; // fuerza a recargar los amistosos sin grupo
  int _tab = 0; // 0 grupos · 1 amistosos · 2 amigos · 3 jugadores
  String _filtro = '';

  late final _acciones = AccionesJugador(
    grupos: widget.repo,
    ligas: widget.ligas,
    amistosos: widget.amistosos,
    alCambiar: _recargar,
  );

  /// Grupos y amigos (invitados, contactados o compañeros de grupo), estén o no en un grupo.
  Future<_Inicio> _cargar() async {
    final grupos = await widget.repo.misGrupos();
    var amigos = <Miembro>[];
    try {
      amigos = (await widget.repo.jugadoresPosibles())
          .where((m) => !m.esYo)
          .toList();
    } catch (_) {} // los amigos son un extra: si falla, se siguen viendo los grupos
    return _Inicio(grupos, amigos);
  }

  void _recargar() {
    final nuevos = _cargar();
    setState(() {
      _datos = nuevos;
      _version++;
    });
  }

  Future<void> _partido(List<Grupo> grupos) async {
    final creado = await mostrarNuevoPartido(
      context,
      grupos: grupos,
      gruposRepo: widget.repo,
      ligas: widget.ligas,
      amistosos: widget.amistosos,
    );
    if (creado == null || !mounted) return;
    avisar(context, context.l10n.partidoCreado);
    final g = creado.grupo;
    if (g == null) {
      _recargar(); // sin grupo: aparece en «Amistosos con amigos»
    } else {
      await _abrir(g); // se abre el grupo para verlo y poner el tanteador
    }
  }

  Future<void> _abrir(Grupo g) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => GrupoPage(
          grupo: g,
          repo: widget.repo,
          ligas: widget.ligas,
          amistosos: widget.amistosos,
        ),
      ),
    );
    if (mounted) _recargar();
  }

  Future<void> _crear() async {
    final nombre = TextEditingController();
    final desc = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(context.l10n.nuevoGrupo),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CampoTexto(
              controller: nombre,
              autofocus: true,
              decoration: InputDecoration(labelText: c.l10n.nombre),
            ),
            const SizedBox(height: 12),
            CampoTexto(
              controller: desc,
              decoration: InputDecoration(labelText: c.l10n.descripcionOpc),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: Text(c.l10n.cancelar),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: Text(c.l10n.crear),
          ),
        ],
      ),
    );
    if (ok != true || nombre.text.trim().isEmpty) return;
    await _ejecutar(
      () => widget.repo.crear(nombre: nombre.text, descripcion: desc.text),
    );
  }

  Future<void> _unirse() async {
    final codigo = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(context.l10n.unirseConCodigo),
        content: CampoTexto(
          controller: codigo,
          autofocus: true,
          textCapitalization: TextCapitalization.characters,
          decoration: InputDecoration(labelText: c.l10n.codigoInvitacion),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: Text(c.l10n.cancelar),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: Text(c.l10n.unirme),
          ),
        ],
      ),
    );
    if (ok != true || codigo.text.trim().isEmpty) return;
    await _ejecutar(() => widget.repo.unirse(codigo.text));
  }

  Future<void> _ejecutar(Future<void> Function() accion) async {
    try {
      await accion();
      if (mounted) _recargar();
    } on GruposException catch (e) {
      if (mounted) avisar(context, e.mensaje);
    }
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<_Inicio>(
    future: _datos,
    builder: (context, snap) {
      if (snap.connectionState != ConnectionState.done) {
        return const Center(child: Cargando());
      }
      if (snap.hasError) {
        return EstadoVacio(icono: Icons.error_outline, texto: '${snap.error}');
      }
      final grupos = snap.data!.grupos;
      final amigos = snap.data!.amigos;
      final l = context.l10n;
      final filtro = _filtro.trim().toLowerCase();
      final visibles = filtro.isEmpty
          ? grupos
          : grupos.where((g) => g.nombre.toLowerCase().contains(filtro)).toList();
      final Widget contenido = switch (_tab) {
        0 => Column(
          key: const ValueKey('tab-grupos'),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (grupos.length > 4) ...[
              CampoTexto(
                onChanged: (v) => setState(() => _filtro = v),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: '${l.grupos}…',
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (grupos.isEmpty)
              _Bienvenida(onCrear: _crear, onUnirse: _unirse)
            else
              _Rejilla(grupos: visibles, onAbrir: _abrir),
          ],
        ),
        1 => AmistososSeccion(
          key: ValueKey('sin-grupo-$_version'),
          repo: widget.amistosos,
          conTitulo: false,
          vacio: _Vacio(
            icono: Icons.sports_tennis,
            texto: l.sinAmistososHome,
          ),
        ),
        2 => _SeccionAmigos(
          key: const ValueKey('tab-amigos'),
          amigos: amigos,
          acciones: _acciones,
        ),
        _ => JugadoresTab(
          key: const ValueKey('tab-jugadores'),
          acciones: _acciones,
        ),
      };
      return CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
            sliver: SliverToBoxAdapter(
              child: _Cabecera(
                onCrear: _crear,
                onUnirse: _unirse,
                onPartido: () => _partido(grupos),
              ),
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _PestanasDelegate(
              seleccion: _tab,
              onCambio: (i) => setState(() => _tab = i),
              pestanas: [
                _Pestana(Icons.groups_outlined, Icons.groups, l.grupos, grupos.length),
                _Pestana(
                  Icons.sports_tennis_outlined,
                  Icons.sports_tennis,
                  l.amistosos,
                  null,
                ),
                _Pestana(
                  Icons.people_alt_outlined,
                  Icons.people_alt,
                  l.amigosTab,
                  amigos.length,
                ),
                _Pestana(
                  Icons.person_search_outlined,
                  Icons.person_search,
                  l.tabJugadores,
                  null,
                ),
              ],
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
            sliver: SliverToBoxAdapter(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: KeyedSubtree(key: ValueKey(_tab), child: contenido),
              ),
            ),
          ),
        ],
      );
    },
  );
}

class _Pestana {
  const _Pestana(this.icono, this.activo, this.texto, this.cuenta);
  final IconData icono, activo;
  final String texto;
  final int? cuenta;
}

/// Selector de pestañas fijo bajo la cabecera: no se pierde al hacer scroll.
class _PestanasDelegate extends SliverPersistentHeaderDelegate {
  _PestanasDelegate({
    required this.seleccion,
    required this.onCambio,
    required this.pestanas,
  });
  final int seleccion;
  final ValueChanged<int> onCambio;
  final List<_Pestana> pestanas;

  @override
  double get minExtent => 90;
  @override
  double get maxExtent => 90;

  @override
  bool shouldRebuild(_PestanasDelegate old) =>
      old.seleccion != seleccion || old.pestanas != pestanas;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlaps) {
    final cs = Theme.of(context).colorScheme;
    final marca = Marca.de(context);
    final t = Theme.of(context).textTheme;
    return Container(
      color: overlaps
          ? Theme.of(context).scaffoldBackgroundColor.withValues(alpha: .94)
          : Colors.transparent,
      padding: const EdgeInsets.fromLTRB(24, 6, 24, 10),
      alignment: Alignment.center,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: marca.superficie,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: marca.borde),
        ),
        child: Row(
          children: [
            for (var i = 0; i < pestanas.length; i++)
              Expanded(
                child: Semantics(
                  button: true,
                  selected: i == seleccion,
                  label: pestanas[i].texto,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onCambio(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 2,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: i == seleccion ? cs.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Badge(
                            isLabelVisible: pestanas[i].cuenta != null,
                            label: Text('${pestanas[i].cuenta}'),
                            child: Icon(
                              i == seleccion
                                  ? pestanas[i].activo
                                  : pestanas[i].icono,
                              size: 22,
                              color: i == seleccion
                                  ? cs.onPrimary
                                  : cs.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 3),
                          // El nombre se ve siempre completo: se reduce si no cabe.
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              pestanas[i].texto,
                              maxLines: 1,
                              softWrap: false,
                              style: t.labelMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: i == seleccion
                                    ? cs.onPrimary
                                    : cs.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Vacio extends StatelessWidget {
  const _Vacio({required this.icono, required this.texto});
  final IconData icono;
  final String texto;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 32),
    child: Column(
      children: [
        MedallonVacio(icono: icono),
        const SizedBox(height: 16),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Text(
            texto,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    ),
  );
}

class _Inicio {
  const _Inicio(this.grupos, this.amigos);
  final List<Grupo> grupos;
  final List<Miembro> amigos;
}

/// Todas las personas de tu círculo (invitadas, contactadas o de tus grupos), con o sin grupo.
class _SeccionAmigos extends StatelessWidget {
  const _SeccionAmigos({
    super.key,
    required this.amigos,
    required this.acciones,
  });
  final List<Miembro> amigos;
  final AccionesJugador acciones;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final marca = Marca.de(context);
    return Aparece(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            amigos.isEmpty
                ? context.l10n.sinAmigosHome
                : context.l10n.amigosSub,
            style: t.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 14),
          for (final a in amigos)
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.fromLTRB(14, 8, 6, 8),
              decoration: BoxDecoration(
                color: marca.superficie,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: marca.borde),
              ),
              child: Row(
                children: [
                  AvatarEquipo(a.nombre, tam: 40),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      a.nombre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: t.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  BotonesJugador(
                    acciones: acciones,
                    id: a.id,
                    nombre: a.nombre,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Acciones principales de la pantalla de inicio.
class _Cabecera extends StatelessWidget {
  const _Cabecera({
    required this.onCrear,
    required this.onUnirse,
    required this.onPartido,
  });
  final VoidCallback onCrear, onUnirse, onPartido;

  @override
  Widget build(BuildContext context) => Aparece(
    child: Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        FilledButton.icon(
          onPressed: onPartido,
          icon: const Icon(Icons.sports_tennis),
          label: Text(context.l10n.crearPartido),
        ),
        OutlinedButton.icon(
          onPressed: onCrear,
          icon: const Icon(Icons.add),
          label: Text(context.l10n.crearGrupo),
        ),
        OutlinedButton.icon(
          onPressed: onUnirse,
          icon: const Icon(Icons.vpn_key_outlined),
          label: Text(context.l10n.unirmeConCodigo),
        ),
      ],
    ),
  );
}

/// Estado vacío con llamada a la acción y los pasos para empezar.
class _Bienvenida extends StatelessWidget {
  const _Bienvenida({required this.onCrear, required this.onUnirse});
  final VoidCallback onCrear, onUnirse;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Aparece(
      child: Column(
        children: [
          const SizedBox(height: 24),
          const MedallonVacio(icono: Icons.groups),
          const SizedBox(height: 24),
          Text(
            context.l10n.ligaEntreAmigosEmpieza,
            textAlign: TextAlign.center,
            style: t.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: -.5,
            ),
          ),
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Text(
              context.l10n.aunNoTienesGrupos,
              textAlign: TextAlign.center,
              style: t.bodyLarge?.copyWith(color: cs.onSurfaceVariant),
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: [
              FilledButton.icon(
                onPressed: onCrear,
                icon: const Icon(Icons.add),
                label: Text(context.l10n.crearGrupo),
              ),
              OutlinedButton.icon(
                onPressed: onUnirse,
                icon: const Icon(Icons.vpn_key_outlined),
                label: Text(context.l10n.unirmeConCodigo),
              ),
            ],
          ),
          const SizedBox(height: 40),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 16,
            runSpacing: 16,
            children: [
              _Paso(
                n: 1,
                icono: Icons.group_add_outlined,
                titulo: context.l10n.pasoCreaGrupo,
                texto: context.l10n.pasoCreaGrupoTxt,
              ),
              _Paso(
                n: 2,
                icono: Icons.share_outlined,
                titulo: context.l10n.pasoInvita,
                texto: context.l10n.pasoInvitaTxt,
              ),
              _Paso(
                n: 3,
                icono: Icons.emoji_events_outlined,
                titulo: context.l10n.pasoJugad,
                texto: context.l10n.pasoJugadTxt,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Paso extends StatelessWidget {
  const _Paso({
    required this.n,
    required this.icono,
    required this.titulo,
    required this.texto,
  });
  final int n;
  final IconData icono;
  final String titulo, texto;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final marca = Marca.de(context);
    return Container(
      width: 260,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: marca.superficie,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: marca.borde),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icono, color: cs.primary),
              const Spacer(),
              Text(
                '0$n',
                style: t.labelLarge?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            titulo,
            style: t.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            texto,
            style: t.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

/// Una columna en móvil y dos en pantallas anchas.
class _Rejilla extends StatelessWidget {
  const _Rejilla({required this.grupos, required this.onAbrir});
  final List<Grupo> grupos;
  final void Function(Grupo) onAbrir;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) {
      const sep = 16.0;
      final cols = c.maxWidth >= 760 ? 2 : 1;
      final ancho = (c.maxWidth - sep * (cols - 1)) / cols;
      return Wrap(
        spacing: sep,
        runSpacing: sep,
        children: [
          for (var i = 0; i < grupos.length; i++)
            SizedBox(
              width: ancho,
              child: Aparece(
                retardo: 60 * i,
                child: _TarjetaGrupo(
                  grupo: grupos[i],
                  onTap: () => onAbrir(grupos[i]),
                ),
              ),
            ),
        ],
      );
    },
  );
}

class _TarjetaGrupo extends StatelessWidget {
  const _TarjetaGrupo({required this.grupo, required this.onTap});
  final Grupo grupo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final marca = Marca.de(context);
    return Pulsable(
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: marca.superficie,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: marca.borde),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AvatarEquipo(grupo.nombre, tam: 48),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          grupo.nombre,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: t.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            Insignia(
                              grupo.miembros == 1
                                  ? context.l10n.miembro1
                                  : context.l10n.miembrosN(grupo.miembros),
                              icono: Icons.people_alt_outlined,
                            ),
                            if (grupo.esAdmin)
                              Insignia(
                                context.l10n.admin,
                                color: cs.primary,
                                icono: Icons.shield_outlined,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (grupo.descripcion != null) ...[
                const SizedBox(height: 12),
                Text(
                  grupo.descripcion!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: t.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
              const SizedBox(height: 14),
              _CodigoInvitacion(codigo: grupo.codigo),
            ],
          ),
        ),
      ),
    );
  }
}

/// Código de invitación con botón para copiarlo.
class _CodigoInvitacion extends StatelessWidget {
  const _CodigoInvitacion({required this.codigo});
  final String codigo;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        Clipboard.setData(ClipboardData(text: codigo));
        avisar(context, context.l10n.codigoCopiado);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Marca.de(context).borde),
        ),
        child: Row(
          children: [
            Icon(Icons.vpn_key_outlined, size: 16, color: cs.onSurfaceVariant),
            const SizedBox(width: 8),
            Text(
              context.l10n.codigo,
              style: t.labelMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                codigo,
                style: t.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            Icon(Icons.copy_rounded, size: 18, color: cs.primary),
          ],
        ),
      ),
    );
  }
}
