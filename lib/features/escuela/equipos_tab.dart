import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/auth.dart';
import '../../core/widgets.dart';
import '../../data/liga_repository.dart';
import '../../data/models.dart';
import 'escuela_providers.dart';

class EquiposTab extends ConsumerWidget {
  const EquiposTab({super.key, required this.escuelaId});
  final String escuelaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final datos = ref.watch(equiposEscuelaProvider(escuelaId));
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _crear(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo equipo'),
      ),
      body: AsyncView<List<EquipoLite>>(
        value: datos,
        onRetry: () => ref.invalidate(equiposEscuelaProvider(escuelaId)),
        builder: (lista) => lista.isEmpty
            ? const EstadoVacio(icono: Icons.groups_outlined, texto: 'Aún no hay equipos. Crea el primero.')
            : RefreshIndicator(
                onRefresh: () async => ref.invalidate(equiposEscuelaProvider(escuelaId)),
                child: ListView(padding: const EdgeInsets.only(bottom: 88), children: [
                  for (final e in lista)
                    ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.groups_outlined)),
                      title: Text(e.nombre),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => EquipoPage(escuelaId: escuelaId, equipo: e))),
                    ),
                ]),
              ),
      ),
    );
  }

  Future<void> _crear(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(context: context, builder: (_) => _NuevoEquipoDialog(escuelaId: escuelaId));
    if (ok == true) {
      ref.invalidate(equiposEscuelaProvider(escuelaId));
      if (context.mounted) avisar(context, 'Equipo creado.');
    }
  }
}

class _NuevoEquipoDialog extends ConsumerStatefulWidget {
  const _NuevoEquipoDialog({required this.escuelaId});
  final String escuelaId;
  @override
  ConsumerState<_NuevoEquipoDialog> createState() => _NuevoEquipoDialogState();
}

class _NuevoEquipoDialogState extends ConsumerState<_NuevoEquipoDialog> {
  final _form = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  String? _deporteId;
  bool _enviando = false;

  @override
  void dispose() {
    _nombre.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _enviando = true);
    try {
      await ref.read(ligaRepositoryProvider).crearEquipo(widget.escuelaId, _nombre.text.trim(), _deporteId!);
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        setState(() => _enviando = false);
        avisar(context, mensajeErrorEscuela(e));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final deportes = ref.watch(deportesProvider).value ?? const <Deporte>[];
    return AlertDialog(
      title: const Text('Nuevo equipo'),
      content: Form(
        key: _form,
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextFormField(
              key: const Key('equipo-nombre'),
              controller: _nombre,
              decoration: const InputDecoration(labelText: 'Nombre del equipo'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Introduce un nombre' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              key: const Key('equipo-deporte'),
              initialValue: _deporteId,
              decoration: const InputDecoration(labelText: 'Deporte'),
              items: [for (final d in deportes) DropdownMenuItem(value: d.id, child: Text(d.nombre))],
              validator: (v) => v == null ? 'Elige un deporte' : null,
              onChanged: (v) => setState(() => _deporteId = v),
            ),
          ]),
        ),
      ),
      actions: [
        TextButton(onPressed: _enviando ? null : () => Navigator.of(context).pop(false), child: const Text('Cancelar')),
        FilledButton(onPressed: _enviando ? null : _guardar, child: const Text('Crear')),
      ],
    );
  }
}

/// Detalle de un equipo: plantilla, añadir jugadores y asignar entrenador.
class EquipoPage extends ConsumerWidget {
  const EquipoPage({super.key, required this.escuelaId, required this.equipo});
  final String escuelaId;
  final EquipoLite equipo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jugadores = ref.watch(jugadoresEquipoEscuelaProvider(equipo.id));
    return Scaffold(
      appBar: AppBar(title: Text(equipo.nombre)),
      body: ListView(padding: const EdgeInsets.all(12), children: [
        Row(children: [
          Expanded(
            child: FilledButton.icon(
              key: const Key('anadir-jugador'),
              onPressed: () => _anadirJugador(context, ref),
              icon: const Icon(Icons.person_add_alt),
              label: const Text('Añadir jugador'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton.icon(
              key: const Key('asignar-entrenador'),
              onPressed: () => _asignarEntrenador(context, ref),
              icon: const Icon(Icons.sports),
              label: const Text('Entrenador'),
            ),
          ),
        ]),
        const SizedBox(height: 16),
        Text('Plantilla', style: Theme.of(context).textTheme.titleSmall),
        jugadores.when(
          loading: () => const Padding(padding: EdgeInsets.all(16), child: LinearProgressIndicator()),
          error: (_, _) => const Padding(padding: EdgeInsets.all(8), child: Text('No se pudo cargar la plantilla.')),
          data: (js) => js.isEmpty
              ? const Padding(padding: EdgeInsets.all(8), child: Text('Sin jugadores todavía.'))
              : Column(children: [
                  for (final j in js)
                    ListTile(leading: const Icon(Icons.person_outline), title: Text(j.nombreCompleto), dense: true),
                ]),
        ),
      ]),
    );
  }

  Future<String?> _elegir<T>(BuildContext context, String titulo, List<(String, String)> opciones, String vacio) {
    return showDialog<String>(
      context: context,
      builder: (_) => SimpleDialog(
        title: Text(titulo),
        children: opciones.isEmpty
            ? [Padding(padding: const EdgeInsets.all(24), child: Text(vacio))]
            : [for (final o in opciones) SimpleDialogOption(onPressed: () => Navigator.of(context).pop(o.$1), child: Text(o.$2))],
      ),
    );
  }

  Future<void> _anadirJugador(BuildContext context, WidgetRef ref) async {
    final repo = ref.read(ligaRepositoryProvider);
    try {
      final personas = await ref.read(personasEscuelaProvider(escuelaId).future);
      final actuales = (await ref.read(jugadoresEquipoEscuelaProvider(equipo.id).future)).map((j) => j.personaId).toSet();
      final libres = personas.where((p) => !actuales.contains(p.id)).toList();
      if (!context.mounted) return;
      final id = await _elegir(context, 'Añadir jugador', [for (final p in libres) (p.id, p.nombreCompleto)],
          'No quedan personas por añadir.');
      if (id == null) return;
      await repo.anadirJugador(equipo.id, escuelaId, id);
      ref.invalidate(jugadoresEquipoEscuelaProvider(equipo.id));
      if (context.mounted) avisar(context, 'Jugador añadido.');
    } catch (e) {
      if (context.mounted) avisar(context, mensajeErrorEscuela(e));
    }
  }

  Future<void> _asignarEntrenador(BuildContext context, WidgetRef ref) async {
    final repo = ref.read(ligaRepositoryProvider);
    try {
      final usuarios = await ref.read(usuariosEscuelaProvider(escuelaId).future);
      final entrenadores = usuarios.where((u) => u.rol == rolADb(Rol.entrenador)).toList();
      if (!context.mounted) return;
      final id = await _elegir(
          context, 'Asignar entrenador',
          [for (final u in entrenadores) (u.usuarioId, u.nombre?.isNotEmpty == true ? u.nombre! : u.email)],
          'No hay usuarios con rol entrenador. Invítalos desde «Usuarios».');
      if (id == null) return;
      await repo.asignarEntrenador(equipo.id, escuelaId, id);
      if (context.mounted) avisar(context, 'Entrenador asignado.');
    } catch (e) {
      if (context.mounted) avisar(context, mensajeErrorEscuela(e));
    }
  }
}
