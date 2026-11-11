import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/area_tabs.dart';
import 'escuelas_tab.dart';
import 'ligas_sa_tab.dart';
import 'registro_tab.dart';
import 'temporadas_tab.dart';

/// Área superadmin: escuelas, temporadas, ligas, registro de cambios.
class SuperadminHome extends ConsumerWidget {
  const SuperadminHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => const AreaTabs(secciones: [
        SeccionArea(Icons.school_outlined, 'Escuelas', EscuelasTab(), iconoActivo: Icons.school),
        SeccionArea(Icons.date_range_outlined, 'Temporadas', TemporadasTab(), iconoActivo: Icons.date_range),
        SeccionArea(Icons.emoji_events_outlined, 'Ligas', LigasSaTab(), iconoActivo: Icons.emoji_events),
        SeccionArea(Icons.history, 'Registro', RegistroTab()),
      ]);
}
