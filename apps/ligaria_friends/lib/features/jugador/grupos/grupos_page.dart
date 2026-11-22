import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ligaria_ui/ligaria_ui.dart';
import '../amistosos/amistosos_repositorio.dart';
import '../amistosos/amistosos_seccion.dart';
import '../ligas/ligas_repositorio.dart';
import '../ligas/nuevo_partido.dart';
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
  late Future<List<Grupo>> _grupos = widget.repo.misGrupos();
  int _version = 0; // fuerza a recargar los amistosos sin grupo

  void _recargar() {
    final nuevos = widget.repo.misGrupos();
    setState(() {
      _grupos = nuevos;
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
            TextField(
              controller: nombre,
              autofocus: true,
              decoration: InputDecoration(labelText: c.l10n.nombre),
            ),
            const SizedBox(height: 12),
            TextField(
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
        content: TextField(
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
  Widget build(BuildContext context) => FutureBuilder<List<Grupo>>(
    future: _grupos,
    builder: (context, snap) {
      if (snap.connectionState != ConnectionState.done) {
        return const Center(child: CircularProgressIndicator());
      }
      if (snap.hasError) {
        return EstadoVacio(icono: Icons.error_outline, texto: '${snap.error}');
      }
      final grupos = snap.data!;
      return ListView(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 40),
        children: [
          if (grupos.isEmpty)
            _Bienvenida(onCrear: _crear, onUnirse: _unirse)
          else ...[
            _Cabecera(
              total: grupos.length,
              onCrear: _crear,
              onUnirse: _unirse,
              onPartido: () => _partido(grupos),
            ),
            const SizedBox(height: 24),
            _Rejilla(grupos: grupos, onAbrir: _abrir),
            AmistososSeccion(
              key: ValueKey('sin-grupo-$_version'),
              repo: widget.amistosos,
            ),
          ],
        ],
      );
    },
  );
}

/// Título de la sección y acciones principales (cuando ya hay grupos).
class _Cabecera extends StatelessWidget {
  const _Cabecera({
    required this.total,
    required this.onCrear,
    required this.onUnirse,
    required this.onPartido,
  });
  final int total;
  final VoidCallback onCrear, onUnirse, onPartido;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final titulo = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.tusGrupos,
          style: t.headlineMedium?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: -.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          total == 1
              ? context.l10n.unGrupoAmigos
              : context.l10n.nGruposAmigos(total),
          style: t.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
        ),
      ],
    );
    final acciones = Wrap(
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
    );
    return Aparece(
      child: LayoutBuilder(
        builder: (context, c) => c.maxWidth >= 980
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(child: titulo),
                  acciones,
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [titulo, const SizedBox(height: 16), acciones],
              ),
      ),
    );
  }
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
