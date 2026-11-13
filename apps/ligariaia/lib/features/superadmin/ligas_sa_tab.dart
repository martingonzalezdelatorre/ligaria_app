import 'package:flutter/material.dart';
import 'package:ligaria_ui/ligaria_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/widgets.dart';
import '../../data/models.dart';
import 'superadmin_providers.dart';

/// Todas las ligas de la plataforma (el superadmin las ve todas por RLS).
class LigasSaTab extends ConsumerWidget {
  const LigasSaTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AsyncView<List<Liga>>(
      value: ref.watch(saLigasProvider),
      onRetry: () => ref.invalidate(saLigasProvider),
      builder: (lista) => lista.isEmpty
          ? const EstadoVacio(icono: Icons.emoji_events_outlined, texto: 'Todavía no hay ligas.')
          : RefreshIndicator(
              onRefresh: () => ref.refresh(saLigasProvider.future),
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  for (final l in lista)
                    ListTile(
                      leading: const Icon(Icons.emoji_events_outlined),
                      title: Text(l.nombre),
                      subtitle: Text('${l.deporte ?? 'Liga'} · ${etiquetaEstadoLiga(l.estado)}'),
                    ),
                ],
              ),
            ),
    );
  }
}
