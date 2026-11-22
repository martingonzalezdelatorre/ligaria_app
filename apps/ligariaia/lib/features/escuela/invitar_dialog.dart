import '../../core/idioma.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ligaria_ui/ligaria_ui.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/auth.dart';
import '../../core/config.dart';
import '../../data/liga_repository.dart';
import '../../data/models.dart';
import 'escuela_providers.dart';

/// Diálogo para invitar a un usuario por email con un rol.
/// Con [rolFijo] y [jugadorFijo] (desde la ficha de una persona) solo pide el correo.
Future<void> mostrarInvitar(
  BuildContext context,
  WidgetRef ref,
  String escuelaId, {
  Rol? rolFijo,
  JugadorLite? jugadorFijo,
}) async {
  final ok = await mostrarFormulario<bool>(
    context,
    (_) => _InvitarDialog(
      escuelaId: escuelaId,
      rolFijo: rolFijo,
      jugadorFijo: jugadorFijo,
    ),
  );
  if (ok == true) {
    ref.invalidate(usuariosEscuelaProvider(escuelaId));
    if (context.mounted) avisar(context, context.l10n.invitacionEnviada);
  }
}

class _InvitarDialog extends ConsumerStatefulWidget {
  const _InvitarDialog({
    required this.escuelaId,
    this.rolFijo,
    this.jugadorFijo,
  });
  final String escuelaId;
  final Rol? rolFijo;
  final JugadorLite? jugadorFijo;
  @override
  ConsumerState<_InvitarDialog> createState() => _InvitarDialogState();
}

