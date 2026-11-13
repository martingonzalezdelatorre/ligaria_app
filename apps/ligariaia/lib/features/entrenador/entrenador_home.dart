import 'package:flutter/material.dart';
import 'package:ligaria_ui/ligaria_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/widgets.dart';
import '../../data/models.dart';
import 'entrenador_providers.dart';
import 'resultado_form_page.dart';

/// Área entrenador: mis equipos, próxima jornada y formulario rápido de resultado.
class EntrenadorHome extends ConsumerWidget {
  const EntrenadorHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => const AreaTabs(secciones: [
        SeccionArea(Icons.groups_outlined, 'Mis equipos', _MisEquiposTab(), iconoActivo: Icons.groups),
        SeccionArea(Icons.event_outlined, 'Próxima jornada', _ProximaJornadaTab(), iconoActivo: Icons.event),
      ]);
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
          ? const EstadoVacio(icono: Icons.groups_outlined, texto: 'Aún no entrenas ningún equipo.')
          : RefreshIndicator(
              onRefresh: () async => ref.invalidate(equiposEntrenadorProvider),
              child: ListView(padding: const EdgeInsets.all(8), children: [
                for (final e in lista) _TarjetaEquipo(equipo: e),
              ]),
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
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(equipo.equipo, style: tema.textTheme.titleMedium),
          Text(equipo.escuela, style: tema.textTheme.bodySmall),
          const SizedBox(height: 4),
          Text(equipo.ligas.isEmpty ? 'Sin liga' : equipo.ligas.map((l) => l.nombre).join(' · '),
              style: tema.textTheme.bodyMedium?.copyWith(color: tema.colorScheme.primary)),
          const SizedBox(height: 12),
          Text('Plantilla', style: tema.textTheme.labelLarge),
          const SizedBox(height: 4),
          jugadores.when(
            loading: () => const LinearProgressIndicator(),
            error: (_, _) => const Text('No se pudo cargar la plantilla.'),
            data: (js) => js.isEmpty
                ? const Text('Sin jugadores todavía.')
                : Wrap(spacing: 6, runSpacing: 4, children: [for (final j in js) Chip(label: Text(j.nombreCompleto))]),
          ),
        ]),
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
          return const EstadoVacio(icono: Icons.event_outlined, texto: 'No hay encuentros de tus equipos todavía.');
        }
        final mios = ref.watch(equiposEntrenadorProvider).value?.map((e) => e.equipoId).toSet() ?? const <String>{};
        final siguiente = lista.where((e) => !e.confirmado).firstOrNull;
        Widget tarjeta(EncuentroVista e) => TarjetaEncuentro(
              encuentro: e,
              destacados: mios,
              trailing: e.confirmado ? null : const Padding(padding: EdgeInsets.only(left: 6), child: Icon(Icons.edit_note, size: 20)),
              onTap: () => _abrir(context, ref, e),
            );
        Widget etiqueta(String t) => Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(t, style: Theme.of(context).textTheme.labelLarge));
        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(proximaJornadaProvider),
          child: ListView(children: [
            if (siguiente != null) ...[etiqueta('Siguiente encuentro'), tarjeta(siguiente)],
            etiqueta('Calendario'),
            for (final e in lista.where((e) => e != siguiente)) tarjeta(e),
          ]),
        );
      },
    );
  }

  Future<void> _abrir(BuildContext context, WidgetRef ref, EncuentroVista e) async {
    if (e.confirmado) {
      avisar(context, 'Este resultado ya está registrado. Si hay un error, pide una corrección a la organización.');
      return;
    }
    final enviado = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => ResultadoFormPage(encuentro: e)),
    );
    if (enviado == true) {
      ref.invalidate(proximaJornadaProvider);
      if (context.mounted) avisar(context, 'Resultado guardado.');
    }
  }
}
