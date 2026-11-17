import 'package:flutter/material.dart';
import 'package:ligaria_ui/ligaria_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Estado de confirmación del resultado de un partido: lo confirman todos sus jugadores.
class Confirmacion {
  const Confirmacion({
    required this.total,
    required this.confirmados,
    required this.yoJuego,
    required this.yoConfirmado,
  });
  final int total, confirmados;
  final bool yoJuego, yoConfirmado;
  bool get completa => total > 0 && confirmados >= total;
  bool get puedoConfirmar => yoJuego && !yoConfirmado;
}

abstract class ConfirmacionRepositorio {
  /// Lo fija `main()`. Por defecto, en memoria (demo y tests).
  static ConfirmacionRepositorio instancia = ConfirmacionDemo();

  /// Confirmación de cada partido con resultado del grupo, por id de partido / amistoso.
  Future<Map<String, Confirmacion>> delGrupo(String? grupoId);

  Future<void> confirmar({String? amistosoId, String? partidoId});
}

class ConfirmacionSupabase implements ConfirmacionRepositorio {
  SupabaseClient get _c => Supabase.instance.client;

  @override
  Future<Map<String, Confirmacion>> delGrupo(String? grupoId) async {
    final base = _c.from('v_confirmaciones').select();
    final filas = await (grupoId == null
        ? base.filter('grupo_id', 'is', null)
        : base.eq('grupo_id', grupoId));
    return {
      for (final f in filas)
        f['ref_id'] as String: Confirmacion(
          total: (f['total'] as num).toInt(),
          confirmados: (f['confirmados'] as num).toInt(),
          yoJuego: f['yo_juego'] as bool,
          yoConfirmado: f['yo_confirmado'] as bool,
        ),
    };
  }

  @override
  Future<void> confirmar({String? amistosoId, String? partidoId}) async {
    await _c.rpc(
      'confirmar_resultado',
      params: {'p_amistoso': amistosoId, 'p_partido': partidoId},
    );
  }
}

/// En memoria: todo resultado nuevo es de un partido de 2 jugadores que ya confirmó el rival.
class ConfirmacionDemo implements ConfirmacionRepositorio {
  final _hechas = <String>{};

  @override
  Future<Map<String, Confirmacion>> delGrupo(String? grupoId) async => {};

  /// En la demo no hay filas que listar: se calcula por id.
  Confirmacion de(String id) => _hechas.contains(id)
      ? const Confirmacion(
          total: 2,
          confirmados: 2,
          yoJuego: true,
          yoConfirmado: true,
        )
      : const Confirmacion(
          total: 2,
          confirmados: 1,
          yoJuego: true,
          yoConfirmado: false,
        );

  @override
  Future<void> confirmar({String? amistosoId, String? partidoId}) async {
    _hechas.add((amistosoId ?? partidoId)!);
  }
}

/// Busca la confirmación de un partido; en demo la inventa a partir del id.
Confirmacion? confirmacionDe(Map<String, Confirmacion> m, String id) {
  final repo = ConfirmacionRepositorio.instancia;
  if (repo is ConfirmacionDemo) return repo.de(id);
  return m[id];
}

/// Etiqueta «Sin confirmar» / «Resultado confirmado» y, si te toca, el botón para confirmar.
class EstadoConfirmacion extends StatelessWidget {
  const EstadoConfirmacion({super.key, required this.c, this.onConfirmar});
  final Confirmacion c;
  final VoidCallback? onConfirmar;

  @override
  Widget build(BuildContext context) {
    final ok = c.completa;
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        ok
            ? const Insignia(
                'Resultado confirmado',
                color: Color(0xFF22C55E),
                icono: Icons.verified_rounded,
              )
            : Insignia(
                'Sin confirmar · ${c.confirmados}/${c.total}',
                color: const Color(0xFFF59E0B),
                icono: Icons.hourglass_top_rounded,
              ),
        if (!ok && c.puedoConfirmar && onConfirmar != null)
          TextButton.icon(
            onPressed: onConfirmar,
            icon: const Icon(Icons.check_rounded, size: 18),
            label: const Text('Confirmar'),
          ),
      ],
    );
  }
}
