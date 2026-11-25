import 'package:flutter/material.dart';
import 'package:ligaria_ui/ligaria_ui.dart';
import '../ajustes/ajustes_page.dart';
import '../ajustes/ajustes_repositorio.dart';
import '../estadisticas/estadisticas_page.dart';
import '../grupos/grupos_repositorio.dart';
import '../social/acciones_jugador.dart';
import 'ranking_repositorio.dart';
import '../../../core/idioma.dart';

enum _Vista {
  global(Icons.public, Preferencia.rankingGlobal),
  provincia(Icons.map_outlined, Preferencia.rankingProvincia),
  localidad(Icons.location_city_outlined, Preferencia.rankingLocalidad),
  grupo(Icons.groups_outlined, null),
  mia(Icons.person_outline, null);

  const _Vista(this.icono, this.preferencia);
  final IconData icono;

  String etiqueta(AppL10n l) => switch (this) {
    global => l.vistaGlobal,
    provincia => l.vistaProvincia,
    localidad => l.vistaLocalidad,
    grupo => l.vistaGrupos,
    mia => l.vistaMia,
  };

  /// Ajuste que hay que activar para aparecer en ese ranking (`null`: siempre).
  final Preferencia? preferencia;
}

/// Rankings: global, de tu provincia, de tu localidad y de cada grupo de amigos.
class RankingPage extends StatefulWidget {
  const RankingPage({super.key, this.repo, this.grupos, this.acciones});
  final RankingRepositorio? repo;

  /// Para elegir el grupo en la vista «Mis grupos».
  final GruposRepositorio? grupos;

