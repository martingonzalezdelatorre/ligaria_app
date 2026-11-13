import 'package:flutter/material.dart';
import 'package:ligaria_ui/ligaria_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/widgets.dart';
import '../../data/models.dart';
import 'organizador_providers.dart';
import 'resultado_page.dart';

/// Calendario y clasificación de una liga organizada.
class LigaDetallePage extends ConsumerWidget {
  const LigaDetallePage({super.key, required this.liga, required this.escuelaId});
  final Liga liga;
  final String escuelaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(liga.nombre),
          bottom: const TabBar(tabs: [Tab(text: 'Calendario'), Tab(text: 'Clasificación')]),
        ),
        body: TabBarView(children: [
          AsyncView<List<EncuentroVista>>(
            value: ref.watch(orgEncuentrosProvider(liga.id)),
            onRetry: () => ref.invalidate(orgEncuentrosProvider(liga.id)),
            builder: (encs) {
              if (encs.isEmpty) {
                return const EstadoVacio(icono: Icons.event_busy_outlined, texto: 'Aún no hay calendario.\nGénéralo desde la lista de ligas.');
              }
              final porJornada = <int, List<EncuentroVista>>{};
              for (final e in encs) {
                porJornada.putIfAbsent(e.jornada, () => []).add(e);
              }
              return ListView(
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  for (final j in porJornada.keys.toList()..sort()) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                      child: Text('Jornada $j · ${fechaCorta(porJornada[j]!.first.fecha)}',
                          style: Theme.of(context).textTheme.titleSmall),
                    ),
                    for (final e in porJornada[j]!)
                      TarjetaEncuentro(
                        encuentro: e,
                        onTap: () => Navigator.of(context)
                            .push(MaterialPageRoute(builder: (_) => ResultadoPage(escuelaId: escuelaId, encuentro: e))),
                      ),
                  ],
                ],
              );
            },
          ),
          AsyncView<List<FilaClasificacion>>(
            value: ref.watch(orgClasificacionProvider(liga.id)),
            onRetry: () => ref.invalidate(orgClasificacionProvider(liga.id)),
            builder: (filas) => filas.isEmpty
                ? const EstadoVacio(icono: Icons.leaderboard_outlined, texto: 'Todavía no hay equipos inscritos.')
                : SingleChildScrollView(child: TablaClasificacion(filas: filas)),
          ),
        ]),
      ),
    );
  }
}
