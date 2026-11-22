import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ligaria_ui/ligaria_ui.dart';
import '../../core/idioma.dart';
import '../../core/widgets.dart';
import '../../data/liga_repository.dart';
import '../../data/models.dart';
import 'organizador_providers.dart';

/// Programa un partido: fecha y hora, sede y pista, y su estado (programado, aplazado o suspendido).
/// Devuelve true si se ha guardado.
Future<bool> mostrarProgramar(BuildContext context, EncuentroVista e) async =>
    await mostrarFormulario<bool>(
      context,
      (_) => _ProgramarDialog(encuentro: e),
    ) ==
    true;

class _ProgramarDialog extends ConsumerStatefulWidget {
  const _ProgramarDialog({required this.encuentro});
  final EncuentroVista encuentro;
  @override
  ConsumerState<_ProgramarDialog> createState() => _ProgramarDialogState();
}

class _ProgramarDialogState extends ConsumerState<_ProgramarDialog> {
  late DateTime? _fecha = widget.encuentro.conHora
      ? widget.encuentro.fecha
      : null;
  late final _sede = TextEditingController(text: widget.encuentro.sede ?? '');
  late final _pista = TextEditingController(text: widget.encuentro.pista ?? '');
  late String _estado =
      const [
        'programado',
        'aplazado',
        'suspendido',
      ].contains(widget.encuentro.estado)
      ? widget.encuentro.estado
      : 'programado';
  bool _enviando = false;

  @override
  void dispose() {
    _sede.dispose();
    _pista.dispose();
    super.dispose();
  }

  Future<void> _elegirFecha() async {
    final base = _fecha ?? widget.encuentro.fecha ?? DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: base,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (d == null) return;
    setState(
      () => _fecha = DateTime(
        d.year,
        d.month,
        d.day,
        _fecha?.hour ?? 18,
        _fecha?.minute ?? 0,
      ),
    );
  }

  Future<void> _elegirHora() async {
    if (_fecha == null) return _elegirFecha();
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _fecha!.hour, minute: _fecha!.minute),
    );
    if (t == null) return;
    setState(
      () => _fecha = DateTime(
        _fecha!.year,
        _fecha!.month,
        _fecha!.day,
        t.hour,
        t.minute,
      ),
    );
  }

  Future<void> _guardar() async {
    setState(() => _enviando = true);
    try {
      final repo = ref.read(ligaRepositoryProvider);
      await repo.programarEncuentro(
        widget.encuentro.id,
        fechaHora: _fecha,
        sede: _sede.text,
        pista: _pista.text,
        estado: _estado == widget.encuentro.estado
            ? null
            : _estado.toUpperCase(),
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        setState(() => _enviando = false);
        avisar(
          context,
          mensajeError(e, defecto: context.l10n.errGuardarPartido),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final e = widget.encuentro;
    return HojaFormulario(
      icono: Icons.event_outlined,
      titulo: l.programarPartido,
      subtitulo: '${e.local} - ${e.visitante}',
      etiquetaAccion: l.guardar,
      iconoAccion: Icons.check_rounded,
      enviando: _enviando,
      onAccion: _guardar,
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                key: const Key('programar-fecha'),
                onPressed: _elegirFecha,
                icon: const Icon(Icons.calendar_today_outlined, size: 18),
                label: Text(
                  _fecha == null ? l.fechaPartido : fechaCorta(_fecha),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                key: const Key('programar-hora'),
                onPressed: _elegirHora,
                icon: const Icon(Icons.schedule, size: 18),
                label: Text(
                  _fecha == null ? l.horaPartido : horaCorta(_fecha!),
                ),
              ),
            ),
            if (_fecha != null)
              IconButton(
                tooltip: l.quitarFecha,
                icon: const Icon(Icons.close),
                onPressed: () => setState(() => _fecha = null),
              ),
          ],
        ),
        const SizedBox(height: 14),
        TextFormField(
          key: const Key('programar-sede'),
          controller: _sede,
          textCapitalization: TextCapitalization.sentences,
          decoration: decoracionCampo(l.sedeCampo, Icons.place_outlined),
        ),
        const SizedBox(height: 14),
        TextFormField(
          key: const Key('programar-pista'),
          controller: _pista,
          decoration: decoracionCampo(l.pistaCampo, Icons.sports_tennis),
        ),
        const SizedBox(height: 14),
        DropdownButtonFormField<String>(
          key: const Key('programar-estado'),
          initialValue: _estado,
          decoration: decoracionCampo(l.estadoPartido, Icons.flag_outlined),
          items: [
            for (final s in const ['programado', 'aplazado', 'suspendido'])
              DropdownMenuItem(
                value: s,
                child: Text(etiquetaEstadoEncuentro(s)),
              ),
          ],
          onChanged: (v) => setState(() => _estado = v ?? _estado),
        ),
      ],
    );
  }
}
