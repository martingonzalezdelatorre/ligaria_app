import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/auth.dart';
import '../../core/formulario.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';

class CuentaPage extends ConsumerStatefulWidget {
  const CuentaPage({super.key});
  @override
  ConsumerState<CuentaPage> createState() => _CuentaPageState();
}

class _CuentaPageState extends ConsumerState<CuentaPage> {
  final _form = GlobalKey<FormState>();
  final _nueva = TextEditingController();
  String? _mensaje;

  @override
  void dispose() {
    _nueva.dispose();
    super.dispose();
  }

  Future<void> _cambiar() async {
    if (!_form.currentState!.validate()) return;
    try {
      await ref.read(authRepositoryProvider).cambiarPassword(_nueva.text);
      _nueva.clear();
      setState(() => _mensaje = 'Contraseña actualizada.');
    } catch (_) {
      setState(() => _mensaje = 'No se pudo cambiar la contraseña.');
    }
  }

  Widget _seccion(BuildContext context, IconData icono, String titulo, Widget hijo) {
    final tema = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            Icon(icono, color: tema.colorScheme.primary, size: 22),
            const SizedBox(width: 10),
            Text(titulo, style: tema.textTheme.titleMedium),
          ]),
          const SizedBox(height: 14),
          hijo,
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(authRepositoryProvider);
    final tema = Theme.of(context);
    final cs = tema.colorScheme;
    final email = repo.email ?? '';

    final cabecera = Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [lima.withValues(alpha: .16), menta.withValues(alpha: .04)]),
        ),
        child: Row(children: [
          AvatarEquipo(email.isEmpty ? '?' : email, tam: 56),
          const SizedBox(width: 16),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Tu cuenta', style: tema.textTheme.labelMedium?.copyWith(color: cs.onSurfaceVariant)),
              Text(email, style: tema.textTheme.titleMedium, overflow: TextOverflow.ellipsis),
            ]),
          ),
        ]),
      ),
    );

    final password = _seccion(
      context,
      Icons.lock_outline,
      'Cambiar contraseña',
      Form(
        key: _form,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          TextFormField(
            controller: _nueva,
            obscureText: true,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _cambiar(),
            decoration: decoracionCampo('Nueva contraseña', Icons.password, ayuda: 'Al menos 8 caracteres'),
            validator: (v) => (v == null || v.length < 8) ? 'Mínimo 8 caracteres' : null,
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(onPressed: _cambiar, child: const Text('Actualizar')),
          ),
          if (_mensaje != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(_mensaje!)),
        ]),
      ),
    );

    final salir = OutlinedButton.icon(
      onPressed: () => ref.read(authRepositoryProvider).cerrarSesion(),
      icon: const Icon(Icons.logout),
      label: const Text('Cerrar sesión'),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Mi cuenta')),
      body: ContenidoCentrado(
        maxAncho: 760,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 32),
          children: [
            cabecera,
            password,
            Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: salir),
          ],
        ),
      ),
    );
  }
}
