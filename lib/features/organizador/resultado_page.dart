import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/widgets.dart';
import '../../data/models.dart';
import '../entrenador/resultado_form_page.dart';
import 'organizador_providers.dart';

/// Detalle de un encuentro con su resultado. La organización puede registrarlo o corregirlo.
class ResultadoPage extends ConsumerWidget {
  const ResultadoPage({super.key, required this.escuelaId, required this.encuentro});
  final String escuelaId;
  final EncuentroVista encuentro;

  Future<void> _editar(BuildContext context, WidgetRef ref) async {
    final guardado = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => ResultadoFormPage(encuentro: encuentro)),
    );
    if (guardado == true) {
      refrescarResultado(ref, encuentro);
      if (!context.mounted) return;
      avisar(context, 'Resultado guardado. La clasificación se ha actualizado.');
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tema = Theme.of(context);
    final detalle = ref.watch(orgDetalleProvider(encuentro.id));
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
        ]),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              key: const Key('editar-resultado'),
              icon: const Icon(Icons.edit_note),
              onPressed: () => _editar(context, ref),
              label: Text(encuentro.confirmado ? 'Corregir resultado' : 'Registrar resultado'),
            ),
          ),
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
