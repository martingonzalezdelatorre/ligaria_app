import 'package:flutter/material.dart';
import 'package:ligaria_ui/ligaria_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/auth.dart';


/// Marco común: fondo de la marca y tarjeta centrada.
class _Marco extends StatelessWidget {
  const _Marco({required this.titulo, required this.child});
  final String titulo;
  final Widget child;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: FondoBlobs(
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(children: [
                            const LogoLigaria(tam: 32),
                            const SizedBox(width: 10),
                            Text('Ligaria', style: Theme.of(context).textTheme.titleLarge),
                          ]),
                          const SizedBox(height: 20),
                          Text(titulo, style: Theme.of(context).textTheme.headlineSmall),
                          const SizedBox(height: 16),
                          child,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}

/// Paso 1: pedir el correo para recibir el enlace.
class RecuperarPasswordPage extends ConsumerStatefulWidget {
  const RecuperarPasswordPage({super.key});
  @override
  ConsumerState<RecuperarPasswordPage> createState() => _RecuperarState();
}

class _RecuperarState extends ConsumerState<RecuperarPasswordPage> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
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
      await ref.read(authRepositoryProvider).enviarRecuperacion(_email.text);
      if (mounted) setState(() => _enviado = true);
    } catch (_) {
      if (mounted) setState(() => _error = 'No se pudo enviar el correo. Inténtalo de nuevo en unos minutos.');
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (_enviado) {
      return _Marco(
        titulo: 'Revisa tu correo',
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(
            'Si existe una cuenta con ${_email.text.trim()}, te hemos enviado un enlace para elegir una contraseña nueva. '
            'Caduca en poco tiempo; mira también la carpeta de spam.',
            style: TextStyle(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 24),
          FilledButton(onPressed: () => context.go('/login'), child: const Text('Volver a iniciar sesión')),
        ]),
      );
    }
    return _Marco(
      titulo: 'Recuperar contraseña',
      child: Form(
        key: _form,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text('Escribe tu correo y te enviaremos un enlace para elegir una contraseña nueva.',
              style: TextStyle(color: cs.onSurfaceVariant)),
          const SizedBox(height: 20),
          TextFormField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            decoration: const InputDecoration(labelText: 'Correo electrónico', prefixIcon: Icon(Icons.mail_outline)),
            validator: (v) => (v == null || !v.contains('@')) ? 'Introduce un correo válido' : null,
            onFieldSubmitted: (_) => _enviar(),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: TextStyle(color: cs.error)),
          ],
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _cargando ? null : _enviar,
            child: _cargando
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Enviar enlace'),
          ),
          TextButton(onPressed: () => context.go('/login'), child: const Text('Volver')),
        ]),
      ),
    );
  }
}

/// Paso 2: llega desde el enlace del correo (sesión de recuperación) y elige la contraseña nueva.
class NuevaPasswordPage extends ConsumerStatefulWidget {
  const NuevaPasswordPage({super.key});
  @override
  ConsumerState<NuevaPasswordPage> createState() => _NuevaState();
}

class _NuevaState extends ConsumerState<NuevaPasswordPage> {
  final _form = GlobalKey<FormState>();
  final _nueva = TextEditingController();
  final _repite = TextEditingController();
  bool _cargando = false;
  String? _error;

  @override
  void dispose() {
    _nueva.dispose();
    _repite.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      await ref.read(authRepositoryProvider).cambiarPassword(_nueva.text);
      if (!mounted) return;
      ref.read(recuperacionProvider.notifier).terminar(); // el router nos lleva al inicio
    } catch (_) {
      if (mounted) setState(() => _error = 'No se pudo cambiar la contraseña. El enlace puede haber caducado: pide uno nuevo.');
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _cancelar() async {
    await ref.read(authRepositoryProvider).cerrarSesion();
    ref.read(recuperacionProvider.notifier).terminar();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return _Marco(
      titulo: 'Elige tu nueva contraseña',
      child: Form(
        key: _form,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          TextFormField(
            controller: _nueva,
            obscureText: true,
            autofillHints: const [AutofillHints.newPassword],
            decoration: const InputDecoration(labelText: 'Nueva contraseña', prefixIcon: Icon(Icons.lock_outline)),
            validator: (v) => (v == null || v.length < 8) ? 'Mínimo 8 caracteres' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _repite,
            obscureText: true,
            autofillHints: const [AutofillHints.newPassword],
            decoration: const InputDecoration(labelText: 'Repite la contraseña', prefixIcon: Icon(Icons.lock_reset)),
            validator: (v) => v != _nueva.text ? 'Las contraseñas no coinciden' : null,
            onFieldSubmitted: (_) => _guardar(),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: TextStyle(color: cs.error)),
          ],
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _cargando ? null : _guardar,
            child: _cargando
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Guardar contraseña'),
          ),
          TextButton(onPressed: _cancelar, child: const Text('Cancelar')),
        ]),
      ),
    );
  }
}
