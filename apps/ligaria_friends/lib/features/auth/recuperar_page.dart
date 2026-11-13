import 'package:flutter/material.dart';
import 'package:ligaria_ui/ligaria_ui.dart';
import 'auth_repositorio.dart';
import 'auth_widgets.dart';

class RecuperarPage extends StatefulWidget {
  const RecuperarPage({super.key, required this.auth, this.emailInicial = ''});
  final AuthRepositorio auth;
  final String emailInicial;

  @override
  State<RecuperarPage> createState() => _RecuperarPageState();
}

class _RecuperarPageState extends State<RecuperarPage> {
  final _form = GlobalKey<FormState>();
  late final _email = TextEditingController(text: widget.emailInicial);
  bool _cargando = false, _enviado = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      await widget.auth.recuperarPassword(email: _email.text.trim());
      if (mounted) setState(() => _enviado = true);
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
      child: _enviado
          ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              const Center(child: MedallonVacio(icono: Icons.mark_email_read_outlined)),
              const SizedBox(height: 20),
              Text('Revisa tu correo', style: t.headlineSmall, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text('Si existe una cuenta con ${_email.text.trim()}, te hemos enviado un enlace para elegir una contraseña nueva. Caduca en poco tiempo; mira también la carpeta de spam.',
                  style: t.bodyMedium?.copyWith(color: cs.onSurfaceVariant), textAlign: TextAlign.center),
              const SizedBox(height: 24),
              BotonPrincipal(texto: 'Volver a iniciar sesión', onPressed: () => Navigator.of(context).maybePop()),
            ])
          : Form(
              key: _form,
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Text('Recupera tu contraseña', style: t.headlineSmall),
                const SizedBox(height: 6),
                Text('Escribe tu correo y te enviaremos un enlace para elegir una contraseña nueva.', style: t.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
                const SizedBox(height: 24),
                if (_error != null) ...[AvisoError(_error!), const SizedBox(height: 16)],
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  textInputAction: TextInputAction.done,
                  validator: validarEmail,
                  onFieldSubmitted: (_) => _enviar(),
                  decoration: decoracionCampo('Correo electrónico', Icons.mail_outline),
                ),
                const SizedBox(height: 24),
                BotonPrincipal(texto: 'Enviar enlace', cargando: _cargando, onPressed: _enviar),
              ]),
            ),
    );
  }
}
