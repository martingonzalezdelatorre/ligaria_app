import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/auth.dart';
import '../../core/widgets.dart';
import '../../data/liga_repository.dart';
import '../../data/models.dart';
import 'escuela_providers.dart';

/// Diálogo para invitar a un usuario por email con un rol.
/// Con [rolFijo] y [personaFija] (desde la ficha de una persona) solo pide el correo.
Future<void> mostrarInvitar(BuildContext context, WidgetRef ref, String escuelaId,
    {Rol? rolFijo, PersonaLite? personaFija}) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (_) => _InvitarDialog(escuelaId: escuelaId, rolFijo: rolFijo, personaFija: personaFija),
  );
  if (ok == true) {
    ref.invalidate(usuariosEscuelaProvider(escuelaId));
    if (context.mounted) avisar(context, 'Invitación enviada.');
  }
}

class _InvitarDialog extends ConsumerStatefulWidget {
  const _InvitarDialog({required this.escuelaId, this.rolFijo, this.personaFija});
  final String escuelaId;
  final Rol? rolFijo;
  final PersonaLite? personaFija;
  @override
  ConsumerState<_InvitarDialog> createState() => _InvitarDialogState();
}

class _InvitarDialogState extends ConsumerState<_InvitarDialog> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  late Rol _rol = widget.rolFijo ?? Rol.entrenador;
  String? _personaId;
  bool _enviando = false;

  bool get _requierePersona => _rol == Rol.alumno || _rol == Rol.tutor;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    if (!_form.currentState!.validate()) return;
    final personaId = widget.personaFija?.id ?? (_requierePersona ? _personaId : null);
    setState(() => _enviando = true);
    try {
      await ref.read(ligaRepositoryProvider).invitar(widget.escuelaId, _email.text.trim(), _rol, personaId: personaId);
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
    final personas = ref.watch(personasEscuelaProvider(widget.escuelaId)).value ?? const <PersonaLite>[];
    return AlertDialog(
      title: Text(widget.personaFija == null ? 'Invitar usuario' : 'Invitar (${widget.personaFija!.nombreCompleto})'),
      content: Form(
        key: _form,
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextFormField(
              key: const Key('invitar-email'),
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Correo electrónico'),
              validator: (v) => (v == null || !v.contains('@')) ? 'Introduce un correo válido' : null,
            ),
            if (widget.rolFijo == null) ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<Rol>(
                key: const Key('invitar-rol'),
                initialValue: _rol,
                decoration: const InputDecoration(labelText: 'Rol'),
                items: [
                  for (final r in Rol.values.where((r) => r != Rol.superadmin))
                    DropdownMenuItem(value: r, child: Text(etiquetaRol(r))),
                ],
                onChanged: (r) => setState(() => _rol = r ?? _rol),
              ),
            ],
            if (_requierePersona && widget.personaFija == null) ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                key: const Key('invitar-persona'),
                initialValue: _personaId,
                isExpanded: true,
                decoration: InputDecoration(labelText: _rol == Rol.tutor ? 'Tutor de…' : 'Ficha del alumno'),
                items: [for (final p in personas) DropdownMenuItem(value: p.id, child: Text(p.nombreCompleto))],
                validator: (v) => v == null ? 'Elige una persona' : null,
                onChanged: (v) => setState(() => _personaId = v),
              ),
            ],
          ]),
        ),
      ),
      actions: [
        TextButton(onPressed: _enviando ? null : () => Navigator.of(context).pop(false), child: const Text('Cancelar')),
        FilledButton(onPressed: _enviando ? null : _enviar, child: const Text('Invitar')),
      ],
    );
  }
}
