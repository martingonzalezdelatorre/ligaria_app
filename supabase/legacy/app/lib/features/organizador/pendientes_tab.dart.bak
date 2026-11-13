import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/widgets.dart';
import '../../data/models.dart';
import 'organizador_providers.dart';
import 'resultado_page.dart';

/// Resultados propuestos por los entrenadores a la espera de confirmación.
class PendientesTab extends ConsumerWidget {
  const PendientesTab({super.key, required this.escuelaId});
  final String escuelaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AsyncView<List<EncuentroVista>>(
      value: ref.watch(orgPendientesProvider(escuelaId)),
      onRetry: () => ref.invalidate(orgPendientesProvider(escuelaId)),
      builder: (lista) => lista.isEmpty
          ? const EstadoVacio(icono: Icons.task_alt, texto: 'No hay resultados pendientes de confirmar.')
          : RefreshIndicator(
              onRefresh: () => ref.refresh(orgPendientesProvider(escuelaId).future),
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  for (final e in lista)
                    TarjetaEncuentro(
                      encuentro: e,
                      onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => ResultadoPage(escuelaId: escuelaId, encuentro: e))),
                    ),
                ],
              ),
            ),
    );
  }
}
