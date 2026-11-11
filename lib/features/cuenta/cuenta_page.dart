import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/auth.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/liga_repository.dart';
import '../../data/models.dart';

final _prefsProvider = FutureProvider.autoDispose<Map<String, bool>>(
    (ref) => ref.watch(ligaRepositoryProvider).prefsNotificacion());
final _notificacionesProvider = FutureProvider.autoDispose<List<NotificacionApp>>(
    (ref) => ref.watch(ligaRepositoryProvider).notificaciones());

const _tiposNotificacion = {
  'resultados': 'Resultados (propuestos, confirmados y correcciones)',
  'calendario': 'Cambios en el calendario',
};

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

  Future<void> _guardarPref(Map<String, bool> actuales, String clave, bool valor) async {
    try {
      await ref.read(ligaRepositoryProvider).guardarPrefsNotificacion({...actuales, clave: valor});
      ref.invalidate(_prefsProvider);
    } catch (_) {
      if (mounted) avisar(context, 'No se pudo guardar la preferencia.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final modo = ref.watch(themeModeProvider);
    final repo = ref.watch(authRepositoryProvider);
    final prefs = ref.watch(_prefsProvider);
    final notifs = ref.watch(_notificacionesProvider);
    final tema = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Mi cuenta')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(repo.email ?? '', style: tema.textTheme.titleMedium),
          const SizedBox(height: 24),
          Text('Apariencia', style: tema.textTheme.titleSmall),
          const SizedBox(height: 8),
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(value: ThemeMode.system, label: Text('Sistema')),
              ButtonSegment(value: ThemeMode.light, label: Text('Claro')),
              ButtonSegment(value: ThemeMode.dark, label: Text('Oscuro')),
            ],
            selected: {modo},
            onSelectionChanged: (s) => ref.read(themeModeProvider.notifier).set(s.first),
          ),
          const SizedBox(height: 32),
          Text('Notificaciones', style: tema.textTheme.titleSmall),
          prefs.when(
            loading: () => const Padding(padding: EdgeInsets.all(16), child: LinearProgressIndicator()),
            error: (_, _) => const Padding(padding: EdgeInsets.all(8), child: Text('No se pudieron cargar tus preferencias.')),
            data: (p) => Column(children: [
              for (final e in _tiposNotificacion.entries)
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(e.value),
                  value: p[e.key] ?? true,
                  onChanged: (v) => _guardarPref(p, e.key, v),
                ),
            ]),
          ),
          notifs.when(
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
            data: (lista) => lista.isEmpty
                ? const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('No tienes notificaciones.'))
                : Column(children: [
                    for (final n in lista.take(10))
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        leading: Icon(n.leida ? Icons.notifications_none : Icons.notifications_active_outlined),
                        title: Text(n.titulo, style: n.leida ? null : const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text([fechaCorta(n.fecha), if (n.cuerpo != null) n.cuerpo!].join(' · ')),
                        onTap: n.leida
                            ? null
                            : () async {
                                await ref.read(ligaRepositoryProvider).marcarNotificacionLeida(n.id);
                                ref.invalidate(_notificacionesProvider);
                              },
                      ),
                  ]),
          ),
          const SizedBox(height: 24),
          Text('Cambiar contraseña', style: tema.textTheme.titleSmall),
          const SizedBox(height: 8),
          Form(
            key: _form,
            child: Column(children: [
              TextFormField(
                controller: _nueva,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Nueva contraseña', border: OutlineInputBorder()),
                validator: (v) => (v == null || v.length < 8) ? 'Mínimo 8 caracteres' : null,
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(onPressed: _cambiar, child: const Text('Actualizar')),
              ),
              if (_mensaje != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(_mensaje!)),
            ]),
          ),
          const SizedBox(height: 32),
          OutlinedButton.icon(
            onPressed: () => ref.read(authRepositoryProvider).cerrarSesion(),
            icon: const Icon(Icons.logout),
            label: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }
}
