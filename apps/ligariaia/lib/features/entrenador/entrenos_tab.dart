import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ligaria_ui/ligaria_ui.dart';
import '../../core/idioma.dart';
import '../../core/widgets.dart';
import '../../data/liga_repository.dart';
import '../../data/models.dart';
import '../calendario/calendario.dart';
import 'entrenador_providers.dart';

/// Pestaña «Entrenos» del entrenador: los entrenos que ha asignado a sus equipos y el botón para
/// asignar uno nuevo. Los jugadores y sus familias lo ven en su calendario.
class EntrenosTab extends ConsumerWidget {
  const EntrenosTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final equipos = ref.watch(equiposEntrenadorProvider).value ?? const [];
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: equipos.isEmpty
          ? null
          : FloatingActionButton.extended(
              key: const Key('nuevo-entreno'),
              onPressed: () => _nuevo(context, ref),
              icon: const Icon(Icons.add),
              label: Text(l.nuevoEntreno),
            ),
      body: AsyncView<List<Entreno>>(
        value: ref.watch(misEntrenosProvider),
        onRetry: () => ref.invalidate(misEntrenosProvider),
        builder: (lista) {
          final hoy = DateTime.now();
          final desde = DateTime(hoy.year, hoy.month, hoy.day);
          final proximos = lista
              .where((e) => !e.fecha.isBefore(desde))
              .toList();
          final pasados = lista
              .where((e) => e.fecha.isBefore(desde))
              .toList()
              .reversed
              .toList();
          Widget titulo(String t) => Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
            child: Text(
              t,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
          );
          Widget tarjeta(Entreno e) => TarjetaEntreno(
            entreno: e,
            trailing: IconButton(
              tooltip: l.eliminarEntreno,
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _eliminar(context, ref, e),
            ),
          );
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(misEntrenosProvider);
              await ref.read(misEntrenosProvider.future);
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 96),
              children: lista.isEmpty
                  ? [
                      SizedBox(
                        height: 360,
                        child: EstadoVacio(
                          icono: Icons.fitness_center,
                          texto: l.sinEntrenosEntrenador,
                        ),
                      ),
                    ]
                  : [
                      if (proximos.isNotEmpty) titulo(l.agendaProximos),
                      for (final e in proximos) tarjeta(e),
                      if (pasados.isNotEmpty) titulo(l.agendaAnteriores),
                      for (final e in pasados.take(20)) tarjeta(e),
                    ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _nuevo(BuildContext context, WidgetRef ref) async {
    final ok = await mostrarFormulario<bool>(
      context,
      (_) => const _NuevoEntrenoDialog(),
    );
    if (ok == true) {
      ref.invalidate(misEntrenosProvider);
      ref.invalidate(agendaProvider);
      if (context.mounted) avisar(context, context.l10n.entrenoGuardado);
    }
  }

  Future<void> _eliminar(BuildContext context, WidgetRef ref, Entreno e) async {
    final l = context.l10n;
    final seguro = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.eliminarEntrenoPregunta),
        content: Text(
          '${e.equipo} · ${fechaHoraCorta(e.fecha, conHora: true)}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l.cancelar),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.eliminarEntreno),
          ),
        ],
      ),
    );
    if (seguro != true) return;
    try {
      await ref.read(ligaRepositoryProvider).eliminarEntreno(e.id);
      ref.invalidate(misEntrenosProvider);
      ref.invalidate(agendaProvider);
      if (context.mounted) avisar(context, l.entrenoEliminado);
    } catch (_) {
      if (context.mounted) avisar(context, l.errGuardarEntreno);
    }
  }
}

class _NuevoEntrenoDialog extends ConsumerStatefulWidget {
  const _NuevoEntrenoDialog();
  @override
  ConsumerState<_NuevoEntrenoDialog> createState() =>
      _NuevoEntrenoDialogState();
}

class _NuevoEntrenoDialogState extends ConsumerState<_NuevoEntrenoDialog> {
  String? _equipoId;
  DateTime? _fecha;
  final _duracion = TextEditingController(text: '60');
  final _lugar = TextEditingController();
  final _notas = TextEditingController();
  bool _enviando = false;

  @override
  void dispose() {
    _duracion.dispose();
    _lugar.dispose();
    _notas.dispose();
    super.dispose();
  }

  Future<void> _elegirFecha() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _fecha ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
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

  Future<void> _guardar(String equipoId) async {
    final l = context.l10n;
    if (_fecha == null) {
      avisar(context, l.fechaEntrenoObligatoria);
      return;
    }
    setState(() => _enviando = true);
    try {
      await ref
          .read(ligaRepositoryProvider)
          .crearEntreno(
            equipoId,
            _fecha!,
            duracionMin: int.tryParse(_duracion.text.trim()),
            lugar: _lugar.text,
            notas: _notas.text,
          );
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      if (mounted) {
        setState(() => _enviando = false);
        avisar(context, l.errGuardarEntreno);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final equipos = ref.watch(equiposEntrenadorProvider).value ?? const [];
    final equipoId =
        _equipoId ?? (equipos.isEmpty ? null : equipos.first.equipoId);
    return HojaFormulario(
      icono: Icons.fitness_center,
      titulo: l.nuevoEntreno,
      etiquetaAccion: l.guardar,
      iconoAccion: Icons.check_rounded,
      enviando: _enviando,
      onAccion: equipoId == null ? null : () => _guardar(equipoId),
      children: [
        DropdownButtonFormField<String>(
          key: const Key('entreno-equipo'),
          initialValue: equipoId,
          isExpanded: true,
          decoration: decoracionCampo(l.equipoCampo, Icons.groups_outlined),
          items: [
            for (final e in equipos)
              DropdownMenuItem(
                value: e.equipoId,
                child: Text(e.equipo, overflow: TextOverflow.ellipsis),
              ),
          ],
          onChanged: (v) => setState(() => _equipoId = v),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                key: const Key('entreno-fecha'),
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
                key: const Key('entreno-hora'),
                onPressed: _elegirHora,
                icon: const Icon(Icons.schedule, size: 18),
                label: Text(
                  _fecha == null ? l.horaPartido : horaCorta(_fecha!),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        TextFormField(
          key: const Key('entreno-duracion'),
          controller: _duracion,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(3),
          ],
          decoration: decoracionCampo(l.duracionCampo, Icons.timer_outlined),
        ),
        const SizedBox(height: 14),
        TextFormField(
          key: const Key('entreno-lugar'),
          controller: _lugar,
          maxLength: 120,
          textCapitalization: TextCapitalization.sentences,
          decoration: decoracionCampo(l.sedeCampo, Icons.place_outlined),
        ),
        const SizedBox(height: 6),
        TextFormField(
          key: const Key('entreno-notas'),
          controller: _notas,
          maxLength: 1000,
          maxLines: 3,
          textCapitalization: TextCapitalization.sentences,
          decoration: decoracionCampo(l.notasCampo, Icons.notes_outlined),
        ),
      ],
    );
  }
}
