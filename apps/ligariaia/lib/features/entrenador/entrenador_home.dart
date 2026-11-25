import '../../core/idioma.dart';
import 'package:flutter/material.dart';
import 'package:ligaria_ui/ligaria_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/widgets.dart';
import '../../data/models.dart';
import 'entrenador_providers.dart';
import 'entrenos_tab.dart';
import 'resultado_form_page.dart';

/// Área entrenador: mis equipos, próxima jornada y formulario rápido de resultado.
class EntrenadorHome extends ConsumerWidget {
  const EntrenadorHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => AreaTabs(
    secciones: [
      SeccionArea(
        Icons.groups_outlined,
        context.l10n.tabMisEquipos,
        const _MisEquiposTab(),
        iconoActivo: Icons.groups,
      ),
      SeccionArea(
        Icons.event_outlined,
        context.l10n.tabProximaJornada,
        const _ProximaJornadaTab(),
        iconoActivo: Icons.event,
      ),
      SeccionArea(
        Icons.fitness_center_outlined,
        context.l10n.tabEntrenos,
        const EntrenosTab(),
        iconoActivo: Icons.fitness_center,
      ),
    ],
  );
}

class _MisEquiposTab extends ConsumerWidget {
  const _MisEquiposTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final equipos = ref.watch(equiposEntrenadorProvider);
    return AsyncView<List<EquipoEntrenado>>(
      value: equipos,
      onRetry: () => ref.invalidate(equiposEntrenadorProvider),
      builder: (lista) => lista.isEmpty
          ? EstadoVacio(
              icono: Icons.groups_outlined,
              texto: context.l10n.sinEntrenar,
            )
          : RefreshIndicator(
              onRefresh: () async => ref.invalidate(equiposEntrenadorProvider),
              child: ListView(
                padding: const EdgeInsets.all(8),
                children: [for (final e in lista) _TarjetaEquipo(equipo: e)],
              ),
            ),
    );
  }
}

class _TarjetaEquipo extends ConsumerWidget {
  const _TarjetaEquipo({required this.equipo});
  final EquipoEntrenado equipo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tema = Theme.of(context);
    final jugadores = ref.watch(jugadoresDeEquipoProvider(equipo.equipoId));
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(equipo.equipo, style: tema.textTheme.titleMedium),
            Text(equipo.escuela, style: tema.textTheme.bodySmall),
            const SizedBox(height: 4),
            Text(
              equipo.ligas.isEmpty
                  ? context.l10n.sinLiga
                  : equipo.ligas.map((l) => l.nombre).join(' · '),
              style: tema.textTheme.bodyMedium?.copyWith(
                color: tema.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            Text(context.l10n.plantilla, style: tema.textTheme.labelLarge),
            const SizedBox(height: 4),
            jugadores.when(
              loading: () => const LinearProgressIndicator(),
              error: (_, _) => Text(context.l10n.errPlantilla),
              data: (js) => js.isEmpty
                  ? Text(context.l10n.sinJugadoresTodavia)
                  : Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        for (final j in js) Chip(label: Text(j.nombreCompleto)),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProximaJornadaTab extends ConsumerWidget {
  const _ProximaJornadaTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final datos = ref.watch(proximaJornadaProvider);
    return AsyncView<List<EncuentroVista>>(
      value: datos,
      onRetry: () => ref.invalidate(proximaJornadaProvider),
      builder: (lista) {
        if (lista.isEmpty) {
          return EstadoVacio(
            icono: Icons.event_outlined,
            texto: context.l10n.sinEncuentros,
          );
        }
        final mios =
            ref
                .watch(equiposEntrenadorProvider)
                .value
                ?.map((e) => e.equipoId)
                .toSet() ??
            const <String>{};
        final siguiente = lista.where((e) => !e.confirmado).firstOrNull;
        Widget tarjeta(EncuentroVista e) => TarjetaEncuentro(
          encuentro: e,
          destacados: mios,
          trailing: e.confirmado
              ? null
              : const Padding(
                  padding: EdgeInsets.only(left: 6),
                  child: Icon(Icons.edit_note, size: 20),
                ),
          onTap: () => _abrir(context, ref, e),
        );
        Widget etiqueta(String t) => Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Text(t, style: Theme.of(context).textTheme.labelLarge),
        );
        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(proximaJornadaProvider),
          child: ListView(
            children: [
              if (siguiente != null) ...[
                etiqueta(context.l10n.siguienteEncuentro),
                tarjeta(siguiente),
              ],
              etiqueta(context.l10n.tabCalendario),
              for (final e in lista.where((e) => e != siguiente)) tarjeta(e),
            ],
          ),
        );
      },
    );
  }

  Future<void> _abrir(
    BuildContext context,
    WidgetRef ref,
    EncuentroVista e,
  ) async {
    if (e.confirmado) {
      avisar(context, context.l10n.yaRegistrado);
      return;
    }
    final enviado = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => ResultadoFormPage(encuentro: e)),
    );
    if (enviado == true) {
      ref.invalidate(proximaJornadaProvider);
      if (context.mounted) avisar(context, context.l10n.resultadoGuardado);
    }
  }
}
