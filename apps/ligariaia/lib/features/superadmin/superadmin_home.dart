import '../../core/idioma.dart';
import 'package:flutter/material.dart';
import 'package:ligaria_ui/ligaria_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ligas_sa_tab.dart';
import 'organizaciones_tab.dart';

/// Área del administrador de la plataforma: organizaciones (escuelas, ayuntamientos, grupos) y ligas.
class SuperadminHome extends ConsumerWidget {
  const SuperadminHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => AreaTabs(
    secciones: [
      SeccionArea(
        Icons.apartment_outlined,
        context.l10n.tabOrganizaciones,
        const OrganizacionesTab(),
        iconoActivo: Icons.apartment,
      ),
      SeccionArea(
        Icons.emoji_events_outlined,
        context.l10n.tabLigas,
        const LigasSaTab(),
        iconoActivo: Icons.emoji_events,
      ),
    ],
  );
}
