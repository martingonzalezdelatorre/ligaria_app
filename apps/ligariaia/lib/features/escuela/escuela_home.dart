import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/area_tabs.dart';
import 'equipos_tab.dart';
import '../organizador/ligas_tab.dart' as org;
import 'ligas_tab.dart';
import 'personas_tab.dart';
import 'usuarios_tab.dart';

/// Área admin de escuela: usuarios, jugadores y tutores, equipos, inscripción en ligas y creación de ligas propias.
class EscuelaHome extends ConsumerWidget {
  const EscuelaHome({super.key, required this.escuelaId, required this.escuelaNombre, this.orgTipo});
  final String escuelaId;
  final String escuelaNombre;
  final String? orgTipo;

  @override
  Widget build(BuildContext context, WidgetRef ref) => AreaTabs(secciones: [
        SeccionArea(Icons.manage_accounts_outlined, 'Usuarios', UsuariosTab(escuelaId: escuelaId), iconoActivo: Icons.manage_accounts),
        SeccionArea(Icons.people_outline, 'Jugadores y tutores', PersonasTab(escuelaId: escuelaId), iconoActivo: Icons.people),
        SeccionArea(Icons.groups_outlined, 'Equipos', EquiposTab(escuelaId: escuelaId), iconoActivo: Icons.groups),
        SeccionArea(Icons.emoji_events_outlined, 'Ligas', LigasTab(escuelaId: escuelaId), iconoActivo: Icons.emoji_events),
        SeccionArea(Icons.add_chart_outlined, 'Mis ligas', org.LigasTab(escuelaId: escuelaId, orgTipo: orgTipo ?? 'ESCUELA'), iconoActivo: Icons.add_chart),
      ]);
}
