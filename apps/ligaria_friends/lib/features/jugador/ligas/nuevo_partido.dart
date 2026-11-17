import 'package:flutter/material.dart';
import 'package:ligaria_ui/ligaria_ui.dart';
import '../amistosos/amistosos_repositorio.dart';
import '../grupos/grupos_repositorio.dart';
import 'formato.dart';
import 'ligas_repositorio.dart';

/// Una liga en curso donde el usuario es administrador, con el nombre de su grupo.
class _LigaActiva {
  const _LigaActiva(this.liga, this.grupo);
  final Liga liga;
  final Grupo grupo;
  String get etiqueta => '${liga.nombre} · ${grupo.nombre}';
}

enum _Modo { amistoso, liga }

/// Crea un partido: un amistoso del grupo (sin liga) o un partido de una liga en curso.
/// Devuelve `null` si se canceló; si se creó, el grupo del partido (`grupo` nulo en un amistoso sin grupo).
Future<({Grupo? grupo})?> mostrarNuevoPartido(
  BuildContext context, {
  required List<Grupo> grupos,
  required GruposRepositorio gruposRepo,
  required LigasRepositorio ligas,
  required AmistososRepositorio amistosos,
}) async {
  return showDialog<({Grupo? grupo})>(
    context: context,
    builder: (_) => _NuevoPartido(
      grupos: grupos,
      gruposRepo: gruposRepo,
      ligas: ligas,
      amistosos: amistosos,
    ),
  );
}

class _NuevoPartido extends StatefulWidget {
  const _NuevoPartido({
    required this.grupos,
    required this.gruposRepo,
    required this.ligas,
    required this.amistosos,
  });
  final List<Grupo> grupos;
  final GruposRepositorio gruposRepo;
  final LigasRepositorio ligas;
  final AmistososRepositorio amistosos;
  @override
  State<_NuevoPartido> createState() => _NuevoPartidoState();
}

class _NuevoPartidoState extends State<_NuevoPartido> {
  _Modo _modo = _Modo.amistoso;
  final _lugar = TextEditingController();
  DateTime? _fecha;
  TimeOfDay? _hora;
  bool _guardando = false;

  // Amistoso
  Grupo? _grupo; // opcional: un amistoso no tiene por qué ser de un grupo
  late final Future<List<Miembro>> _miembros = widget.gruposRepo
      .jugadoresPosibles();
  Deporte _deporte = Deporte.padel;
  Modalidad _modalidad = Modalidad.parejas;
  int _sets = 2;
  List<String?> _jl = [null, null], _jv = [null, null];

  // De liga
  late final Future<List<_LigaActiva>> _activas = _cargarActivas();
  _LigaActiva? _liga;
  Future<List<Participante>>? _participantes;
  String? _local, _visitante;

  @override
  void dispose() {
    _lugar.dispose();
    super.dispose();
  }

  Future<List<_LigaActiva>> _cargarActivas() async {
    final out = <_LigaActiva>[];
    for (final g in widget.grupos) {
      for (final l in await widget.ligas.ligas(g.id)) {
        if (l.enCurso && widget.ligas.puedeGestionar(l, g)) {
          out.add(_LigaActiva(l, g));
        }
      }
    }
    return out;
  }

  int get _porLado => _modalidad == Modalidad.individual ? 1 : 2;

  void _elegirGrupo(Grupo? g) => _grupo = g;

  void _elegirLiga(_LigaActiva? l) {
    setState(() {
      _liga = l;
      _local = _visitante = null;
      _participantes = l == null ? null : widget.ligas.participantes(l.liga.id);
    });
  }

  Future<void> _elegirFecha() async {
    final hoy = DateTime.now();
    final f = await showDatePicker(
      context: context,
      initialDate: _fecha ?? hoy,
      firstDate: DateTime(hoy.year - 1),
      lastDate: DateTime(hoy.year + 2),
    );
    if (f != null) setState(() => _fecha = f);
  }

  Future<void> _elegirHora() async {
    final h = await showTimePicker(
      context: context,
      initialTime: _hora ?? const TimeOfDay(hour: 18, minute: 0),
    );
    if (h != null) setState(() => _hora = h);
  }

