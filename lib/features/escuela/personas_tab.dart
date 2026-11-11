import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/auth.dart';
import '../../core/widgets.dart';
import '../../data/liga_repository.dart';
import '../../data/models.dart';
import 'escuela_providers.dart';
import 'invitar_dialog.dart';

class PersonasTab extends ConsumerWidget {
  const PersonasTab({super.key, required this.escuelaId});
  final String escuelaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final datos = ref.watch(personasEscuelaProvider(escuelaId));
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _nueva(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Nueva persona'),
      ),
      body: AsyncView<List<PersonaLite>>(
        value: datos,
        onRetry: () => ref.invalidate(personasEscuelaProvider(escuelaId)),
        builder: (lista) => lista.isEmpty
            ? const EstadoVacio(icono: Icons.child_care, texto: 'Todavía no hay jugadores. Añade el primero.')
            : RefreshIndicator(
                onRefresh: () async => ref.invalidate(personasEscuelaProvider(escuelaId)),
                child: ListView(padding: const EdgeInsets.only(bottom: 88), children: [
                  for (final p in lista) _fila(context, ref, p),
                ]),
              ),
      ),
    );
  }

  Widget _fila(BuildContext context, WidgetRef ref, PersonaLite p) {
    final edad = edadDe(p.fechaNacimiento);
    return ListTile(
      leading: const CircleAvatar(child: Icon(Icons.person_outline)),
      title: Text(p.nombreCompleto),
      subtitle: Text('$edad años · ${fechaLarga(p.fechaNacimiento)}${edad < 14 ? ' · Menor de 14' : ''}'),
      trailing: PopupMenuButton<String>(
        tooltip: 'Invitar',
        onSelected: (v) => mostrarInvitar(context, ref, escuelaId,
            rolFijo: v == 'tutor' ? Rol.tutor : Rol.alumno, personaFija: p),
        itemBuilder: (_) => const [
          PopupMenuItem(value: 'tutor', child: Text('Invitar a su tutor')),
          PopupMenuItem(value: 'alumno', child: Text('Invitar como alumno')),
        ],
      ),
    );
  }

  Future<void> _nueva(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(context: context, builder: (_) => _NuevaPersonaDialog(escuelaId: escuelaId));
    if (ok == true) {
      ref.invalidate(personasEscuelaProvider(escuelaId));
      if (context.mounted) avisar(context, 'Persona añadida.');
    }
  }
}

class _NuevaPersonaDialog extends ConsumerStatefulWidget {
  const _NuevaPersonaDialog({required this.escuelaId});
  final String escuelaId;
  @override
  ConsumerState<_NuevaPersonaDialog> createState() => _NuevaPersonaDialogState();
}

class _NuevaPersonaDialogState extends ConsumerState<_NuevaPersonaDialog> {
  final _form = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _apellidos = TextEditingController();
  final _fecha = TextEditingController();
  bool _enviando = false;

  @override
  void dispose() {
    _nombre.dispose();
    _apellidos.dispose();
    _fecha.dispose();
    super.dispose();
  }

  Future<void> _elegirFecha() async {
    final hoy = DateTime.now();
    final f = await showDatePicker(
      context: context,
      initialDate: DateTime(hoy.year - 10),
      firstDate: DateTime(1940),
      lastDate: hoy,
    );
    if (f != null) _fecha.text = '${f.day.toString().padLeft(2, '0')}/${f.month.toString().padLeft(2, '0')}/${f.year}';
  }

  Future<void> _guardar() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _enviando = true);
    try {
      await ref.read(ligaRepositoryProvider).crearPersona(
          widget.escuelaId, _nombre.text.trim(), _apellidos.text.trim(), parseFecha(_fecha.text)!);
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        setState(() => _enviando = false);
        avisar(context, mensajeErrorEscuela(e));
      }
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Nueva persona'),
        content: Form(
          key: _form,
          child: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextFormField(
                key: const Key('persona-nombre'),
                controller: _nombre,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Introduce el nombre' : null,
              ),
              TextFormField(
                key: const Key('persona-apellidos'),
                controller: _apellidos,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Apellidos'),
              ),
              TextFormField(
                key: const Key('persona-fecha'),
                controller: _fecha,
                keyboardType: TextInputType.datetime,
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9/]'))],
                decoration: InputDecoration(
                  labelText: 'Fecha de nacimiento (dd/mm/aaaa)',
                  suffixIcon: IconButton(icon: const Icon(Icons.calendar_month), onPressed: _elegirFecha),
                ),
                validator: (v) {
                  final f = parseFecha(v ?? '');
                  if (f == null) return 'Fecha no válida';
                  if (f.isAfter(DateTime.now())) return 'No puede ser futura';
                  return null;
                },
              ),
            ]),
          ),
        ),
        actions: [
          TextButton(onPressed: _enviando ? null : () => Navigator.of(context).pop(false), child: const Text('Cancelar')),
          FilledButton(onPressed: _enviando ? null : _guardar, child: const Text('Guardar')),
        ],
      );
}
