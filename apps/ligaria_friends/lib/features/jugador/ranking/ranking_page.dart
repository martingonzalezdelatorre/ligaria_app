import 'package:flutter/material.dart';
import 'package:ligaria_ui/ligaria_ui.dart';
import '../ajustes/ajustes_page.dart';
import '../ajustes/ajustes_repositorio.dart';
import '../grupos/grupos_repositorio.dart';
import 'ranking_repositorio.dart';

enum _Vista {
  global('Global', Icons.public, Preferencia.rankingGlobal),
  provincia('Provincia', Icons.map_outlined, Preferencia.rankingProvincia),
  localidad(
    'Localidad',
    Icons.location_city_outlined,
    Preferencia.rankingLocalidad,
  ),
  grupo('Mis grupos', Icons.groups_outlined, null);

  const _Vista(this.etiqueta, this.icono, this.preferencia);
  final String etiqueta;
  final IconData icono;

  /// Ajuste que hay que activar para aparecer en ese ranking (`null`: siempre).
  final Preferencia? preferencia;
}

/// Rankings: global, de tu provincia, de tu localidad y de cada grupo de amigos.
class RankingPage extends StatefulWidget {
  const RankingPage({super.key, this.repo, this.grupos});
  final RankingRepositorio? repo;

  /// Para elegir el grupo en la vista «Mis grupos».
  final GruposRepositorio? grupos;
  @override
  State<RankingPage> createState() => _RankingPageState();
}

class _RankingPageState extends State<RankingPage> {
  late final RankingRepositorio _repo =
      widget.repo ?? RankingRepositorio.instancia;
  _Vista _vista = _Vista.global;
  Future<List<Grupo>> _grupos = Future.value(const []);
  Grupo? _grupo;
  late Future<List<PuestoRanking>> _futuro = _repo.ranking();
  Future<PerfilUsuario?> _perfil = _cargarPerfil();

  static Future<PerfilUsuario?> _cargarPerfil() => AjustesRepositorio.instancia
      .perfil()
      .then<PerfilUsuario?>((p) => p)
      .catchError((_) => null);

  @override
  void initState() {
    super.initState();
    if (widget.grupos != null) _grupos = widget.grupos!.misGrupos();
  }

  void _cargar() {
    // Los ajustes pueden haber cambiado desde el engranaje de la barra superior.
    _perfil = _cargarPerfil();
    _futuro = switch (_vista) {
      _Vista.global => _repo.ranking(),
      _Vista.provincia => _repo.rankingProvincia(),
      _Vista.localidad => _repo.rankingLocalidad(),
      _Vista.grupo =>
        _grupo == null
            ? Future.value(const [])
            : _repo.rankingGrupo(_grupo!.id),
    };
  }

  Future<void> _ajustes() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const AjustesPage()));
    if (mounted) setState(_cargar);
  }

  String _descripcion() => switch (_vista) {
    _Vista.global => 'Clasificación global de la app',
    _Vista.provincia => 'Clasificación de tu provincia',
    _Vista.localidad => 'Clasificación de tu localidad',
    _Vista.grupo => 'Clasificación de tu grupo',
  };

  /// Aviso cuando el usuario no aparece en el ranking o falta su ubicación.
  Widget _aviso(PerfilUsuario? p) {
    if (p == null || _vista == _Vista.grupo) return const SizedBox.shrink();
    String? titulo, detalle;
    if (_vista == _Vista.provincia && !p.tieneProvincia) {
      titulo = 'Indica tu provincia';
      detalle = 'Complétala en Ajustes de cuenta para ver este ranking.';
    } else if (_vista == _Vista.localidad && !p.tieneLocalidad) {
      titulo = 'Indica tu localidad';
      detalle = 'Complétala en Ajustes de cuenta para ver este ranking.';
    } else if (!p.valorDe(_vista.preferencia!)) {
      titulo = 'No apareces en este ranking';
      detalle = 'Únete desde Ajustes de cuenta para competir.';
    }
    if (titulo == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Card(
        margin: EdgeInsets.zero,
        child: ListTile(
          leading: const Icon(Icons.info_outline),
          title: Text(titulo),
          subtitle: Text(detalle!),
          trailing: TextButton(
            onPressed: _ajustes,
            child: const Text('Ajustes'),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return FutureBuilder<List<Grupo>>(
      future: _grupos,
      builder: (context, gs) {
        final grupos = gs.data ?? const <Grupo>[];
        return RefreshIndicator(
          onRefresh: () async {
            setState(_cargar);
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
                '${_descripcion()}: 10 puntos por partido ganado.',
                style: t.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final v in _Vista.values)
                    ChoiceChip(
                      avatar: Icon(v.icono, size: 18),
                      label: Text(v.etiqueta),
                      selected: _vista == v,
                      onSelected: (_) => setState(() {
                        _vista = v;
                        if (v == _Vista.grupo && grupos.isNotEmpty) {
                          _grupo ??= grupos.first;
                        }
                        _cargar();
                      }),
                    ),
                ],
              ),
              if (_vista == _Vista.grupo && grupos.length > 1) ...[
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: _grupo?.id,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Grupo'),
                  items: [
                    for (final g in grupos)
                      DropdownMenuItem(value: g.id, child: Text(g.nombre)),
                  ],
                  onChanged: (id) => setState(() {
                    _grupo = grupos.firstWhere((g) => g.id == id);
                    _cargar();
                  }),
                ),
              ],
              FutureBuilder<PerfilUsuario?>(
                future: _perfil,
                builder: (context, p) => _aviso(p.data),
              ),
              const SizedBox(height: 20),
              if (_vista == _Vista.grupo && grupos.isEmpty)
                const EstadoVacio(
                  icono: Icons.groups_outlined,
                  texto: 'Únete a un grupo para ver su ranking.',
                )
              else
                FutureBuilder<List<PuestoRanking>>(
                  future: _futuro,
                  builder: (context, snap) {
                    if (snap.connectionState != ConnectionState.done) {
                      return const Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (snap.hasError) {
                      return EstadoVacio(
                        icono: Icons.error_outline,
                        texto: '${snap.error}',
                      );
                    }
                    final lista = snap.data!;
                    if (lista.isEmpty) {
                      return const EstadoVacio(
                        icono: Icons.emoji_events_outlined,
                        texto: 'Todavía no hay nadie en este ranking.',
                      );
                    }
                    return Column(
                      children: [
                        for (var i = 0; i < lista.length; i++)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Aparece(
                              retardo: 40 * (i < 10 ? i : 10),
                              child: _FilaRanking(
                                puesto: i + 1,
                                datos: lista[i],
                              ),
                            ),
                          ),
                      ],
                    );
                  },
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
