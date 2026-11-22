import 'package:flutter/material.dart';
import 'package:ligaria_ui/ligaria_ui.dart';
import 'comando_voz.dart';
import 'escucha_voz.dart';
import 'ligas_repositorio.dart';
import 'marcador_repositorio.dart';
import 'tablero_marcador.dart';
import 'tanteo.dart';
import '../../../core/idioma.dart';

/// Tanteador en directo (puntos, juegos y sets) de un partido de tenis o pádel.
/// Al terminar, devuelve un [ResultadoTanteador] (sets y puntos) con `Navigator.pop`.
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
  // Quién ganó cada punto («L» / «V»), en paralelo al historial, para guardarlos con el resultado.
  final _secuencia = <String>[];
  bool _emitiendo = true;
  bool _avisado = false;

  // Voz: se escucha de forma continua mientras esté activada y el partido no haya terminado.
  late final _interprete = InterpreteVoz(
    local: widget.local,
    visitante: widget.visitante,
  );
  bool _vozActiva = false;
  bool _vozPreparada = false;

  @override
  void initState() {
    super.initState();
    _emitir();
  }

  @override
  void dispose() {
    _vozActiva = false;
    EscuchaVoz.instancia.parar();
    super.dispose();
  }

  Future<void> _alternarVoz() async {
    if (_vozActiva) {
      setState(() => _vozActiva = false);
      await EscuchaVoz.instancia.parar();
      return;
    }
    if (!_vozPreparada) {
      final ok = await EscuchaVoz.instancia.preparar(
        alTerminarEscucha: _reescuchar,
        alFallar: (_) {},
      );
      if (!mounted) return;
      if (!ok) {
        avisar(context, context.l10n.vozNoDisponible);
        return;
      }
      _vozPreparada = true;
    }
    setState(() => _vozActiva = true);
    await _escuchar();
  }

  Future<void> _escuchar() async {
    if (!mounted || !_vozActiva || _t.terminado) return;
    await EscuchaVoz.instancia.escuchar(
      idioma: Localizations.localeOf(context).languageCode,
      alFrase: _alFrase,
    );
  }

  /// El reconocedor se corta solo tras unos segundos de silencio: se reanuda mientras siga activo.
  void _reescuchar() {
    if (!mounted || !_vozActiva) return;
    if (_t.terminado) {
      setState(() => _vozActiva = false);
      return;
    }
    Future.delayed(const Duration(milliseconds: 300), _escuchar);
  }

  void _alFrase(String frase) {
    if (!mounted) return;
    final comandos = _interprete.interpretar(frase);
    if (comandos.isEmpty) {
      avisar(context, context.l10n.vozNoEntendido(frase));
      return;
    }
    for (final c in comandos) {
      switch (c) {
        case PuntoVoz(:final local):
          _punto(local);
        case DeshacerVoz():
          _deshacer();
      }
    }
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
        avisar(context, context.l10n.marcadorNoEmite);
      }
    }
  }

  void _punto(bool local) {
    if (_t.terminado) return;
    setState(() {
      _historial.add(_t);
      _secuencia.add(local ? 'L' : 'V');
      _t = _t.punto(local);
    });
    _emitir();
  }

  void _deshacer() {
    if (_historial.isEmpty) return;
    setState(() {
      _t = _historial.removeLast();
      _secuencia.removeLast();
    });
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
        title: Text(c.l10n.salirTanteador),
        content: Text(c.l10n.partidoNoGuardado),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: Text(c.l10n.seguir),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: Text(c.l10n.salir),
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
          title: Text(context.l10n.tanteadorDeporte(widget.deporte.etiqueta)),
          leading: BackButton(onPressed: _salir),
          actions: [
            IconButton(
              tooltip: _vozActiva
                  ? context.l10n.vozParar
                  : context.l10n.vozActivar,
              onPressed: _t.terminado ? null : _alternarVoz,
              icon: Icon(
                _vozActiva ? Icons.mic_rounded : Icons.mic_none_rounded,
                color: _vozActiva ? cs.primary : null,
              ),
            ),
            IconButton(
              tooltip: context.l10n.deshacerPunto,
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
                            context.l10n.ganaX(
                              _t.ganaLocal ? widget.local : widget.visitante,
                            ),
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
                        Navigator.pop(
                          context,
                          ResultadoTanteador(
                            sets: _t.resultado,
                            puntos: _secuencia.join(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.save_rounded),
                      label: Text(context.l10n.guardarResultado),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: _deshacer,
                      icon: const Icon(Icons.undo_rounded),
                      label: Text(context.l10n.corregirPunto),
                    ),
                  ] else ...[
                    if (_vozActiva) ...[
                      Row(
                        children: [
                          Icon(Icons.mic_rounded, color: cs.primary, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${context.l10n.vozEscuchando} ${context.l10n.vozAyuda}',
                              style: t.bodySmall,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],
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
                        title: Text(context.l10n.puntoDeOro),
                        subtitle: Text(context.l10n.puntoDeOroTxt),
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
        context.l10n.puntoPara(nombre),
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
      ),
    ),
  );
}
