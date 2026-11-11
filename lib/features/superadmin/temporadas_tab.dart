import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/widgets.dart';
import '../../data/liga_repository.dart';
import '../../data/models.dart';
import 'superadmin_providers.dart';

class TemporadasTab extends ConsumerWidget {
  const TemporadasTab({super.key});

  Future<void> _crear(BuildContext context, WidgetRef ref) async {
    final r = await showDialog<(String, DateTime, DateTime)>(context: context, builder: (_) => const _NuevaTemporadaDialog());
    if (r == null) return;
    try {
      await ref.read(ligaRepositoryProvider).crearTemporada(r.$1, r.$2, r.$3);
      ref.invalidate(saTemporadasProvider);
      if (context.mounted) avisar(context, 'Temporada creada.');
    } catch (_) {
      if (context.mounted) avisar(context, 'No se pudo crear la temporada. Comprueba que el nombre no esté repetido.');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _crear(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Nueva temporada'),
      ),
      body: AsyncView<List<Temporada>>(
        value: ref.watch(saTemporadasProvider),
        onRetry: () => ref.invalidate(saTemporadasProvider),
        builder: (lista) => lista.isEmpty
            ? const EstadoVacio(icono: Icons.event_outlined, texto: 'Todavía no hay temporadas.')
            : ListView(
                padding: const EdgeInsets.only(top: 8, bottom: 96),
                children: [
                  for (final t in lista)
                    ListTile(
                      leading: const Icon(Icons.event_outlined),
                      title: Text(t.nombre),
                      subtitle: Text('${fechaLarga(t.inicio)} – ${fechaLarga(t.fin)}'),
                    ),
                ],
              ),
      ),
    );
  }
}

class _NuevaTemporadaDialog extends StatefulWidget {
  const _NuevaTemporadaDialog();
  @override
  State<_NuevaTemporadaDialog> createState() => _NuevaTemporadaDialogState();
}

class _NuevaTemporadaDialogState extends State<_NuevaTemporadaDialog> {
  final _nombre = TextEditingController();
  late DateTime _inicio = DateTime(DateTime.now().year, 9, 1);
  late DateTime _fin = DateTime(DateTime.now().year + 1, 6, 30);
  String? _error;

  @override
  void dispose() {
    _nombre.dispose();
    super.dispose();
  }

  Future<void> _elegir(bool inicio) async {
    final f = await showDatePicker(
        context: context, initialDate: inicio ? _inicio : _fin, firstDate: DateTime(2020), lastDate: DateTime(2100));
    if (f != null) setState(() => inicio ? _inicio = f : _fin = f);
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Nueva temporada'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(
            controller: _nombre,
            autofocus: true,
            decoration: InputDecoration(labelText: 'Nombre (p. ej. 2026-27)', errorText: _error, border: const OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(onPressed: () => _elegir(true), icon: const Icon(Icons.event), label: Text('Inicio: ${fechaLarga(_inicio)}')),
          OutlinedButton.icon(onPressed: () => _elegir(false), icon: const Icon(Icons.event), label: Text('Fin: ${fechaLarga(_fin)}')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              if (_nombre.text.trim().isEmpty) {
                setState(() => _error = 'Escribe un nombre');
              } else if (_fin.isBefore(_inicio)) {
                setState(() => _error = 'El fin debe ser posterior al inicio');
              } else {
                Navigator.of(context).pop((_nombre.text.trim(), _inicio, _fin));
              }
            },
            child: const Text('Crear'),
          ),
        ],
      );
}