  List<String?> get _elegidos => [..._jl.take(_porLado), ..._jv.take(_porLado)];
  bool get _hayRepetidos {
    final e = _elegidos.whereType<String>().toList();
    return e.length != e.toSet().length;
  }

  bool get _listo => _modo == _Modo.amistoso
      ? _elegidos.every((x) => x != null) && !_hayRepetidos
      : _liga != null &&
            _local != null &&
            _visitante != null &&
            _local != _visitante;

  DateTime? get _cuando {
    if (_fecha == null) return null;
    final h = _hora ?? const TimeOfDay(hour: 12, minute: 0);
    return DateTime(_fecha!.year, _fecha!.month, _fecha!.day, h.hour, h.minute);
  }

  Future<void> _crear() async {
    setState(() => _guardando = true);
    try {
      if (_modo == _Modo.amistoso) {
        await widget.amistosos.crear(
          grupoId: _grupo?.id,
          deporte: _deporte,
          local: _jl.take(_porLado).cast<String>().toList(),
          visitante: _jv.take(_porLado).cast<String>().toList(),
          setsParaGanar: _sets,
          fechaHora: _cuando,
          lugar: _lugar.text,
        );
      } else {
        await widget.ligas.crearPartido(
          ligaId: _liga!.liga.id,
          localId: _local!,
          visitanteId: _visitante!,
          fechaHora: _cuando,
          lugar: _lugar.text,
        );
      }
      if (mounted) {
        Navigator.pop(context, (
          grupo: _modo == _Modo.amistoso ? _grupo : _liga!.grupo,
        ));
      }
    } on LigasException catch (e) {
      if (mounted) {
        setState(() => _guardando = false);
        avisar(context, e.mensaje);
      }
    }
  }

