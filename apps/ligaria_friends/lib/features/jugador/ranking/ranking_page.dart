import 'package:flutter/material.dart';
import 'package:ligaria_ui/ligaria_ui.dart';
import 'ranking_repositorio.dart';

/// Ranking global: jugadores ordenados por partidos ganados / partidos jugados.
class RankingPage extends StatefulWidget {
  const RankingPage({super.key, this.repo});
  final RankingRepositorio? repo;
  @override
  State<RankingPage> createState() => _RankingPageState();
}

class _RankingPageState extends State<RankingPage> {
  late final RankingRepositorio _repo =
      widget.repo ?? RankingRepositorio.instancia;
  late Future<List<PuestoRanking>> _futuro = _repo.ranking();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return FutureBuilder<List<PuestoRanking>>(
      future: _futuro,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return EstadoVacio(
            icono: Icons.error_outline,
            texto: '${snap.error}',
          );
        }
        final lista = snap.data!;
        return RefreshIndicator(
          onRefresh: () async {
            setState(() => _futuro = _repo.ranking());
            await _futuro;
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 40),
            children: [
              Text(
                'Ranking',
                style: t.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Clasificación global: 10 puntos por partido ganado.',
                style: t.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 20),
              if (lista.isEmpty)
                const EstadoVacio(
                  icono: Icons.emoji_events_outlined,
                  texto: 'Aún no hay partidos jugados.',
                )
              else
                for (var i = 0; i < lista.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Aparece(
                      retardo: 40 * (i < 10 ? i : 10),
                      child: _FilaRanking(puesto: i + 1, datos: lista[i]),
                    ),
                  ),
            ],
          ),
        );
      },
    );
  }
}

class _FilaRanking extends StatelessWidget {
  const _FilaRanking({required this.puesto, required this.datos});
  final int puesto;
  final PuestoRanking datos;

  static const _medallas = [
    Color(0xFFD4AF37), // oro
    Color(0xFF9AA0A6), // plata
    Color(0xFFB87333), // bronce
  ];

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final medalla = puesto <= 3 ? _medallas[puesto - 1] : null;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            SizedBox(
              width: 36,
              child: medalla != null
                  ? Icon(Icons.emoji_events, color: medalla)
                  : Text(
                      '$puesto',
                      textAlign: TextAlign.center,
                      style: t.titleMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    datos.nombre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    '${datos.ganados} ganados de ${datos.jugados} jugados',
                    style: t.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${datos.puntos} pts',
                  style: t.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: cs.primary,
                  ),
                ),
                Text(
                  '${(datos.puntaje * 100).round()}%',
                  style: t.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
