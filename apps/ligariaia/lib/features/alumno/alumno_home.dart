import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/area_tabs.dart';
import 'ficha_tab.dart';
import 'liga_tab.dart';

/// Área alumno/familia: Liga (selector de mis ligas, mi equipo, calendario, resultados, clasificación) y Mi ficha.
class AlumnoHome extends ConsumerWidget {
  const AlumnoHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => const AreaTabs(secciones: [
        SeccionArea(Icons.emoji_events_outlined, 'Liga', LigaTab(), iconoActivo: Icons.emoji_events),
        SeccionArea(Icons.badge_outlined, 'Mi ficha', FichaTab(), iconoActivo: Icons.badge),
      ]);
}
