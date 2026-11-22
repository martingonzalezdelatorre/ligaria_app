import 'package:flutter/material.dart';
import 'package:ligaria_ui/ligaria_ui.dart';
import 'ligas_repositorio.dart';
import 'marcador_repositorio.dart';
import 'tablero_marcador.dart';
import 'tanteo.dart';
import '../../../core/idioma.dart';

/// Vista en directo (solo lectura) del marcador que está publicando otro miembro del grupo.
class MarcadorPage extends StatelessWidget {
  const MarcadorPage({
    super.key,
    required this.local,
    required this.visitante,
    required this.deporte,
    this.amistosoId,
    this.partidoId,
  });
  final String local, visitante;
  final Deporte deporte;
  final String? amistosoId, partidoId;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(context.l10n.marcadorDeporte(deporte.etiqueta)),
      ),
      body: FondoBlobs(
        child: SafeArea(
          child: ContenidoCentrado(
            maxAncho: 680,
            child: StreamBuilder<Tanteo?>(
              stream: MarcadorRepositorio.instancia.ver(
                amistosoId: amistosoId,
                partidoId: partidoId,
              ),
              builder: (context, snap) {
                final tanteo = snap.data;
                return ListView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                  children: [
                    if (snap.connectionState == ConnectionState.waiting)
                      const Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (tanteo == null) ...[
                      const SizedBox(height: 24),
                      const Center(
                        child: MedallonVacio(icono: Icons.scoreboard_outlined),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        context.l10n.partidoNoJugando,
                        style: t.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        context.l10n.cuandoEmpieces,
                        style: t.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ] else ...[
                      TableroMarcador(
                        tanteo: tanteo,
                        local: local,
                        visitante: visitante,
                        enDirecto: true,
                      ),
                      const SizedBox(height: 14),
                      Text(
                        context.l10n.seActualizaSolo,
                        style: t.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