  Widget _chips<T>(
    String titulo,
    List<T> valores,
    T actual,
    String Function(T) etiqueta,
    void Function(T) alElegir,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      Text(titulo, style: Theme.of(context).textTheme.labelLarge),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        children: [
          for (final v in valores)
            ChoiceChip(
              label: Text(etiqueta(v)),
              selected: v == actual,
              onSelected: (_) => setState(() => alElegir(v)),
            ),
        ],
      ),
    ],
  );

  Widget _desplegable({
    required String etiqueta,
    required String? valor,
    required List<(String, String)> opciones,
    required void Function(String?) alCambiar,
  }) => DropdownButtonFormField<String>(
    key: ValueKey('$etiqueta-${opciones.length}-$valor'),
    initialValue: valor,
    isExpanded: true,
    decoration: InputDecoration(labelText: etiqueta),
    items: [
      for (final (id, nombre) in opciones)
        DropdownMenuItem(
          value: id,
          child: Text(nombre, overflow: TextOverflow.ellipsis),
        ),
    ],
    onChanged: alCambiar,
  );

  Widget _cuandoYDonde() => Column(
    children: [
      const SizedBox(height: 14),
      Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _elegirFecha,
              icon: const Icon(Icons.event_outlined),
              label: Text(_fecha == null ? 'Fecha' : fechaCorta(_fecha!)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _elegirHora,
              icon: const Icon(Icons.schedule_outlined),
              label: Text(_hora == null ? 'Hora' : _hora!.format(context)),
            ),
          ),
        ],
      ),
      const SizedBox(height: 14),
      TextField(
        controller: _lugar,
        decoration: const InputDecoration(labelText: 'Lugar (opcional)'),
      ),
    ],
  );

  Widget _formAmistoso() => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 14),
      _desplegable(
        etiqueta: 'Grupo (opcional)',
        valor: _grupo?.id ?? '',
        opciones: [
          ('', 'Sin grupo (entre amigos)'),
          for (final g in widget.grupos) (g.id, g.nombre),
        ],
        alCambiar: (id) => setState(
          () =>
              _elegirGrupo(widget.grupos.where((g) => g.id == id).firstOrNull),
        ),
      ),
      _chips<Deporte>(
        'Deporte',
        Deporte.values,
        _deporte,
        (d) => d.etiqueta,
        (d) => _deporte = d,
      ),
      _chips<Modalidad>(
        'Modalidad',
        Modalidad.values,
        _modalidad,
        (m) => m.etiqueta,
        (m) {
          _modalidad = m;
          _jl = [null, null];
          _jv = [null, null];
        },
      ),
      _chips<int>(
        'Formato',
        const [1, 2, 3],
        _sets,
        (s) => 'Al mejor de ${s * 2 - 1}',
        (s) => _sets = s,
      ),
      FutureBuilder<List<Miembro>>(
        future: _miembros,
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            );
          }
          final ops = [
            for (final m in snap.data!)
              (m.id, m.esYo ? '${m.nombre} (tú)' : m.nombre),
          ];
          Widget lado(String titulo, List<String?> sel) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text(titulo, style: Theme.of(context).textTheme.labelLarge),
              for (var i = 0; i < _porLado; i++) ...[
                const SizedBox(height: 8),
                _desplegable(
                  etiqueta: _porLado == 1 ? 'Jugador' : 'Jugador ${i + 1}',
                  valor: sel[i],
                  opciones: ops,
                  alCambiar: (v) => setState(() => sel[i] = v),
                ),
              ],
            ],
          );
          return Column(
            children: [
              lado('Local', _jl),
              lado('Visitante', _jv),
              if (_hayRepetidos)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    'Un jugador no puede aparecer dos veces.',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      _cuandoYDonde(),
    ],
  );

  Widget _formLiga() => FutureBuilder<List<_LigaActiva>>(
    future: _activas,
    builder: (context, snap) {
      if (snap.connectionState != ConnectionState.done) {
        return const SizedBox(
          height: 80,
          child: Center(child: CircularProgressIndicator()),
        );
      }
      final activas = snap.data ?? const [];
      if (activas.isEmpty) {
        return Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Text(
            'No hay ligas en curso donde seas administrador. Crea una liga en tu '
            'grupo, inscribe a los participantes y genera el calendario; o crea un '
            'partido amistoso.',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        );
      }
      return Column(
        children: [
          const SizedBox(height: 14),
          DropdownButtonFormField<_LigaActiva>(
            initialValue: _liga,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Liga'),
            items: [
              for (final a in activas)
                DropdownMenuItem(
                  value: a,
                  child: Text(a.etiqueta, overflow: TextOverflow.ellipsis),
                ),
            ],
            onChanged: _elegirLiga,
          ),
          if (_participantes != null) ...[
            const SizedBox(height: 14),
            FutureBuilder<List<Participante>>(
              future: _participantes,
              builder: (context, ps) {
                if (!ps.hasData) {
                  return const Padding(
                    padding: EdgeInsets.all(12),
                    child: CircularProgressIndicator(),
                  );
                }
                final ops = [for (final p in ps.data!) (p.id, p.nombre)];
                return Column(
                  children: [
                    _desplegable(
                      etiqueta: 'Local',
                      valor: _local,
                      opciones: ops,
                      alCambiar: (v) => setState(() => _local = v),
                    ),
                    const SizedBox(height: 14),
                    _desplegable(
                      etiqueta: 'Visitante',
                      valor: _visitante,
                      opciones: ops,
                      alCambiar: (v) => setState(() => _visitante = v),
                    ),
                  ],
                );
              },
            ),
            _cuandoYDonde(),
            if (_local != null && _local == _visitante)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  'Elige dos participantes distintos.',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
          ],
        ],
      );
    },
  );

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Nuevo partido'),
    content: SizedBox(
      width: 420,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Amistoso'),
                  selected: _modo == _Modo.amistoso,
                  onSelected: (_) => setState(() => _modo = _Modo.amistoso),
                ),
                ChoiceChip(
                  label: const Text('De liga'),
                  selected: _modo == _Modo.liga,
                  onSelected: (_) => setState(() => _modo = _Modo.liga),
                ),
              ],
            ),
            if (_modo == _Modo.amistoso) _formAmistoso() else _formLiga(),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: _guardando ? null : () => Navigator.pop(context),
        child: const Text('Cancelar'),
      ),
      FilledButton(
        onPressed: _listo && !_guardando ? _crear : null,
        child: const Text('Crear partido'),
      ),
    ],
  );
}
