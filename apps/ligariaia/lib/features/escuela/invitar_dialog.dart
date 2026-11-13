import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/auth.dart';
import '../../core/formulario.dart';
import '../../core/widgets.dart';
import '../../data/liga_repository.dart';
import '../../data/models.dart';
import 'escuela_providers.dart';

/// Diálogo para invitar a un usuario por email con un rol.
/// Con [rolFijo] y [jugadorFijo] (desde la ficha de una persona) solo pide el correo.
Future<void> mostrarInvitar(BuildContext context, WidgetRef ref, String escuelaId,
    {Rol? rolFijo, JugadorLite? jugadorFijo}) async {
  final ok = await mostrarFormulario<bool>(
    context,
    (_) => _InvitarDialog(escuelaId: escuelaId, rolFijo: rolFijo, jugadorFijo: jugadorFijo),
  );
  if (ok == true) {
    ref.invalidate(usuariosEscuelaProvider(escuelaId));
    if (context.mounted) avisar(context, 'Invitación enviada.');
  }
}

class _InvitarDialog extends ConsumerStatefulWidget {
  const _InvitarDialog({required this.escuelaId, this.rolFijo, this.jugadorFijo});
  final String escuelaId;
  final Rol? rolFijo;
  final JugadorLite? jugadorFijo;
  @override
  ConsumerState<_InvitarDialog> createState() => _InvitarDialogState();
}

class _InvitarDialogState extends ConsumerState<_InvitarDialog> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  late Rol _rol = widget.rolFijo ?? Rol.entrenador;
  String? _jugadorId;
  bool _enviando = false;

  bool get _requierePersona => _rol == Rol.alumno || _rol == Rol.tutor;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    if (!_form.currentState!.validate()) return;
    final jugadorId = widget.jugadorFijo?.id ?? (_requierePersona ? _jugadorId : null);
    setState(() => _enviando = true);
    try {
      await ref.read(ligaRepositoryProvider).invitar(widget.escuelaId, _email.text.trim(), _rol, jugadorId: jugadorId);
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        setState(() => _enviando = false);
        avisar(context, mensajeErrorEscuela(e));
      }
    }
  }

  static const _roles = <Rol, (IconData, String)>{
    Rol.adminEscuela: (Icons.admin_panel_settings_outlined, 'Gestiona la escuela'),
    Rol.entrenador: (Icons.sports, 'Dirige equipos'),
    Rol.alumno: (Icons.sports_soccer, 'Juega y ve su liga'),
    Rol.tutor: (Icons.family_restroom, 'Padre, madre o tutor'),
    Rol.organizadorLiga: (Icons.emoji_events_outlined, 'Organiza ligas'),
  };

  @override
  Widget build(BuildContext context) {
    final personas = ref.watch(jugadoresOrgProvider(widget.escuelaId)).value ?? const <JugadorLite>[];
    final fija = widget.jugadorFijo;
    return HojaFormulario(
      formKey: _form,
      icono: Icons.mark_email_unread_outlined,
      titulo: 'Invitar usuario',
      subtitulo: fija == null
          ? 'Enviaremos un correo con el enlace de acceso.'
          : 'Para ${fija.nombreCompleto} · como ${etiquetaRol(_rol).toLowerCase()}',
      etiquetaAccion: 'Enviar invitación',
      iconoAccion: Icons.send_rounded,
      enviando: _enviando,
      onAccion: _enviar,
      children: [
        TextFormField(
          key: const Key('invitar-email'),
          controller: _email,
          autofocus: true,
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.email],
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _enviar(),
          decoration: decoracionCampo('Correo electrónico', Icons.alternate_email, ayuda: 'nombre@ejemplo.com'),
          validator: (v) => (v == null || !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim()))
              ? 'Introduce un correo válido'
              : null,
        ),
        if (widget.rolFijo == null) ...[
          espacioCampo,
          SelectorTarjetas<Rol>(
            etiqueta: 'Rol',
            valor: _rol,
            onCambio: (r) => setState(() => _rol = r),
            opciones: [
              for (final e in _roles.entries)
                OpcionTarjeta(e.key, etiquetaRol(e.key), e.value.$1,
                    descripcion: e.value.$2, clave: Key('invitar-rol-${e.key.name}')),
            ],
          ),
        ],
        if (_requierePersona && fija == null) ...[
          espacioCampo,
          DropdownButtonFormField<String>(
            key: const Key('invitar-persona'),
            initialValue: _jugadorId,
            isExpanded: true,
            decoration: decoracionCampo(_rol == Rol.tutor ? 'Tutor de…' : 'Ficha del alumno', Icons.person_search_outlined),
            items: [for (final p in personas) DropdownMenuItem(value: p.id, child: Text(p.nombreCompleto))],
            validator: (v) => v == null ? 'Elige una persona' : null,
            onChanged: (v) => setState(() => _jugadorId = v),
          ),
        ],
      ],
    );
  }
}
