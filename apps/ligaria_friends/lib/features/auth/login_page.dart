import 'package:flutter/material.dart';
import 'package:ligaria_ui/ligaria_ui.dart';
import 'auth_repositorio.dart';
import 'auth_widgets.dart';
import 'recuperar_page.dart';
import 'registro_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.auth});
  final AuthRepositorio auth;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _cargando = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      await widget.auth.iniciarSesion(email: _email.text, password: _pass.text);
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
      child: AutofillGroup(
        child: Form(
          key: _form,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text('Bienvenido de nuevo', style: t.headlineSmall),
            const SizedBox(height: 6),
            Text('Entra y organiza tu próximo partido.', style: t.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
            const SizedBox(height: 24),
            if (_error != null) ...[AvisoError(_error!), const SizedBox(height: 16)],
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              textInputAction: TextInputAction.next,
              validator: validarEmail,
              decoration: decoracionCampo('Email', Icons.alternate_email_rounded),
            ),
            espacioCampo,
            CampoPassword(controller: _pass, onEnviar: _entrar),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => RecuperarPage(auth: widget.auth, emailInicial: _email.text))),
                child: const Text('¿Olvidaste tu contraseña?'),
              ),
            ),
            const SizedBox(height: 8),
            BotonPrincipal(texto: 'Iniciar sesión', cargando: _cargando, onPressed: _entrar),
            const SizedBox(height: 20),
            Row(children: [
              const Expanded(child: Divider()),
              Flexible(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text('¿Aún no juegas con nosotros?',
                      textAlign: TextAlign.center, style: t.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                ),
              ),
              const Expanded(child: Divider()),
            ]),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => RegistroPage(auth: widget.auth))),
              icon: const Icon(Icons.person_add_alt_1_rounded),
              label: const Text('Crear cuenta'),
            ),
          ]),
        ),
      ),
    );
  }
}