class _InvitarDialogState extends ConsumerState<_InvitarDialog> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _telefono = TextEditingController();
  late Rol _rol = widget.rolFijo ?? Rol.entrenador;
  String? _jugadorId;
  bool _enviando = false;

  bool get _soloWhatsapp =>
      _email.text.trim().isEmpty && _telefono.text.trim().isNotEmpty;
  bool get _requierePersona => _rol == Rol.alumno;
  bool get _eligePersona => _rol == Rol.alumno || _rol == Rol.tutor;

  @override
  void dispose() {
    _email.dispose();
    _telefono.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    if (!_form.currentState!.validate()) return;
    if (_email.text.trim().isEmpty) {
      // Solo WhatsApp: no hay correo al que ligar la invitación, solo se envía el mensaje.
      await _whatsapp();
      if (mounted) Navigator.of(context).pop(false);
      return;
    }
    final jugadorId =
        widget.jugadorFijo?.id ?? (_eligePersona ? _jugadorId : null);
    setState(() => _enviando = true);
    try {
      await ref
          .read(ligaRepositoryProvider)
          .invitar(
            widget.escuelaId,
            _email.text.trim(),
            _rol,
            jugadorId: jugadorId,
          );
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        setState(() => _enviando = false);
        avisar(context, mensajeErrorEscuela(e));
      }
    }
  }

  String get _mensaje {
    if (_email.text.trim().isEmpty) {
      return context.l10n.msgInvitSinCorreo(AppConfig.familiasUrl);
    }
    final correo = _email.text.trim();
    return context.l10n.msgInvitConCorreo(correo, AppConfig.familiasUrl);
  }

  /// Copia el mensaje con el enlace de registro para pegarlo donde se quiera.
  void _copiarEnlace() {
    Clipboard.setData(ClipboardData(text: _mensaje));
    avisar(context, context.l10n.mensajeCopiado);
  }

  /// Abre WhatsApp con el mensaje; con teléfono va directo a ese chat.
  Future<void> _whatsapp() async {
    final tel = _telefono.text.replaceAll(RegExp(r'[^0-9]'), '');
    final uri = Uri.https('wa.me', tel.isEmpty ? '' : '/$tel', {
      'text': _mensaje,
    });
    var ok = false;
    try {
      ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
    if (!ok && mounted) avisar(context, context.l10n.errWhatsapp);
  }

  Map<Rol, (IconData, String)> _roles(AppL10n l) => {
    Rol.adminEscuela: (Icons.admin_panel_settings_outlined, l.rolDescAdmin),
    Rol.entrenador: (Icons.sports, l.rolDescEntrenador),
    Rol.alumno: (Icons.sports_soccer, l.rolDescJugador),
    Rol.tutor: (Icons.family_restroom, l.padreMadreTutor),
    Rol.organizadorLiga: (Icons.emoji_events_outlined, l.rolDescOrganizador),
  };

  @override
  Widget build(BuildContext context) {
    final personas =
        ref.watch(jugadoresOrgProvider(widget.escuelaId)).value ??
        const <JugadorLite>[];
    final fija = widget.jugadorFijo;
    return HojaFormulario(
      formKey: _form,
      icono: Icons.mark_email_unread_outlined,
      titulo: context.l10n.invitarUsuario,
      subtitulo: fija == null
          ? context.l10n.invitacionGuardada
          : context.l10n.paraComo(
              fija.nombreCompleto,
              etiquetaRol(_rol).toLowerCase(),
            ),
      etiquetaAccion: _soloWhatsapp
          ? context.l10n.enviarWhatsapp
          : context.l10n.enviarInvitacion,
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
          decoration: decoracionCampo(
            context.l10n.correoElectronico,
            Icons.alternate_email,
            ayuda: 'nombre@ejemplo.com',
          ),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          onChanged: (_) => setState(() {}),
          validator: (v) {
            final t = (v ?? '').trim();
            if (t.isEmpty) {
              return _telefono.text.trim().isEmpty
                  ? context.l10n.introCorreoOWhats
                  : null;
            }
            return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(t)
                ? null
                : context.l10n.correoInvalido;
          },
        ),
        espacioCampo,
        TextFormField(
          key: const Key('invitar-telefono'),
          controller: _telefono,
          keyboardType: TextInputType.phone,
          autofillHints: const [AutofillHints.telephoneNumber],
          decoration: decoracionCampo(
            context.l10n.whatsapp,
            Icons.phone_outlined,
            ayuda: context.l10n.whatsappAyuda,
          ),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          onChanged: (_) => setState(() {}),
          validator: (v) {
            final d = (v ?? '').replaceAll(RegExp(r'[^0-9]'), '');
            if (d.isEmpty) {
              return _email.text.trim().isEmpty
                  ? context.l10n.introWhatsOCorreo
                  : null;
            }
            return d.length < 8 || d.length > 15
                ? context.l10n.telNoValido
                : null;
          },
        ),
        if (widget.rolFijo == null) ...[
          espacioCampo,
          SelectorTarjetas<Rol>(
            etiqueta: context.l10n.rol,
            valor: _rol,
            onCambio: (r) => setState(() => _rol = r),
            opciones: [
              for (final e in _roles(context.l10n).entries)
                OpcionTarjeta(
                  e.key,
                  etiquetaRol(e.key),
                  e.value.$1,
                  descripcion: e.value.$2,
                  clave: Key('invitar-rol-${e.key.name}'),
                ),
            ],
          ),
        ],
        if (_soloWhatsapp) ...[
          const SizedBox(height: 10),
          Text(
            context.l10n.sinCorreoAviso,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          children: [
            OutlinedButton.icon(
              key: const Key('invitar-whatsapp'),
              onPressed: _whatsapp,
              icon: const Icon(Icons.chat_outlined),
              label: Text(context.l10n.enviarWhatsapp),
            ),
            if (_rol == Rol.tutor)
              OutlinedButton.icon(
                key: const Key('copiar-enlace-familias'),
                onPressed: _copiarEnlace,
                icon: const Icon(Icons.link_rounded),
                label: Text(context.l10n.copiarEnlace),
              ),
          ],
        ),
        if (_rol == Rol.tutor && fija == null) ...[
          const SizedBox(height: 10),
          Text(
            context.l10n.sinAlumnoAviso,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        if (_eligePersona && fija == null) ...[
          espacioCampo,
          DropdownButtonFormField<String>(
            key: const Key('invitar-persona'),
            initialValue: _jugadorId,
            isExpanded: true,
            decoration: decoracionCampo(
              _rol == Rol.tutor
                  ? context.l10n.tutorDeOpc
                  : context.l10n.fichaAlumno,
              Icons.person_search_outlined,
            ),
            items: [
              for (final p in personas)
                DropdownMenuItem(value: p.id, child: Text(p.nombreCompleto)),
            ],
            validator: (v) => (v == null && _requierePersona)
                ? context.l10n.eligePersona
                : null,
            onChanged: (v) => setState(() => _jugadorId = v),
          ),
        ],
      ],
    );
  }
}
