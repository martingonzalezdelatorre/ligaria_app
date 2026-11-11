import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/widgets.dart';
import '../../data/liga_repository.dart';
import '../../data/models.dart';
import 'crear_liga_page.dart';
import 'liga_detalle_page.dart';
import 'organizador_providers.dart';

class LigasTab extends ConsumerWidget {
  const LigasTab({super.key, required this.escuelaId});
  final String escuelaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ligas = ref.watch(orgLigasProvider(escuelaId));
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => CrearLigaPage(escuelaId: escuelaId))),
        icon: const Icon(Icons.add),
        label: const Text('Nueva liga'),
      ),
      body: AsyncView<List<Liga>>(
        value: ligas,
        onRetry: () => ref.invalidate(orgLigasProvider(escuelaId)),
        builder: (lista) => lista.isEmpty
            ? const EstadoVacio(icono: Icons.emoji_events_outlined, texto: 'Aún no has creado ninguna liga.\nPulsa «Nueva liga» para empezar.')
            : RefreshIndicator(
                onRefresh: () => ref.refresh(orgLigasProvider(escuelaId).future),
                child: ListView(
                  padding: const EdgeInsets.only(top: 8, bottom: 96),
                  children: [for (final l in lista) _LigaCard(liga: l, escuelaId: escuelaId)],
                ),
              ),
      ),
    );
  }
}

class _LigaCard extends ConsumerWidget {
  const _LigaCard({required this.liga, required this.escuelaId});
  final Liga liga;
  final String escuelaId;

  Future<void> _publicar(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(ligaRepositoryProvider).publicarLiga(liga.id);
      ref.invalidate(orgLigasProvider(escuelaId));
      if (context.mounted) avisar(context, 'Liga publicada: ya admite inscripciones de equipos.');
    } catch (e) {
      if (context.mounted) avisar(context, mensajeError(e, defecto: 'No se pudo publicar la liga.'));
    }
  }

  Future<void> _generar(BuildContext context, WidgetRef ref) async {
    final p = await showDialog<ParamsCalendario>(context: context, builder: (_) => const GenerarCalendarioDialog());
    if (p == null) return;
    try {
      final n = await ref
          .read(ligaRepositoryProvider)
          .generarCalendario(liga.id, inicio: p.inicio, diasEntreJornadas: p.dias);
      ref.invalidate(orgEncuentrosProvider(liga.id));
      ref.invalidate(orgLigasProvider(escuelaId));
      if (context.mounted) avisar(context, 'Calendario generado: $n encuentros.');
    } catch (e) {
      if (context.mounted) avisar(context, mensajeError(e, defecto: 'No se pudo generar el calendario.'));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tema = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(liga.nombre, style: tema.textTheme.titleMedium),
          const SizedBox(height: 2),
          Text('${liga.deporte ?? 'Liga'} · ${etiquetaEstadoLiga(liga.estado)}',
              style: tema.textTheme.bodySmall?.copyWith(color: tema.colorScheme.outline)),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 4, children: [
            if (liga.estado == 'borrador')
              FilledButton.tonal(onPressed: () => _publicar(context, ref), child: const Text('Publicar')),
            if (liga.estado != 'finalizada')
              OutlinedButton(onPressed: () => _generar(context, ref), child: const Text('Generar calendario')),
            TextButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => LigaDetallePage(liga: liga))),
              child: const Text('Ver liga'),
            ),
          ]),
        ]),
      ),
    );
  }
}

class ParamsCalendario {
  const ParamsCalendario(this.inicio, this.dias);
  final DateTime inicio;
  final int dias;
}

/// Pide fecha de inicio y días entre jornadas; avisa de que un calendario existente se sustituye.
class GenerarCalendarioDialog extends StatefulWidget {
  const GenerarCalendarioDialog({super.key});
  @override
  State<GenerarCalendarioDialog> createState() => _GenerarCalendarioDialogState();
}

class _GenerarCalendarioDialogState extends State<GenerarCalendarioDialog> {
  late DateTime _inicio = () {
    final h = DateTime.now();
    return DateTime(h.year, h.month, h.day);
  }();
  final _dias = TextEditingController(text: '7');

  @override
  void dispose() {
    _dias.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Generar calendario'),
      content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Se crearán las jornadas todos contra todos con los equipos inscritos. '
            'Si ya existía un calendario sin resultados, se sustituirá.'),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          icon: const Icon(Icons.event),
          label: Text('Primera jornada: ${fechaLarga(_inicio)}'),
          onPressed: () async {
            final f = await showDatePicker(
                context: context, initialDate: _inicio, firstDate: DateTime(2020), lastDate: DateTime(2100));
            if (f != null) setState(() => _inicio = f);
          },
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _dias,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Días entre jornadas', border: OutlineInputBorder()),
        ),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(ParamsCalendario(_inicio, (int.tryParse(_dias.text) ?? 7).clamp(1, 60))),
          child: const Text('Generar'),
        ),
      ],
    );
  }
}
