import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/auth.dart';

class _Paso {
  const _Paso(this.icono, this.titulo, this.texto);
  final IconData icono;
  final String titulo, texto;
}

const _comunes = [
  _Paso(Icons.sports_tennis, 'Bienvenido a Ligaria',
      'Aquí sigues las ligas entre escuelas: calendario, resultados y clasificación, desde el móvil.'),
];

const _porRol = <Rol, List<_Paso>>{
  Rol.alumno: [
    _Paso(Icons.leaderboard_outlined, 'Tu liga', 'Elige tu liga arriba para ver tu equipo, el calendario, los resultados y la clasificación.'),
    _Paso(Icons.lock_outline, 'Tu privacidad', 'Otras escuelas solo ven tu nombre y la inicial de tu apellido junto a los resultados. En «Mi ficha» ves tus datos.'),
  ],
  Rol.tutor: [
    _Paso(Icons.family_restroom, 'Familias', 'Desde «Mi ficha» consultas los datos de tu hijo o hija; en «Liga» sigues su equipo, calendario y resultados.'),
  ],
  Rol.entrenador: [
    _Paso(Icons.edit_note, 'Resultados en un minuto', 'En «Próxima jornada» abre el encuentro, marca quién ganó cada partido y guarda. Si hay un error, la organización puede corregirlo.'),
  ],
  Rol.adminEscuela: [
    _Paso(Icons.school_outlined, 'Tu escuela', 'Da de alta jugadores y tutores, crea equipos e inscríbelos en las ligas abiertas.'),
  ],
  Rol.organizadorLiga: [
    _Paso(Icons.emoji_events_outlined, 'Organizar una liga', 'Crea la liga, ábrela a la inscripción, genera el calendario y registra o corrige los resultados desde «Ver liga».'),
  ],
  Rol.superadmin: [
    _Paso(Icons.admin_panel_settings_outlined, 'Plataforma', 'Crea organizaciones (escuelas, ayuntamientos, grupos) y asígnales su administrador por correo.'),
  ],
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
    final roles = ref.watch(pertenenciasProvider).value?.map((p) => p.rol).toSet() ?? const <Rol>{};
    final pasos = [
      ..._comunes,
      for (final r in Rol.values.where(roles.contains)) ...?_porRol[r],
    ];
    final ultimo = _i == pasos.length - 1;
    return Scaffold(
      appBar: AppBar(title: const Text('Tutorial')),
      body: SafeArea(
        child: Column(children: [
          Expanded(
            child: PageView(
              controller: _ctrl,
              onPageChanged: (i) => setState(() => _i = i),
              children: [
                for (final p in pasos)
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(p.icono, size: 72, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(height: 24),
                      Text(p.titulo, style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      Text(p.texto, textAlign: TextAlign.center),
                    ]),
                  ),
              ],
            ),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            for (var k = 0; k < pasos.length; k++)
              Container(
                margin: const EdgeInsets.all(4), width: 8, height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: k == _i ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
          ]),
          Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton(
              onPressed: () => ultimo
                  ? Navigator.of(context).maybePop()
                  : _ctrl.nextPage(duration: const Duration(milliseconds: 250), curve: Curves.easeOut),
              child: Text(ultimo ? 'Entendido' : 'Siguiente'),
            ),
          ),
        ]),
      ),
    );
  }
}
