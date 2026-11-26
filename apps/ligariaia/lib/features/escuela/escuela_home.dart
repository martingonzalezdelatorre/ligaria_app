import '../../core/idioma.dart';
import 'package:flutter/material.dart';
import 'package:ligaria_ui/ligaria_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'equipos_tab.dart';
import '../organizador/ligas_tab.dart' as org;
import 'ligas_tab.dart';
import 'personas_tab.dart';
import 'primeros_pasos.dart';
import 'usuarios_tab.dart';

/// Área admin de escuela: usuarios, jugadores y tutores, equipos, inscripción en ligas y creación de ligas propias.
/// Mientras la escuela es nueva, arriba aparece la guía «Primeros pasos».
class EscuelaHome extends ConsumerStatefulWidget {
  const EscuelaHome({
    super.key,
    required this.escuelaId,
    required this.escuelaNombre,
    this.orgTipo,
  });
  final String escuelaId;
  final String escuelaNombre;
  final String? orgTipo;

  @override
  ConsumerState<EscuelaHome> createState() => _EscuelaHomeState();
}

class _EscuelaHomeState extends ConsumerState<EscuelaHome> {
  final _pestana = ValueNotifier<int>(0);

  @override
  void dispose() {
    _pestana.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final escuelaId = widget.escuelaId;
    return Column(
      children: [
        PrimerosPasos(escuelaId: escuelaId, irA: (i) => _pestana.value = i),
        Expanded(
          child: AreaTabs(
            seleccion: _pestana,
            secciones: [
              SeccionArea(
                Icons.manage_accounts_outlined,
                context.l10n.tabUsuarios,
                UsuariosTab(escuelaId: escuelaId),
                iconoActivo: Icons.manage_accounts,
              ),
              SeccionArea(
                Icons.people_outline,
                context.l10n.tabJugadoresTutores,
                PersonasTab(escuelaId: escuelaId),
                iconoActivo: Icons.people,
              ),
              SeccionArea(
                Icons.groups_outlined,
                context.l10n.tabEquipos,
                EquiposTab(escuelaId: escuelaId),
                iconoActivo: Icons.groups,
              ),
              SeccionArea(
                Icons.emoji_events_outlined,
                context.l10n.tabInscribirme,
                LigasTab(escuelaId: escuelaId),
                iconoActivo: Icons.emoji_events,
              ),
              SeccionArea(
                Icons.add_chart_outlined,
                context.l10n.tabLigasOrganizo,
                org.LigasTab(
                  escuelaId: escuelaId,
                  orgTipo: widget.orgTipo ?? 'ESCUELA',
                ),
                iconoActivo: Icons.add_chart,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
