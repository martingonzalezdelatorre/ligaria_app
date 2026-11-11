import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/widgets.dart';
import '../../data/liga_repository.dart';
import '../../data/models.dart';
import 'organizador_providers.dart';

const _etiquetasDesempate = {
  'enfrentamiento_directo': 'Enfrentamiento directo',
  'diferencia_partidos': 'Diferencia de partidos',
  'diferencia_sets': 'Diferencia de sets',
  'diferencia_juegos': 'Diferencia de juegos',
};

class CrearLigaPage extends ConsumerWidget {
  const CrearLigaPage({super.key, required this.escuelaId});
  final String escuelaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final temporadas = ref.watch(orgTemporadasProvider);
    final deportes = ref.watch(orgDeportesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva liga')),
      body: AsyncView<List<Temporada>>(
        value: temporadas,
        onRetry: () => ref.invalidate(orgTemporadasProvider),
        builder: (ts) => AsyncView<List<Deporte>>(
          value: deportes,
          onRetry: () => ref.invalidate(orgDeportesProvider),
          builder: (ds) => (ts.isEmpty || ds.isEmpty)
              ? const EstadoVacio(
                  icono: Icons.info_outline,
                  texto: 'Hace falta al menos una temporada y un deporte.\nPídeselo al superadministrador.')
              : _FormLiga(escuelaId: escuelaId, temporadas: ts, deportes: ds),
        ),
      ),
    );
  }
}

class _FormLiga extends ConsumerStatefulWidget {
  const _FormLiga({required this.escuelaId, required this.temporadas, required this.deportes});
  final String escuelaId;
  final List<Temporada> temporadas;
  final List<Deporte> deportes;
  @override
  ConsumerState<_FormLiga> createState() => _FormLigaState();
}

class _FormLigaState extends ConsumerState<_FormLiga> {
  final _form = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  late String _temporada = widget.temporadas.first.id;
  late String _deporte = widget.deportes.first.id;
  int _vueltas = 1, _individuales = 2, _dobles = 1, _victoria = 3, _empate = 1, _derrota = 0;
  List<String> _desempates = const ReglasLiga().desempates;
  bool _enviando = false;

  @override
  void dispose() {
    _nombre.dispose();
    super.dispose();
  }

  void _mover(int i, int delta) {
    final l = [..._desempates];
    final j = i + delta;
    if (j < 0 || j >= l.length) return;
    final t = l[i];
    l[i] = l[j];
    l[j] = t;
    setState(() => _desempates = l);
  }

  Future<void> _crear() async {
    if (!_form.currentState!.validate()) return;
    if (_individuales + _dobles < 1) {
      avisar(context, 'Cada encuentro necesita al menos un partido.');
      return;
    }
    setState(() => _enviando = true);
    try {
      await ref.read(ligaRepositoryProvider).crearLiga(
            escuelaId: widget.escuelaId,
            temporadaId: _temporada,
            deporteId: _deporte,
            nombre: _nombre.text.trim(),
            reglas: ReglasLiga(
              vueltas: _vueltas, individuales: _individuales, dobles: _dobles,
              puntosVictoria: _victoria, puntosEmpate: _empate, puntosDerrota: _derrota,
              desempates: _desempates,
            ),
          );
      ref.invalidate(orgLigasProvider(widget.escuelaId));
      if (!mounted) return;
      avisar(context, 'Liga creada. Publícala para abrir las inscripciones.');
      Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() => _enviando = false);
        avisar(context, mensajeError(e, defecto: 'No se pudo crear la liga.'));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Form(
      key: _form,
      child: ListView(padding: const EdgeInsets.all(16), children: [
        TextFormField(
          controller: _nombre,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(labelText: 'Nombre de la liga', border: OutlineInputBorder()),
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Escribe un nombre' : null,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: _temporada,
          decoration: const InputDecoration(labelText: 'Temporada', border: OutlineInputBorder()),
          items: [for (final t in widget.temporadas) DropdownMenuItem(value: t.id, child: Text(t.nombre))],
          onChanged: (v) => setState(() => _temporada = v ?? _temporada),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: _deporte,
          decoration: const InputDecoration(labelText: 'Deporte', border: OutlineInputBorder()),
          items: [for (final d in widget.deportes) DropdownMenuItem(value: d.id, child: Text(d.nombre))],
          onChanged: (v) => setState(() => _deporte = v ?? _deporte),
        ),
        const SizedBox(height: 24),
        Text('Reglas', style: tema.textTheme.titleMedium),
        const SizedBox(height: 8),
        SegmentedButton<int>(
          segments: const [
            ButtonSegment(value: 1, label: Text('1 vuelta')),
            ButtonSegment(value: 2, label: Text('2 vueltas')),
          ],
          selected: {_vueltas},
          onSelectionChanged: (s) => setState(() => _vueltas = s.first),
        ),
        _Contador(etiqueta: 'Partidos individuales', valor: _individuales, max: 6, onCambio: (v) => setState(() => _individuales = v)),
        _Contador(etiqueta: 'Partidos de dobles', valor: _dobles, max: 4, onCambio: (v) => setState(() => _dobles = v)),
        const Divider(),
        _Contador(etiqueta: 'Puntos por victoria', valor: _victoria, max: 10, onCambio: (v) => setState(() => _victoria = v)),
        _Contador(etiqueta: 'Puntos por empate', valor: _empate, max: 10, onCambio: (v) => setState(() => _empate = v)),
        _Contador(etiqueta: 'Puntos por derrota', valor: _derrota, max: 10, onCambio: (v) => setState(() => _derrota = v)),
        const Divider(),
        Text('Orden de desempates', style: tema.textTheme.titleSmall),
        for (var i = 0; i < _desempates.length; i++)
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(radius: 12, child: Text('${i + 1}', style: const TextStyle(fontSize: 12))),
            title: Text(_etiquetasDesempate[_desempates[i]] ?? _desempates[i]),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              IconButton(
                  tooltip: 'Subir', icon: const Icon(Icons.arrow_upward), onPressed: i == 0 ? null : () => _mover(i, -1)),
              IconButton(
                  tooltip: 'Bajar',
                  icon: const Icon(Icons.arrow_downward),
                  onPressed: i == _desempates.length - 1 ? null : () => _mover(i, 1)),
            ]),
          ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: _enviando ? null : _crear,
          child: _enviando
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Crear liga'),
        ),
      ]),
    );
  }
}

class _Contador extends StatelessWidget {
  const _Contador({required this.etiqueta, required this.valor, required this.max, required this.onCambio});
  final String etiqueta;
  final int valor, max;
  final ValueChanged<int> onCambio;
  @override
  Widget build(BuildContext context) => Row(children: [
        Expanded(child: Text(etiqueta)),
        IconButton(
            tooltip: 'Menos $etiqueta', icon: const Icon(Icons.remove_circle_outline), onPressed: valor > 0 ? () => onCambio(valor - 1) : null),
        SizedBox(width: 24, child: Text('$valor', textAlign: TextAlign.center)),
        IconButton(
            tooltip: 'Más $etiqueta', icon: const Icon(Icons.add_circle_outline), onPressed: valor < max ? () => onCambio(valor + 1) : null),
      ]);
}
