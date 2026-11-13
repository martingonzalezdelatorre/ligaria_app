import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/area_tabs.dart';
import 'ligas_sa_tab.dart';
import 'organizaciones_tab.dart';

/// Área del administrador de la plataforma: organizaciones (escuelas, ayuntamientos, grupos) y ligas.
class SuperadminHome extends ConsumerWidget {
  const SuperadminHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => const AreaTabs(secciones: [
        SeccionArea(Icons.apartment_outlined, 'Organizaciones', OrganizacionesTab(), iconoActivo: Icons.apartment),
        SeccionArea(Icons.emoji_events_outlined, 'Ligas', LigasSaTab(), iconoActivo: Icons.emoji_events),
      ]);
}
