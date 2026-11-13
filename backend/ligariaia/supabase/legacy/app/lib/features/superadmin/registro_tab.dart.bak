import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/widgets.dart';
import '../../data/models.dart';
import 'superadmin_providers.dart';

String _accion(String a) => switch (a) {
      'INSERT' => 'Alta',
      'UPDATE' => 'Modificación',
      'DELETE' => 'Baja',
      _ => a,
    };

String _hora(DateTime d) {
  final l = d.toLocal();
  return '${fechaLarga(l)} ${l.hour.toString().padLeft(2, '0')}:${l.minute.toString().padLeft(2, '0')}';
}

class RegistroTab extends ConsumerStatefulWidget {
  const RegistroTab({super.key});
  @override
  ConsumerState<RegistroTab> createState() => _RegistroTabState();
}

class _RegistroTabState extends ConsumerState<RegistroTab> {
  String? _tabla; // null = todas

  @override
  Widget build(BuildContext context) {
    return AsyncView<List<RegistroCambio>>(
      value: ref.watch(saRegistroProvider),
      onRetry: () => ref.invalidate(saRegistroProvider),
      builder: (todos) {
        if (todos.isEmpty) return const EstadoVacio(icono: Icons.history, texto: 'El registro de cambios está vacío.');
        final tablas = {for (final r in todos) r.tabla}.toList()..sort();
        final sel = tablas.contains(_tabla) ? _tabla : null;
        final lista = sel == null ? todos : todos.where((r) => r.tabla == sel).toList();
        return Column(children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: DropdownButtonFormField<String?>(
              key: ValueKey(sel),
              initialValue: sel,
              decoration: const InputDecoration(labelText: 'Filtrar por tabla', border: OutlineInputBorder()),
              items: [
                const DropdownMenuItem<String?>(value: null, child: Text('Todas')),
                for (final t in tablas) DropdownMenuItem<String?>(value: t, child: Text(t)),
              ],
              onChanged: (v) => setState(() => _tabla = v),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.refresh(saRegistroProvider.future),
              child: ListView(children: [
                for (final r in lista)
                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.history),
                    title: Text('${_accion(r.accion)} · ${r.tabla}'),
                    subtitle: Text(_hora(r.fecha)),
                  ),
              ]),
            ),
          ),
        ]);
      },
    );
  }
}
