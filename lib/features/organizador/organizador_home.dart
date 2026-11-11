import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/area_tabs.dart';
import 'correcciones_tab.dart';
import 'ligas_tab.dart';
import 'pendientes_tab.dart';

/// Área organizador: crear liga y reglas, generar calendario, resultados pendientes, correcciones.
class OrganizadorHome extends ConsumerWidget {
  const OrganizadorHome({super.key, required this.escuelaId, required this.escuelaNombre});
  final String escuelaId;
  final String escuelaNombre;

  @override
  Widget build(BuildContext context, WidgetRef ref) => AreaTabs(secciones: [
        SeccionArea(Icons.emoji_events_outlined, 'Ligas', LigasTab(escuelaId: escuelaId), iconoActivo: Icons.emoji_events),
        SeccionArea(Icons.pending_actions_outlined, 'Pendientes', PendientesTab(escuelaId: escuelaId), iconoActivo: Icons.pending_actions),
        SeccionArea(Icons.edit_note_outlined, 'Correcciones', CorreccionesTab(escuelaId: escuelaId), iconoActivo: Icons.edit_note),
      ]);
}
