import 'package:flutter/material.dart';
import 'package:ligaria_ui/ligaria_ui.dart';
import '../grupos/grupos_repositorio.dart';
import '../ligas/confirmacion_repositorio.dart';
import '../ligas/dialogo_resultado.dart';
import '../ligas/formato.dart';
import '../ligas/ligas_repositorio.dart';
import '../ligas/marcador_page.dart';
import '../ligas/marcador_repositorio.dart';
import '../ligas/tanteador_page.dart';
import '../ligas/tanteo.dart';
import 'amistosos_repositorio.dart';
import '../../../core/idioma.dart';

/// Sección «Amistosos»: partidos sin liga, con su resultado. [grupo] `null`: los amistosos entre amigos, sin grupo.
class AmistososSeccion extends StatefulWidget {
  const AmistososSeccion({super.key, this.grupo, required this.repo});
  final Grupo? grupo;
  final AmistososRepositorio repo;
  @override
  State<AmistososSeccion> createState() => _AmistososSeccionState();
}

class _AmistososSeccionState extends State<AmistososSeccion> {
  late Future<List<Amistoso>> _lista = widget.repo.amistosos(widget.grupo?.id);

  Map<String, Confirmacion> _conf = {};

  @override
  void initState() {
    super.initState();
    _cargarConf();
  }

  Future<void> _cargarConf() async {
    try {
      final c = await ConfirmacionRepositorio.instancia.delGrupo(
        widget.grupo?.id,
      );
      if (mounted) setState(() => _conf = c);
    } catch (_) {}
  }

  void _recargar() {
    final nueva = widget.repo.amistosos(widget.grupo?.id);
    setState(() {
      _lista = nueva;
    });
    _cargarConf();
  }

  Future<void> _confirmar(Amistoso a) async {
    try {
      await ConfirmacionRepositorio.instancia.confirmar(amistosoId: a.id);
      if (!mounted) return;
      avisar(context, context.l10n.resultadoConfirmado);
      _recargar();
    } catch (e) {
      if (mounted) avisar(context, context.l10n.errConfirmar);
    }
  }

  Future<void> _tanteador(Amistoso a) async {
    final res = await Navigator.of(context).push<ResultadoTanteador>(
      MaterialPageRoute(
        builder: (_) => TanteadorPage(
          local: a.local,
          visitante: a.visitante,
          deporte: a.deporte,
          setsParaGanar: a.setsParaGanar,
          amistosoId: a.id,
        ),
      ),
    );
    if (res == null) return;
    try {
      await widget.repo.registrarResultado(a.id, res.sets, puntos: res.puntos);
      if (mounted) _recargar();
    } on LigasException catch (e) {
      if (mounted) avisar(context, e.mensaje);
    }
  }

  void _ver(Amistoso a) => Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => MarcadorPage(
        local: a.local,
        visitante: a.visitante,
        deporte: a.deporte,
        amistosoId: a.id,
      ),
    ),
  );

  Future<void> _resultado(Amistoso a) async {
    final sets = await showDialog<List<List<int>>>(
      context: context,
      builder: (_) => DialogoResultado(
        localNombre: a.local,
        visitanteNombre: a.visitante,
        setsParaGanar: a.setsParaGanar,
      ),
    );
    if (sets == null) return;
    try {
      await widget.repo.registrarResultado(a.id, sets);
      if (mounted) _recargar();
    } on LigasException catch (e) {
      if (mounted) avisar(context, e.mensaje);
    }
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<List<Amistoso>>(
    future: _lista,
    builder: (context, snap) {
      final lista = snap.data ?? const <Amistoso>[];
      if (lista.isEmpty) {
        return const SizedBox.shrink(); // sin amistosos no ocupa sitio
      }
      final t = Theme.of(context).textTheme;
      return StreamBuilder<Set<String>>(
        stream: MarcadorRepositorio.instancia.enDirecto(widget.grupo?.id),
        builder: (context, vivo) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Text(
              widget.grupo == null
                  ? context.l10n.amistososConAmigos
                  : context.l10n.amistosos,
              style: t.titleLarge,
            ),
            const SizedBox(height: 12),
            for (final a in lista)
              _Fila(
                a,
                enDirecto: vivo.data?.contains(a.id) ?? false,
                onResultado: () => _resultado(a),
                onTanteador: () => _tanteador(a),
                onVer: () => _ver(a),
                confirmacion: a.jugado ? confirmacionDe(_conf, a.id) : null,
                onConfirmar: () => _confirmar(a),
              ),
          ],
        ),
      );
    },
  );
}

class _Fila extends StatelessWidget {
  const _Fila(
    this.a, {
    required this.onResultado,
    required this.onTanteador,
    required this.onVer,
    required this.enDirecto,
    required this.confirmacion,
    required this.onConfirmar,
  });
  final Confirmacion? confirmacion;
  final VoidCallback onConfirmar;
  final Amistoso a;
  final bool enDirecto;
  final VoidCallback onResultado, onTanteador, onVer;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final marca = Marca.de(context);
    final cuando = [
      if (a.fechaHora != null) fechaHora(a.fechaHora!),
      if (a.lugar != null) a.lugar!,
    ].join(' · ');
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: marca.superficie,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: marca.borde),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: a.local,
                        style: TextStyle(
                          fontWeight: a.ganador == 'LOCAL'
                              ? FontWeight.w900
                              : null,
                        ),
                      ),
                      const TextSpan(text: '  vs  '),
                      TextSpan(
                        text: a.visitante,
                        style: TextStyle(
                          fontWeight: a.ganador == 'VISITANTE'
                              ? FontWeight.w900
                              : null,
                        ),
                      ),
                    ],
                  ),
                  style: t.titleSmall,
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Insignia(a.deporte.etiqueta),
                    if (enDirecto && !a.jugado)
                      Insignia(
                        context.l10n.enDirecto,
                        color: const Color(0xFFEF4444),
                      ),
                    if (cuando.isNotEmpty)
                      Text(
                        cuando,
                        style: t.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
                if (confirmacion != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: EstadoConfirmacion(
                      c: confirmacion!,
                      onConfirmar: onConfirmar,
                    ),
                  ),
                if (a.resultado != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      a.resultado!,
                      style: t.bodyMedium?.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          a.jugado
              ? Icon(Icons.check_circle_rounded, color: cs.primary)
              : Column(
                  children: [
                    if (enDirecto)
                      FilledButton.tonalIcon(
                        onPressed: onVer,
                        icon: const Icon(Icons.visibility_outlined, size: 18),
                        label: Text(context.l10n.verMarcador),
                      ),
                    FilledButton.icon(
                      onPressed: onTanteador,
                      icon: const Icon(Icons.scoreboard_outlined, size: 18),
                      label: Text(context.l10n.tanteador),
                    ),
                    TextButton(
                      onPressed: onResultado,
                      child: Text(context.l10n.introducirResultado),
                    ),
                  ],
                ),
        ],
      ),
    );
  }
}
