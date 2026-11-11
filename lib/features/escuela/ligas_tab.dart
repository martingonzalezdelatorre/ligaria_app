import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/widgets.dart';
import '../../data/liga_repository.dart';
import '../../data/models.dart';
import 'escuela_providers.dart';

/// Ligas abiertas a inscripción: inscribir uno de mis equipos del mismo deporte.
class LigasTab extends ConsumerWidget {
  const LigasTab({super.key, required this.escuelaId});
  final String escuelaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final datos = ref.watch(ligasAbiertasProvider);
    return AsyncView<List<LigaAbierta>>(
      value: datos,
      onRetry: () => ref.invalidate(ligasAbiertasProvider),
      builder: (lista) => lista.isEmpty
          ? const EstadoVacio(icono: Icons.emoji_events_outlined, texto: 'No hay ligas abiertas a inscripción ahora mismo.')
          : RefreshIndicator(
              onRefresh: () async => ref.invalidate(ligasAbiertasProvider),
              child: ListView(padding: const EdgeInsets.all(8), children: [
                for (final l in lista)
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.emoji_events_outlined),
                      title: Text(l.nombre),
                      subtitle: Text('${l.deporte} · organiza ${l.organizadora}'),
                      trailing: FilledButton.tonal(
                        key: Key('inscribir-${l.id}'),
                        onPressed: () => _inscribir(context, ref, l),
                        child: const Text('Inscribir'),
                      ),
                    ),
                  ),
              ]),
            ),
    );
  }

  Future<void> _inscribir(BuildContext context, WidgetRef ref, LigaAbierta liga) async {
    final repo = ref.read(ligaRepositoryProvider);
    try {
      final equipos = await ref.read(equiposEscuelaProvider(escuelaId).future);
      final validos = equipos.where((e) => e.deporteId == liga.deporteId).toList();
      if (!context.mounted) return;
      final id = await showDialog<String>(
        context: context,
        builder: (_) => SimpleDialog(
          title: Text('Inscribir en ${liga.nombre}'),
          children: validos.isEmpty
              ? [Padding(padding: const EdgeInsets.all(24), child: Text('No tienes equipos de ${liga.deporte}. Crea uno en «Equipos».'))]
              : [for (final e in validos) SimpleDialogOption(onPressed: () => Navigator.of(context).pop(e.id), child: Text(e.nombre))],
        ),
      );
      if (id == null) return;
      await repo.inscribirEquipo(liga.id, id, escuelaId);
      if (context.mounted) avisar(context, 'Equipo inscrito en ${liga.nombre}.');
    } catch (e) {
      if (context.mounted) avisar(context, mensajeErrorEscuela(e));
    }
  }
}