  /// Acciones sobre cada jugador (WhatsApp, mensaje, retar); sin ellas no se muestran.
  final AccionesJugador? acciones;
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
    if (_vista == _Vista.mia) _futuroMio = _cargarMias();
    _futuro = switch (_vista) {
      _Vista.global => _repo.ranking(),
      _Vista.provincia => _repo.rankingProvincia(),
      _Vista.localidad => _repo.rankingLocalidad(),
      _Vista.grupo =>
        _grupo == null
            ? Future.value(const [])
            : _repo.rankingGrupo(_grupo!.id),
      _Vista.mia => Future.value(const []),
    };
  }

  Future<List<_Posicion>> _futuroMio = Future.value(const []);

  /// Mi puesto en cada ranking; `null` si no aparezco o el ranking no está disponible.
  Future<List<_Posicion>> _cargarMias() async {
    final yo = _repo.miId;
    final grupos = await _grupos;
    Future<_Posicion> pos(
      String? etiqueta,
      _Vista v,
      Future<List<PuestoRanking>> f,
    ) async {
      try {
        final lista = await f;
        final i = lista.indexWhere((e) => e.usuarioId == yo);
        return _Posicion(
          v,
          etiqueta,
          i < 0 ? null : i + 1,
          lista.length,
          i < 0 ? null : lista[i],
        );
      } catch (_) {
        return _Posicion(v, etiqueta, null, 0, null);
      }
    }

    return Future.wait([
      pos(null, _Vista.global, _repo.ranking()),
      pos(null, _Vista.provincia, _repo.rankingProvincia()),
      pos(null, _Vista.localidad, _repo.rankingLocalidad()),
      for (final g in grupos)
        pos(g.nombre, _Vista.grupo, _repo.rankingGrupo(g.id)),
    ]);
  }

  Future<void> _ajustes() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const AjustesPage()));
    if (mounted) setState(_cargar);
  }

  String _descripcion() => switch (_vista) {
    _Vista.global => context.l10n.descGlobal,
    _Vista.provincia => context.l10n.descProvincia,
    _Vista.localidad => context.l10n.descLocalidad,
    _Vista.grupo => context.l10n.descGrupo,
    _Vista.mia => context.l10n.descMia,
  };

  /// Aviso cuando el usuario no aparece en el ranking o falta su ubicación.
  Widget _aviso(PerfilUsuario? p) {
    if (p == null || _vista == _Vista.grupo || _vista == _Vista.mia) {
      return const SizedBox.shrink();
    }
    String? titulo, detalle;
    if (_vista == _Vista.provincia && !p.tieneProvincia) {
      titulo = context.l10n.indicaTuProvincia;
      detalle = context.l10n.completalaAjustes;
    } else if (_vista == _Vista.localidad && !p.tieneLocalidad) {
      titulo = context.l10n.indicaTuLocalidad;
      detalle = context.l10n.completalaAjustes;
    } else if (!p.valorDe(_vista.preferencia!)) {
      titulo = context.l10n.noApareces;
      detalle = context.l10n.unetePara;
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
            child: Text(context.l10n.ajustes),
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
                context.l10n.ranking,
                style: t.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                context.l10n.descConPuntos(_descripcion()),
                style: t.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => EstadisticasPage(grupos: widget.grupos),
                    ),
                  ),
                  icon: const Icon(Icons.query_stats_rounded),
                  label: Text(context.l10n.estadisticas),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final v in _Vista.values)
                    ChoiceChip(
                      avatar: Icon(v.icono, size: 18),
                      label: Text(v.etiqueta(context.l10n)),
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
                  decoration: InputDecoration(labelText: context.l10n.grupo),
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
              if (_vista == _Vista.mia)
                FutureBuilder<List<_Posicion>>(
                  future: _futuroMio,
                  builder: (context, snap) {
                    if (snap.connectionState != ConnectionState.done) {
                      return const Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    final lista = snap.data ?? const <_Posicion>[];
                    return Column(
                      children: [
                        for (final x in lista)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _FilaPosicion(datos: x),
                          ),
                      ],
                    );
                  },
                )
              else if (_vista == _Vista.grupo && grupos.isEmpty)
                EstadoVacio(
                  icono: Icons.groups_outlined,
                  texto: context.l10n.unetePorRanking,
                )
              else
                FutureBuilder<List<PuestoRanking>>(
                  future: _futuro,
                  builder: (context, snap) {
                    if (snap.connectionState != ConnectionState.done) {
                      return const Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(child: Cargando()),
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
                      return EstadoVacio(
                        icono: Icons.emoji_events_outlined,
                        texto: context.l10n.nadieRanking,
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
                                acciones: widget.acciones,
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

class _Posicion {
  const _Posicion(this.vista, this.grupo, this.puesto, this.total, this.datos);
  final _Vista vista;
  final String? grupo;
  final int? puesto;
  final int total;
  final PuestoRanking? datos;
}

class _FilaPosicion extends StatelessWidget {
  const _FilaPosicion({required this.datos});
  final _Posicion datos;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final l = context.l10n;
    final titulo = datos.grupo ?? datos.vista.etiqueta(l);
    final d = datos.datos;
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: Icon(datos.vista.icono, color: cs.primary),
        title: Text(
          titulo,
          style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          d == null ? l.sinPuesto : l.ganadosDeJugados(d.ganados, d.jugados),
          style: t.bodySmall?.copyWith(color: cs.onSurfaceVariant),
        ),
        trailing: datos.puesto == null
            ? null
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '#${datos.puesto}',
                    style: t.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: cs.primary,
                    ),
                  ),
                  Text(
                    l.deTotal(datos.total),
                    style: t.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
      ),
    );
  }
}

class _FilaRanking extends StatelessWidget {
  const _FilaRanking({
    required this.puesto,
    required this.datos,
    this.acciones,
  });
  final AccionesJugador? acciones;
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
                    context.l10n.ganadosDeJugados(datos.ganados, datos.jugados),
                    style: t.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  context.l10n.puntosAbrev(datos.puntos),
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
            if (acciones != null && !acciones!.esYo(datos.usuarioId))
              IconButton(
                tooltip: datos.nombre,
                onPressed: () => acciones!.mostrar(
                  context,
                  id: datos.usuarioId,
                  nombre: datos.nombre,
                  esAmigo: false,
                ),
                icon: const Icon(Icons.more_vert),
              ),
          ],
        ),
      ),
    );
  }
}
