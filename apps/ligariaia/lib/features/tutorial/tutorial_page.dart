import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/auth.dart';
import '../../core/idioma.dart';

class _Paso {
  const _Paso(this.icono, this.n);
  final IconData icono;
  final int n;

  String titulo(AppL10n l) => switch (n) {
    1 => l.tut1T,
    2 => l.tut2T,
    3 => l.tut3T,
    4 => l.tut4T,
    5 => l.tut5T,
    6 => l.tut6T,
    7 => l.tut7T,
    _ => l.tut8T,
  };
  String texto(AppL10n l) => switch (n) {
    1 => l.tut1D,
    2 => l.tut2D,
    3 => l.tut3D,
    4 => l.tut4D,
    5 => l.tut5D,
    6 => l.tut6D,
    7 => l.tut7D,
    _ => l.tut8D,
  };
}

const _comunes = [_Paso(Icons.sports_tennis, 1)];

const _porRol = <Rol, List<_Paso>>{
  Rol.alumno: [
    _Paso(Icons.leaderboard_outlined, 2),
    _Paso(Icons.lock_outline, 3),
  ],
  Rol.tutor: [_Paso(Icons.family_restroom, 4)],
  Rol.entrenador: [_Paso(Icons.edit_note, 5)],
  Rol.adminEscuela: [_Paso(Icons.school_outlined, 6)],
  Rol.organizadorLiga: [_Paso(Icons.emoji_events_outlined, 7)],
  Rol.superadmin: [_Paso(Icons.admin_panel_settings_outlined, 8)],
};

class TutorialPage extends ConsumerStatefulWidget {
  const TutorialPage({super.key});
  @override
  ConsumerState<TutorialPage> createState() => _TutorialPageState();
}

class _TutorialPageState extends ConsumerState<TutorialPage> {
  final _ctrl = PageController();
  int _i = 0;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final roles =
        ref.watch(pertenenciasProvider).value?.map((p) => p.rol).toSet() ??
        const <Rol>{};
    final pasos = [
      ..._comunes,
      for (final r in Rol.values.where(roles.contains)) ...?_porRol[r],
    ];
    final ultimo = _i == pasos.length - 1;
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.tutorial)),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _ctrl,
                onPageChanged: (i) => setState(() => _i = i),
                children: [
                  for (final p in pasos)
                    Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            p.icono,
                            size: 72,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: 24),
                          Text(
                            p.titulo(context.l10n),
                            style: Theme.of(context).textTheme.headlineSmall,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            p.texto(context.l10n),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var k = 0; k < pasos.length; k++)
                  Container(
                    margin: const EdgeInsets.all(4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: k == _i
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton(
                onPressed: () => ultimo
                    ? Navigator.of(context).maybePop()
                    : _ctrl.nextPage(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOut,
                      ),
                child: Text(
                  ultimo ? context.l10n.entendido : context.l10n.siguiente,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
