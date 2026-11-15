import 'package:flutter/material.dart';
import 'package:ligaria_ui/ligaria_ui.dart';
import 'ligas_repositorio.dart';
import 'marcador_repositorio.dart';
import 'tablero_marcador.dart';
import 'tanteo.dart';

/// Tanteador en directo (puntos, juegos y sets) de un partido de tenis o pádel.
/// Al terminar, devuelve los sets con `Navigator.pop` para guardarlos como resultado.
class TanteadorPage extends StatefulWidget {
  const TanteadorPage({
    super.key,
    required this.local,
    required this.visitante,
    required this.deporte,
    required this.setsParaGanar,
    this.amistosoId,
    this.partidoId,
  });
  final String local, visitante;

  /// Partido que se puntúa: se emite en directo al resto del grupo.
  final String? amistosoId, partidoId;
  final Deporte deporte;
  final int setsParaGanar;

  @override
  State<TanteadorPage> createState() => _TanteadorPageState();
}

class _TanteadorPageState extends State<TanteadorPage> {
  late Tanteo _t = Tanteo(
    setsParaGanar: widget.setsParaGanar,
    puntoDeOro: widget.deporte == Deporte.padel,
  );
  final _historial = <Tanteo>[];
  bool _emitiendo = true;
  bool _avisado = false;

  @override
  void initState() {
    super.initState();
    _emitir();
  }

  /// Publica el marcador para que el resto del grupo lo siga. Si no se puede (p. ej. no juegas
  /// el partido), se sigue puntuando en local y se avisa una vez.
  Future<void> _emitir([bool borrar = false]) async {
    try {
      await MarcadorRepositorio.instancia.publicar(
        amistosoId: widget.amistosoId,
        partidoId: widget.partidoId,
        tanteo: borrar ? null : _t,
      );
      if (mounted && !_emitiendo) setState(() => _emitiendo = true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _emitiendo = false);
      if (!_avisado) {
        _avisado = true;
        avisar(context, 'Tu marcador no se emite en directo en este partido.');
      }
    }
  }

  void _punto(bool local) {
    if (_t.terminado) return;
    setState(() {
      _historial.add(_t);
      _t = _t.punto(local);
    });
    _emitir();
  }

  void _deshacer() {
    if (_historial.isEmpty) return;
    setState(() => _t = _historial.removeLast());
    _emitir();
  }

  Future<void> _salir() async {
    if (_historial.isEmpty || _t.terminado) {
      _emitir(true);
      Navigator.pop(context);
      return;
    }
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('¿Salir del tanteador?'),
        content: const Text(
          'El partido en curso no se ha guardado y se perderá.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Seguir'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Salir'),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      _emitir(true);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _salir();
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text('Tanteador · ${widget.deporte.etiqueta}'),
          leading: BackButton(onPressed: _salir),
          actions: [
            IconButton(
              tooltip: 'Deshacer último punto',
              onPressed: _historial.isEmpty ? null : _deshacer,
              icon: const Icon(Icons.undo_rounded),
            ),
          ],
        ),
        body: FondoBlobs(
          child: SafeArea(
            child: ContenidoCentrado(
              maxAncho: 640,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                children: [
                  TableroMarcador(
                    tanteo: _t,
                    local: widget.local,
                    visitante: widget.visitante,
                    enDirecto: _emitiendo,
                  ),
                  const SizedBox(height: 20),
                  if (_t.terminado) ...[
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: cs.primary.withValues(alpha: .1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: cs.primary.withValues(alpha: .6),
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.emoji_events_rounded,
                            color: cs.primary,
                            size: 36,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Gana ${_t.ganaLocal ? widget.local : widget.visitante}',
                            style: t.titleLarge,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _t.sets.map((s) => '${s[0]}-${s[1]}').join('  '),
                            style: t.titleMedium?.copyWith(color: cs.primary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () {
                        _emitir(true);
                        Navigator.pop(context, _t.resultado);
                      },
                      icon: const Icon(Icons.save_rounded),
                      label: const Text('Guardar resultado'),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: _deshacer,
                      icon: const Icon(Icons.undo_rounded),
                      label: const Text('Corregir último punto'),
                    ),
                  ] else ...[
                    _BotonPunto(
                      nombre: widget.local,
                      onTap: () => _punto(true),
                    ),
                    const SizedBox(height: 12),
                    _BotonPunto(
                      nombre: widget.visitante,
                      onTap: () => _punto(false),
                    ),
                    if (widget.deporte == Deporte.padel) ...[
                      const SizedBox(height: 12),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Punto de oro'),
                        subtitle: const Text(
                          'En el 40-40 el siguiente punto decide el juego',
                        ),
                        value: _t.puntoDeOro,
                        onChanged: (v) {
                          setState(() => _t = _t.copiar(puntoDeOro: v));
                          _emitir();
                        },
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BotonPunto extends StatelessWidget {
  const _BotonPunto({required this.nombre, required this.onTap});
  final String nombre;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 72,
    child: FilledButton(
      onPressed: onTap,
      child: Text(
        'Punto para $nombre',
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
      ),
    ),
  );
}
