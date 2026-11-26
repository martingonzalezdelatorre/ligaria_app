import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/idioma.dart';
import '../../data/liga_repository.dart';
import 'escuela_providers.dart';

/// ¿Ha inscrito la organización algún equipo en una liga? (paso 4 de «Primeros pasos»)
final inscripcionesOrgProvider = FutureProvider.family<bool, String>(
  (ref, orgId) => ref.watch(ligaRepositoryProvider).tieneInscripciones(orgId),
);

/// ¿Se ha invitado a algún entrenador? (paso 3: cuenta también la invitación aún sin aceptar)
final entrenadorInvitadoProvider = FutureProvider.family<bool, String>(
  (ref, orgId) =>
      ref.watch(ligaRepositoryProvider).tieneInvitacionEntrenador(orgId),
);

/// Posición de cada pestaña de EscuelaHome a la que lleva cada paso.
class PestanasEscuela {
  static const usuarios = 0, personas = 1, equipos = 2, ligas = 3;
}

/// Un paso de una guía: se marca solo cuando [hecho] y, al tocarlo, lleva a donde se completa.
class PasoGuia {
  const PasoGuia({
    required this.clave,
    required this.hecho,
    required this.titulo,
    required this.detalle,
    required this.alTocar,
  });
  final String clave;
  final bool hecho;
  final String titulo, detalle;
  final VoidCallback alTocar;
}

/// Tarjeta de «Primeros pasos»: lista de pasos con barra de progreso. Empieza abierta si no hay
/// ningún paso hecho y plegada si ya hay progreso; se puede plegar y ocultar (se recuerda en el
/// dispositivo con [preferencia]) y desaparece sola cuando todo está hecho.
class TarjetaPasos extends StatefulWidget {
  const TarjetaPasos({
    super.key,
    required this.preferencia,
    required this.pasos,
  });

  /// Clave de las preferencias donde se guarda que la persona ocultó la guía.
  final String preferencia;
  final List<PasoGuia> pasos;

  @override
  State<TarjetaPasos> createState() => _TarjetaPasosState();
}

class _TarjetaPasosState extends State<TarjetaPasos> {
  bool? _oculto; // null mientras se lee la preferencia
  bool? _abierto; // null: lo decide el progreso

  @override
  void initState() {
    super.initState();
    _leerPreferencia();
  }

  Future<void> _leerPreferencia() async {
    var oculto = false;
    try {
      oculto =
          (await SharedPreferences.getInstance()).getBool(widget.preferencia) ??
          false;
    } catch (_) {}
    if (mounted) setState(() => _oculto = oculto);
  }

  Future<void> _ocultar() async {
    setState(() => _oculto = true);
    try {
      await (await SharedPreferences.getInstance()).setBool(
        widget.preferencia,
        true,
      );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (_oculto != false) return const SizedBox.shrink();
    final pasos = widget.pasos;
    final hechos = pasos.where((p) => p.hecho).length;
    if (hechos == pasos.length) return const SizedBox.shrink();

    final l = context.l10n;
    final tema = Theme.of(context);
    final abierto = _abierto ?? hechos == 0;
    return Card(
      key: const Key('primeros-pasos'),
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            key: const Key('primeros-pasos-cabecera'),
            onTap: () => setState(() => _abierto = !abierto),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 4, 8),
              child: Row(
                children: [
                  Icon(
                    Icons.rocket_launch_outlined,
                    color: tema.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l.pasosTitulo, style: tema.textTheme.titleSmall),
                        Text(
                          l.pasosProgreso(hechos, pasos.length),
                          style: tema.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Icon(abierto ? Icons.expand_less : Icons.expand_more),
                  IconButton(
                    key: const Key('primeros-pasos-ocultar'),
                    tooltip: l.pasosOcultar,
                    icon: const Icon(Icons.close),
                    onPressed: _ocultar,
                  ),
                ],
              ),
            ),
          ),
          LinearProgressIndicator(value: hechos / pasos.length, minHeight: 3),
          if (abierto)
            for (var i = 0; i < pasos.length; i++)
              ListTile(
                key: Key('paso-${pasos[i].clave}'),
                dense: true,
                leading: Icon(
                  pasos[i].hecho
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: pasos[i].hecho
                      ? tema.colorScheme.primary
                      : tema.colorScheme.outline,
                ),
                title: Text(
                  '${i + 1}. ${pasos[i].titulo}',
                  style: pasos[i].hecho
                      ? TextStyle(
                          decoration: TextDecoration.lineThrough,
                          color: tema.colorScheme.outline,
                        )
                      : null,
                ),
                subtitle: pasos[i].hecho ? null : Text(pasos[i].detalle),
                trailing: pasos[i].hecho
                    ? null
                    : const Icon(Icons.chevron_right),
                onTap: pasos[i].alTocar,
              ),
        ],
      ),
    );
  }
}

/// Guía de arranque para el administrador de una escuela nueva: cuatro pasos fijos que se
/// marcan solos al completarlos. Cada paso lleva a su pestaña.
class PrimerosPasos extends ConsumerWidget {
  const PrimerosPasos({super.key, required this.escuelaId, required this.irA});
  final String escuelaId;
  final ValueChanged<int> irA;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = escuelaId;
    final jugadores = ref.watch(jugadoresOrgProvider(id));
    final equipos = ref.watch(equiposEscuelaProvider(id));
    final usuarios = ref.watch(usuariosEscuelaProvider(id));
    final inscripciones = ref.watch(inscripcionesOrgProvider(id));
    final entrenadorInvitado = ref.watch(entrenadorInvitadoProvider(id));
    // Sin los tres primeros datos no se muestra nada: una guía a medias confundiría más que ayudaría.
    // Si falla alguna de las dos consultas de apoyo (invitaciones, inscripciones) el paso queda pendiente.
    if (jugadores.value == null ||
        equipos.value == null ||
        usuarios.value == null) {
      return const SizedBox.shrink();
    }
    final l = context.l10n;
    return TarjetaPasos(
      preferencia: 'primeros_pasos_oculto_$id',
      pasos: [
        PasoGuia(
          clave: 'jugadores',
          hecho: jugadores.value!.isNotEmpty,
          titulo: l.paso1T,
          detalle: l.paso1D,
          alTocar: () => irA(PestanasEscuela.personas),
        ),
        PasoGuia(
          clave: 'equipos',
          hecho: equipos.value!.isNotEmpty,
          titulo: l.paso2T,
          detalle: l.paso2D,
          alTocar: () => irA(PestanasEscuela.equipos),
        ),
        PasoGuia(
          clave: 'entrenador',
          hecho:
              usuarios.value!.any((u) => u.rol == 'ENTRENADOR') ||
              (entrenadorInvitado.value ?? false),
          titulo: l.paso3T,
          detalle: l.paso3D,
          alTocar: () => irA(PestanasEscuela.usuarios),
        ),
        PasoGuia(
          clave: 'liga',
          hecho: inscripciones.value ?? false,
          titulo: l.paso4T,
          detalle: l.paso4D,
          alTocar: () => irA(PestanasEscuela.ligas),
        ),
      ],
    );
  }
}
