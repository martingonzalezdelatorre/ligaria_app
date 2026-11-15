import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ligaria_ui/ligaria_ui.dart';
import '../amistosos/amistosos_repositorio.dart';
import '../ligas/ligas_repositorio.dart';
import '../ligas/nuevo_partido.dart';
import 'grupo_page.dart';
import 'grupos_repositorio.dart';

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

  void _recargar() {
    final nuevos = widget.repo.misGrupos();
    setState(() {
      _grupos = nuevos;
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
    avisar(context, 'Partido creado');
    await _abrir(creado); // se abre el grupo para verlo y poner el tanteador
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
        title: const Text('Nuevo grupo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nombre,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: desc,
              decoration: const InputDecoration(
                labelText: 'Descripción (opcional)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Crear'),
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
        title: const Text('Unirse con código'),
        content: TextField(
          controller: codigo,
          autofocus: true,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(labelText: 'Código de invitación'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Unirme'),
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
      if (snap.connectionState != ConnectionState.done)
        return const Center(child: CircularProgressIndicator());
      if (snap.hasError)
        return EstadoVacio(icono: Icons.error_outline, texto: '${snap.error}');
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
          'Tus grupos',
          style: t.headlineMedium?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: -.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          total == 1 ? '1 grupo de amigos' : '$total grupos de amigos',
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
          label: const Text('Crear partido'),
        ),
        OutlinedButton.icon(
          onPressed: onCrear,
          icon: const Icon(Icons.add),
          label: const Text('Crear grupo'),
        ),
        OutlinedButton.icon(
          onPressed: onUnirse,
          icon: const Icon(Icons.vpn_key_outlined),
          label: const Text('Unirme con código'),
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
            'Tu liga entre amigos empieza aquí',
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
              'Aún no tienes grupos. Crea uno para empezar tu liga entre amigos.',
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
                label: const Text('Crear grupo'),
              ),
              OutlinedButton.icon(
                onPressed: onUnirse,
                icon: const Icon(Icons.vpn_key_outlined),
                label: const Text('Unirme con código'),
              ),
            ],
          ),
          const SizedBox(height: 40),
          const Wrap(
            alignment: WrapAlignment.center,
            spacing: 16,
            runSpacing: 16,
            children: [
              _Paso(
                n: 1,
                icono: Icons.group_add_outlined,
                titulo: 'Crea tu grupo',
                texto: 'Ponle nombre y tú serás el administrador.',
              ),
              _Paso(
                n: 2,
                icono: Icons.share_outlined,
                titulo: 'Invita a tus amigos',
                texto: 'Comparte el código de invitación del grupo.',
              ),
              _Paso(
                n: 3,
                icono: Icons.emoji_events_outlined,
                titulo: 'Jugad la liga',
                texto: 'Calendario, resultados y clasificación.',
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
                              '${grupo.miembros} ${grupo.miembros == 1 ? 'miembro' : 'miembros'}',
                              icono: Icons.people_alt_outlined,
                            ),
                            if (grupo.esAdmin)
                              Insignia(
                                'Admin',
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
        avisar(context, 'Código copiado');
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
              'Código',
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
