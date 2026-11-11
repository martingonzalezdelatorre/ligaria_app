import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/widgets.dart';
import '../../data/liga_repository.dart';
import '../../data/models.dart';
import 'superadmin_providers.dart';

const moduloCompeticiones = 'competiciones';

class EscuelasTab extends ConsumerWidget {
  const EscuelasTab({super.key});

  Future<void> _crear(BuildContext context, WidgetRef ref) async {
    final r = await showDialog<(String, String)>(context: context, builder: (_) => const _NuevaEscuelaDialog());
    if (r == null) return;
    try {
      await ref.read(ligaRepositoryProvider).crearEscuela(r.$1, r.$2);
      ref.invalidate(saEscuelasProvider);
      if (context.mounted) avisar(context, 'Escuela creada.');
    } catch (_) {
      if (context.mounted) avisar(context, 'No se pudo crear la escuela. Comprueba que el identificador no esté repetido.');
    }
  }

  Future<void> _modulo(BuildContext context, WidgetRef ref, EscuelaAdmin e, bool activo) async {
    try {
      await ref.read(ligaRepositoryProvider).setModulo(e.id, moduloCompeticiones, activo);
      ref.invalidate(saEscuelasProvider);
    } catch (_) {
      if (context.mounted) avisar(context, 'No se pudo cambiar el módulo.');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _crear(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Nueva escuela'),
      ),
      body: AsyncView<List<EscuelaAdmin>>(
        value: ref.watch(saEscuelasProvider),
        onRetry: () => ref.invalidate(saEscuelasProvider),
        builder: (lista) => lista.isEmpty
            ? const EstadoVacio(icono: Icons.school_outlined, texto: 'Todavía no hay escuelas.')
            : ListView(
                padding: const EdgeInsets.only(top: 8, bottom: 96),
                children: [
                  for (final e in lista)
                    Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      child: SwitchListTile(
                        title: Text(e.nombre),
                        subtitle: Text('${e.slug} · Módulo competiciones'),
                        value: e.modulos[moduloCompeticiones] ?? false,
                        onChanged: (v) => _modulo(context, ref, e, v),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}

class _NuevaEscuelaDialog extends StatefulWidget {
  const _NuevaEscuelaDialog();
  @override
  State<_NuevaEscuelaDialog> createState() => _NuevaEscuelaDialogState();
}

class _NuevaEscuelaDialogState extends State<_NuevaEscuelaDialog> {
  final _nombre = TextEditingController();
  final _slug = TextEditingController();
  bool _slugEditado = false;
  String? _error;

  @override
  void dispose() {
    _nombre.dispose();
    _slug.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Nueva escuela'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(
            controller: _nombre,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Nombre', border: OutlineInputBorder()),
            onChanged: (v) {
              if (!_slugEditado) _slug.text = slugDe(v);
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _slug,
            decoration: InputDecoration(labelText: 'Identificador (slug)', errorText: _error, border: const OutlineInputBorder()),
            onChanged: (_) => _slugEditado = true,
          ),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              final n = _nombre.text.trim(), s = slugDe(_slug.text);
              if (n.isEmpty || s.isEmpty) {
                setState(() => _error = 'Nombre e identificador obligatorios');
              } else {
                Navigator.of(context).pop((n, s));
              }
            },
            child: const Text('Crear'),
          ),
        ],
      );
}
