import 'package:flutter/material.dart';
import 'package:ligaria_ui/ligaria_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/auth.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});
  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
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
      await ref.read(authRepositoryProvider).iniciarSesion(_email.text, _pass.text);
    } catch (_) {
      if (mounted) setState(() => _error = 'Correo o contraseña incorrectos.');
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tema = Theme.of(context);
    final ancha = Pantalla.esAncha(context);
    final formulario = _formulario(context);
    final titulo = Column(crossAxisAlignment: ancha ? CrossAxisAlignment.start : CrossAxisAlignment.center, children: [
      Text('Ligaria', style: tema.textTheme.headlineMedium?.copyWith(color: Colors.white)),
    ]);
    final lema = Text('Calendarios, resultados y clasificación de tu liga, siempre a mano.',
        textAlign: ancha ? TextAlign.start : TextAlign.center,
        style: tema.textTheme.bodyLarge?.copyWith(color: cs.onSurfaceVariant));

    if (!ancha) {
      return Scaffold(
        body: FondoBlobs(child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  HeroPista(alto: (MediaQuery.sizeOf(context).height * .24).clamp(110.0, 190.0)),
                  const SizedBox(height: 20),
                  Aparece(retardo: 150, child: titulo),
                  const SizedBox(height: 6),
                  Aparece(retardo: 250, child: lema),
                  const SizedBox(height: 20),
                  Aparece(retardo: 350, child: Card(margin: EdgeInsets.zero, child: Padding(padding: const EdgeInsets.all(22), child: formulario))),
                ]),
              ),
            ),
          ),
        )),
      );
    }
    // Pantalla ancha (tablet/escritorio): ilustración grande a la izquierda y formulario a la derecha.
    return Scaffold(
      body: Row(children: [
        Expanded(
          flex: 5,
          child: Container(
            color: Colors.transparent,
            padding: const EdgeInsets.all(40),
            child: Center(child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                  HeroPista(alto: (MediaQuery.sizeOf(context).height * .42).clamp(180.0, 340.0), radio: 32),
                  const SizedBox(height: 28),
                  Row(children: [const LogoLigaria(tam: 44), const SizedBox(width: 12), titulo]),
                  const SizedBox(height: 10),
                  Aparece(retardo: 250, child: lema),
                ]),
              ),
            )),
          ),
        ),
        Expanded(
          flex: 4,
          child: FondoBlobs(child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 400), child: Aparece(retardo: 250, child: formulario)),
            ),
          )),
        ),
      ]),
    );
  }

  Widget _formulario(BuildContext context) => Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Iniciar sesión', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 20),
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              decoration: const InputDecoration(labelText: 'Correo electrónico', prefixIcon: Icon(Icons.mail_outline)),
              validator: (v) => (v == null || !v.contains('@')) ? 'Introduce un correo válido' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _pass,
              obscureText: true,
              autofillHints: const [AutofillHints.password],
              decoration: const InputDecoration(labelText: 'Contraseña', prefixIcon: Icon(Icons.lock_outline)),
              validator: (v) => (v == null || v.isEmpty) ? 'Introduce tu contraseña' : null,
              onFieldSubmitted: (_) => _entrar(),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => context.push('/recuperar'),
                child: const Text('¿Has olvidado tu contraseña?'),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _cargando ? null : _entrar,
              child: _cargando
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Entrar'),
            ),
          ],
        ),
      );
}
