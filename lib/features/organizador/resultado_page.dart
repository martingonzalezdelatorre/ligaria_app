import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/widgets.dart';
import '../../data/liga_repository.dart';
import '../../data/models.dart';
import 'correccion_page.dart';
import 'organizador_providers.dart';

/// Detalle de un encuentro con su resultado: confirmar, rechazar o corregir.
class ResultadoPage extends ConsumerWidget {
  const ResultadoPage({super.key, required this.escuelaId, required this.encuentro});
  final String escuelaId;
  final EncuentroVista encuentro;

  Future<void> _confirmar(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(ligaRepositoryProvider).confirmarResultado(encuentro.id);
      refrescarResultado(ref, escuelaId, encuentro);
      if (!context.mounted) return;
      avisar(context, 'Resultado confirmado.');
      Navigator.of(context).pop();
    } catch (e) {
      if (context.mounted) avisar(context, mensajeError(e, defecto: 'No se pudo confirmar el resultado.'));
    }
  }

  Future<void> _rechazar(BuildContext context, WidgetRef ref) async {
    final motivo = await showDialog<String>(context: context, builder: (_) => const _MotivoDialog());
    if (motivo == null) return;
    try {
      await ref.read(ligaRepositoryProvider).rechazarResultado(encuentro.id, motivo);
      refrescarResultado(ref, escuelaId, encuentro);
      if (!context.mounted) return;
      avisar(context, 'Resultado devuelto al entrenador.');
      Navigator.of(context).pop();
    } catch (e) {
      if (context.mounted) avisar(context, mensajeError(e, defecto: 'No se pudo rechazar el resultado.'));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tema = Theme.of(context);
    final detalle = ref.watch(orgDetalleProvider(encuentro.id));
    final historial = ref.watch(orgCorreccionesProvider(encuentro.id)).value ?? const <Correccion>[];
    final puedeCorregir = detalle.hasValue && !encuentro.estado.contains('programado');
    return Scaffold(
      appBar: AppBar(title: Text('Jornada ${encuentro.jornada}')),
      body: AsyncView<DetalleEncuentro>(
        value: detalle,
        onRetry: () => ref.invalidate(orgDetalleProvider(encuentro.id)),
        builder: (d) => ListView(padding: const EdgeInsets.all(12), children: [
          TarjetaEncuentro(encuentro: encuentro),
          if (d.incomparecencia != null)
            Card(
              color: tema.colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text('Incomparecencia: no se presentó '
                    '${d.incomparecencia == 'local' ? encuentro.local : encuentro.visitante}. Cuenta como derrota administrativa.'),
              ),
            ),
          for (final p in d.partidos) _PartidoCard(partido: p),
          if (historial.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 16, 4, 4),
              child: Text('Historial de correcciones', style: tema.textTheme.titleSmall),
            ),
            for (final c in historial)
              ListTile(
                dense: true,
                leading: const Icon(Icons.history),
                title: Text(c.motivo),
                subtitle: Text(fechaLarga(c.fecha)),
              ),
          ],
        ]),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Wrap(spacing: 8, runSpacing: 8, alignment: WrapAlignment.end, children: [
            if (encuentro.propuesto) ...[
              FilledButton(onPressed: () => _confirmar(context, ref), child: const Text('Confirmar')),
              OutlinedButton(onPressed: () => _rechazar(context, ref), child: const Text('Rechazar')),
            ],
            if (puedeCorregir)
              OutlinedButton(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => CorreccionPage(
                        escuelaId: escuelaId, encuentro: encuentro, detalle: detalle.requireValue))),
                child: const Text('Corregir'),
              ),
          ]),
        ),
      ),
    );
  }
}

class _PartidoCard extends StatelessWidget {
  const _PartidoCard({required this.partido});
  final PartidoDetalle partido;
  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    String quien(List<String> n) => n.isEmpty ? '—' : n.join(' / ');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Partido ${partido.orden} · ${partido.tipo == 'dobles' ? 'Dobles' : 'Individual'}',
              style: tema.textTheme.labelLarge),
          const SizedBox(height: 6),
          Row(children: [
            Expanded(child: Text(quien(partido.local))),
            Expanded(child: Text(quien(partido.visitante), textAlign: TextAlign.end)),
          ]),
          const SizedBox(height: 6),
          Text(partido.sets.isEmpty ? 'Sin jugar' : partido.sets.map((s) => '${s[0]}-${s[1]}').join('   ·   '),
              style: tema.textTheme.titleMedium),
        ]),
      ),
    );
  }
}

class _MotivoDialog extends StatefulWidget {
  const _MotivoDialog();
  @override
  State<_MotivoDialog> createState() => _MotivoDialogState();
}

class _MotivoDialogState extends State<_MotivoDialog> {
  final _c = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Rechazar resultado'),
        content: TextField(
          controller: _c,
          autofocus: true,
          maxLines: 3,
          decoration: InputDecoration(labelText: 'Motivo (se envía al entrenador)', errorText: _error, border: const OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              final t = _c.text.trim();
              if (t.isEmpty) {
                setState(() => _error = 'Indica el motivo');
              } else {
                Navigator.of(context).pop(t);
              }
            },
            child: const Text('Rechazar'),
          ),
        ],
      );
}
