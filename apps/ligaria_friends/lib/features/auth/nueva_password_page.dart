import 'package:flutter/material.dart';
import 'package:ligaria_ui/ligaria_ui.dart';
import 'auth_repositorio.dart';
import 'auth_widgets.dart';
import '../../core/idioma.dart';

/// Paso 2 de la recuperación: se llega desde el enlace del correo (sesión de recuperación)
/// y se elige la contraseña nueva.
class NuevaPasswordPage extends StatefulWidget {
  const NuevaPasswordPage({
    super.key,
    required this.auth,
    required this.onTerminar,
  });
  final AuthRepositorio auth;

  /// Se llama al guardar o cancelar; la raíz vuelve entonces al flujo normal.
  final VoidCallback onTerminar;

  @override
  State<NuevaPasswordPage> createState() => _NuevaPasswordPageState();
}

class _NuevaPasswordPageState extends State<NuevaPasswordPage> {
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
      await widget.auth.cambiarPassword(_nueva.text);
      if (mounted) widget.onTerminar();
    } on AuthException {
      if (mounted) {
        setState(() => _error = l10nActual.errCambiarContrasena);
      }
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _cancelar() async {
    await widget.auth.cerrarSesion();
    widget.onTerminar();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return AuthScaffold(
      child: Form(
        key: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(context.l10n.eligeNuevaContrasena, style: t.headlineSmall),
            const SizedBox(height: 6),
            Text(
              context.l10n.minimo8Punto,
              style: t.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            if (_error != null) ...[
              AvisoError(_error!),
              const SizedBox(height: 16),
            ],
            CampoPassword(
              controller: _nueva,
              etiqueta: context.l10n.nuevaContrasena,
              accion: TextInputAction.next,
            ),
            espacioCampo,
            CampoPassword(
              controller: _repite,
              etiqueta: context.l10n.repiteContrasena,
              validator: (v) =>
                  v != _nueva.text ? context.l10n.contrasenasNoCoinciden : null,
              onEnviar: _guardar,
            ),
            const SizedBox(height: 24),
            BotonPrincipal(
              texto: context.l10n.guardarContrasena,
              cargando: _cargando,
              onPressed: _guardar,
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _cancelar,
              child: Text(context.l10n.cancelar),
            ),
          ],
        ),
      ),
    );
  }
}
