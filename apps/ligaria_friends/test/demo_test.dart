import 'package:flutter_test/flutter_test.dart';
import 'package:ligaria_friends/features/jugador/amistosos/amistosos_repositorio.dart';
import 'package:ligaria_friends/features/jugador/grupos/grupos_repositorio.dart';
import 'package:ligaria_friends/main.dart';

void main() {
  test('modo demo: un grupo con un amistoso jugado y otro sin grupo', () async {
    final grupos = GruposDemo();
    final amistosos = AmistososDemo(grupos);
    await sembrarDemo(grupos, amistosos);

    final g = (await grupos.misGrupos()).single;
    final delGrupo = await amistosos.amistosos(g.id);
    final sinGrupo = await amistosos.amistosos(null);
    expect(delGrupo.single.jugado, isTrue);
    expect(sinGrupo.single.grupoId, isNull);
    expect(sinGrupo.single.visitante, 'Amigo externo');
  });

  test('desde cero: sin grupos ni amistosos', () async {
    final grupos = GruposDemo();
    final amistosos = AmistososDemo(grupos);
    expect(await grupos.misGrupos(), isEmpty);
    expect(await amistosos.amistosos(null), isEmpty);
  });
}
