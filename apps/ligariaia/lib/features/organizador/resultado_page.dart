import '../../core/idioma.dart';
import 'package:flutter/material.dart';
import 'package:ligaria_ui/ligaria_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/widgets.dart';
import '../../data/models.dart';
import '../entrenador/resultado_form_page.dart';
import 'organizador_providers.dart';
import 'programar_dialog.dart';

/// Detalle de un encuentro con su resultado. La organización puede registrarlo o corregirlo.
class ResultadoPage extends ConsumerWidget {
  const ResultadoPage({
    super.key,
    required this.escuelaId,
    required this.encuentro,
  });
  final String escuelaId;
  final EncuentroVista encuentro;

  Future<void> _editar(BuildContext context, WidgetRef ref) async {
    final guardado = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ResultadoFormPage(encuentro: encuentro),
      ),
    );
    if (guardado == true) {
      refrescarResultado(ref, encuentro);
      if (!context.mounted) return;
      avisar(context, context.l10n.resultadoGuardadoClasif);
      Navigator.of(context).pop();
    }
  }

  Future<void> _programar(BuildContext context, WidgetRef ref) async {
    if (await mostrarProgramar(context, encuentro)) {
      refrescarResultado(ref, encuentro);
      if (!context.mounted) return;
      avisar(context, context.l10n.partidoProgramado);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tema = Theme.of(context);
    final detalle = ref.watch(orgDetalleProvider(encuentro.id));
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.jornadaN(encuentro.jornada))),
      body: AsyncView<DetalleEncuentro>(
        value: detalle,
        onRetry: () => ref.invalidate(orgDetalleProvider(encuentro.id)),
        builder: (d) => ListView(
          padding: const EdgeInsets.all(12),
          children: [
            TarjetaEncuentro(encuentro: encuentro),
            if (d.incomparecencia != null)
              Card(
                color: tema.colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    context.l10n.incomparecenciaDetalle(
                      d.incomparecencia == 'local'
                          ? encuentro.local
                          : encuentro.visitante,
                    ),
                  ),
                ),
              ),
            for (final p in d.partidos) _PartidoCard(partido: p),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Wrap(
            alignment: WrapAlignment.end,
            spacing: 12,
            runSpacing: 8,
            children: [
              if (!encuentro.confirmado)
                OutlinedButton.icon(
                  key: const Key('programar-partido'),
                  icon: const Icon(Icons.event_outlined),
                  onPressed: () => _programar(context, ref),
                  label: Text(context.l10n.programarPartido),
                ),
              FilledButton.icon(
                key: const Key('editar-resultado'),
                icon: const Icon(Icons.edit_note),
                onPressed: () => _editar(context, ref),
                label: Text(
                  encuentro.confirmado
                      ? context.l10n.corregirResultado
                      : context.l10n.registrarResultado,
                ),
              ),
            ],
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.partidoTipo(
                partido.orden,
                partido.tipo == 'dobles'
                    ? context.l10n.dobles
                    : context.l10n.individual,
              ),
              style: tema.textTheme.labelLarge,
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(child: Text(quien(partido.local))),
                Expanded(
                  child: Text(
                    quien(partido.visitante),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              partido.sets.isEmpty
                  ? context.l10n.sinJugar
                  : partido.sets.map((s) => '${s[0]}-${s[1]}').join('   ·   '),
              style: tema.textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}
