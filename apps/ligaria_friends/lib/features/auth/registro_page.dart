import 'package:flutter/material.dart';
import 'package:ligaria_ui/ligaria_ui.dart';
import '../../core/invitacion.dart';
import 'auth_repositorio.dart';
import 'auth_widgets.dart';

class RegistroPage extends StatefulWidget {
  const RegistroPage({super.key, required this.auth, this.invitado = false});
  final AuthRepositorio auth;

  /// Llega desde un enlace de invitación: se avisa de que entrará a un grupo.
  final bool invitado;

  @override
  State<RegistroPage> createState() => _RegistroPageState();
}

class _RegistroPageState extends State<RegistroPage> {
  final _form = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _pass2 = TextEditingController();
  late final _codigo = TextEditingController(text: Invitacion.pendiente ?? '');
  bool _cargando = false;
  bool _acepto = false;
  bool _confirmar = false;
  bool _esTienda = false;
  final _tienda = TextEditingController();
  String? _error;

  @override
  void dispose() {
    for (final c in [_nombre, _email, _pass, _pass2, _codigo, _tienda]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _registrar() async {
    if (!_form.currentState!.validate()) return;
    if (!_acepto) {
      setState(() => _error = 'Debes aceptar las condiciones de uso.');
      return;
    }
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      if (!_esTienda) {
        await Invitacion.guardar(
          _codigo.text,
        ); // se une al grupo al tener sesión
      }
      final dentro = await widget.auth.registrar(
        nombre: _nombre.text.trim(),
        email: _email.text,
        password: _pass.text,
        nombreTienda: _esTienda ? _tienda.text.trim() : null,
      );
      if (!mounted) return;
      if (dentro) {
        Navigator.of(context).popUntil(
          (r) => r.isFirst,
        ); // la raíz muestra el inicio al detectar la sesión
      } else {
        setState(() => _confirmar = true);
      }
    } on AuthException catch (e) {
      if (mounted) setState(() => _error = e.mensaje);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return AuthScaffold(
      atras: true,
      child: _confirmar
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Center(
                  child: MedallonVacio(icono: Icons.mark_email_read_outlined),
                ),
                const SizedBox(height: 20),
                Text(
                  'Confirma tu email',
                  style: t.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Te hemos enviado un enlace a ${_email.text.trim()}. Ábrelo para activar tu cuenta y luego inicia sesión.',
                  style: t.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                BotonPrincipal(
                  texto: 'Ir a iniciar sesión',
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
              ],
            )
          : AutofillGroup(
              child: Form(
                key: _form,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Crea tu cuenta', style: t.headlineSmall),
                    const SizedBox(height: 6),
                    Text(
                      widget.invitado
                          ? 'Te han invitado a un grupo. Crea tu cuenta y entrarás directamente.'
                          : 'Únete a la liga y reta a tus amigos.',
                      style: t.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                    ),
                    const SizedBox(height: 24),
                    if (_error != null) ...[
                      AvisoError(_error!),
                      const SizedBox(height: 16),
                    ],
                    SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment(
                          value: false,
                          label: Text('Jugador'),
                          icon: Icon(Icons.sports_tennis),
                        ),
                        ButtonSegment(
                          value: true,
                          label: Text('Tienda'),
                          icon: Icon(Icons.storefront_outlined),
                        ),
                      ],
                      selected: {_esTienda},
                      onSelectionChanged: (s) =>
                          setState(() => _esTienda = s.first),
                    ),
                    const SizedBox(height: 16),
                    if (_esTienda) ...[
                      TextFormField(
                        controller: _tienda,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        validator: (v) => (v == null || v.trim().length < 2)
                            ? 'Introduce el nombre de la tienda'
                            : null,
                        decoration: decoracionCampo(
                          'Nombre de la tienda',
                          Icons.storefront_outlined,
                        ),
                      ),
                      espacioCampo,
                    ],
                    TextFormField(
                      controller: _nombre,
                      textCapitalization: TextCapitalization.words,
                      autofillHints: const [AutofillHints.name],
                      textInputAction: TextInputAction.next,
                      validator: (v) => (v == null || v.trim().length < 2)
                          ? 'Introduce tu nombre'
                          : null,
                      decoration: decoracionCampo(
                        _esTienda ? 'Tu nombre (responsable)' : 'Nombre',
                        Icons.person_outline_rounded,
                      ),
                    ),
                    espacioCampo,
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      textInputAction: TextInputAction.next,
                      validator: validarEmail,
                      decoration: decoracionCampo(
                        'Email',
                        Icons.alternate_email_rounded,
                      ),
                    ),
                    espacioCampo,
                    CampoPassword(
                      controller: _pass,
                      accion: TextInputAction.next,
                    ),
                    espacioCampo,
                    CampoPassword(
                      controller: _pass2,
                      etiqueta: 'Repite la contraseña',
                      validator: (v) => v != _pass.text
                          ? 'Las contraseñas no coinciden'
                          : null,
                      onEnviar: _registrar,
                    ),
                    if (!_esTienda) ...[
                      espacioCampo,
                      TextFormField(
                        controller: _codigo,
                        textCapitalization: TextCapitalization.characters,
                        textInputAction: TextInputAction.done,
                        decoration: decoracionCampo(
                          'Código de invitación (opcional)',
                          Icons.group_add_outlined,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 6, left: 4),
                        child: Text(
                          'Si un amigo te invitó, escribe su código y entrarás en su grupo.',
                          style: t.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      value: _acepto,
                      onChanged: (v) => setState(() => _acepto = v ?? false),
                      title: Text(
                        'Acepto las condiciones de uso y la política de privacidad',
                        style: t.bodySmall,
                      ),
                    ),
                    const SizedBox(height: 8),
                    BotonPrincipal(
                      texto: 'Registrarme',
                      cargando: _cargando,
                      onPressed: _registrar,
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      child: const Text('Ya tengo cuenta'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
