import 'package:flutter/material.dart';
import 'package:ligaria_ui/ligaria_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/widgets.dart';
import '../../data/liga_repository.dart';
import '../../data/models.dart';
import '../escuela/escuela_providers.dart';
import 'crear_liga_page.dart';
import 'liga_detalle_page.dart';
import 'organizador_providers.dart';

class LigasTab extends ConsumerWidget {
  const LigasTab({super.key, required this.escuelaId, this.orgTipo});
  final String escuelaId;
  final String? orgTipo; // tipo de la organización (ESCUELA, AYUNTAMIENTO, GRUPO_AMIGOS)

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ligas = ref.watch(orgLigasProvider(escuelaId));
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => CrearLigaPage(escuelaId: escuelaId, orgTipo: orgTipo))),
        icon: const Icon(Icons.add),
        label: const Text('Nueva liga'),
      ),
      body: AsyncView<List<Liga>>(
        value: ligas,
        onRetry: () => ref.invalidate(orgLigasProvider(escuelaId)),
        builder: (lista) => lista.isEmpty
            ? const EstadoVacio(icono: Icons.emoji_events_outlined, texto: 'Aún no has creado ninguna liga.\nPulsa «Nueva liga» para empezar.')
            : RefreshIndicator(
                onRefresh: () => ref.refresh(orgLigasProvider(escuelaId).future),
                child: ListView(
                  padding: const EdgeInsets.only(top: 8, bottom: 96),
                  children: [for (final l in lista) _LigaCard(liga: l, escuelaId: escuelaId, orgTipo: orgTipo)],
                ),
              ),
      ),
    );
  }
}

class _LigaCard extends ConsumerWidget {
  const _LigaCard({required this.liga, required this.escuelaId, this.orgTipo});
  final Liga liga;
  final String escuelaId;
  final String? orgTipo;

  Future<void> _publicar(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(ligaRepositoryProvider).publicarLiga(liga.id);
      ref.invalidate(orgLigasProvider(escuelaId));
      if (context.mounted) avisar(context, 'Liga publicada: ya admite inscripciones de equipos.');
    } catch (e) {
      if (context.mounted) avisar(context, mensajeError(e, defecto: 'No se pudo publicar la liga.'));
    }
  }

  Future<void> _agregarEquipos(BuildContext context, WidgetRef ref) async {
    final repo = ref.read(ligaRepositoryProvider);
    try {
      final equipos = await ref.read(equiposEscuelaProvider(escuelaId).future);
      final validos = equipos.where((e) => liga.deporteId == null || e.deporteId == liga.deporteId).toList();
      if (!context.mounted) return;
      final elegido = await elegirDeLista<EquipoLite>(
        context,
        icono: Icons.group_add_rounded,
        titulo: 'Agregar equipo',
        subtitulo: liga.nombre,
        opciones: [for (final e in validos) (e, e.nombre, null)],
        vacio: 'No hay equipos de este deporte. Crea uno en «Equipos».',
      );
      if (elegido == null) return;
      await repo.inscribirEquipo(liga.id, elegido.id);
      ref.invalidate(orgClasificacionProvider(liga.id));
      if (context.mounted) avisar(context, '${elegido.nombre} agregado a ${liga.nombre}.');
    } catch (e) {
      if (context.mounted) avisar(context, mensajeError(e, defecto: 'No se pudo agregar el equipo.'));
    }
  }

  Future<void> _generar(BuildContext context, WidgetRef ref) async {
    final p = await mostrarFormulario<ParamsCalendario>(context, (_) => GenerarCalendarioDialog(inicio: liga.fechaInicio));
    if (p == null) return;
    try {
      final n = await ref
          .read(ligaRepositoryProvider)
          .generarCalendario(liga.id, inicio: p.inicio, diasEntreJornadas: p.dias, vueltas: p.vueltas);
      ref.invalidate(orgEncuentrosProvider(liga.id));
      ref.invalidate(orgLigasProvider(escuelaId));
      if (context.mounted) avisar(context, 'Calendario generado: $n encuentros.');
    } catch (e) {
      if (context.mounted) avisar(context, mensajeError(e, defecto: 'No se pudo generar el calendario.'));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tema = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(liga.nombre, style: tema.textTheme.titleMedium),
          const SizedBox(height: 2),
          Text('${liga.deporte ?? 'Liga'} · ${etiquetaEstadoLiga(liga.estado)}',
              style: tema.textTheme.bodySmall?.copyWith(color: tema.colorScheme.onSurfaceVariant)),
          if (liga.fechaInicio != null && liga.fechaFin != null)
            Text('${fechaLarga(liga.fechaInicio!)} – ${fechaLarga(liga.fechaFin!)}',
                style: tema.textTheme.bodySmall?.copyWith(color: tema.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 4, children: [
            if (liga.estado == 'borrador')
              OutlinedButton.icon(
                key: Key('editar-${liga.id}'),
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Editar'),
                onPressed: () => Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => CrearLigaPage(escuelaId: escuelaId, orgTipo: orgTipo, liga: liga))),
              ),
            if (liga.estado == 'borrador')
              FilledButton.tonal(onPressed: () => _publicar(context, ref), child: const Text('Publicar')),
            if (liga.estado == 'publicada')
              OutlinedButton.icon(
                  icon: const Icon(Icons.group_add_outlined),
                  onPressed: () => _agregarEquipos(context, ref),
                  label: const Text('Agregar equipo')),
            if (liga.estado == 'publicada' || liga.estado == 'en_curso')
              OutlinedButton(onPressed: () => _generar(context, ref), child: const Text('Generar calendario')),
            TextButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => LigaDetallePage(liga: liga, escuelaId: escuelaId))),
              child: const Text('Ver liga'),
            ),
          ]),
        ]),
      ),
    );
  }
}

class ParamsCalendario {
  const ParamsCalendario(this.inicio, this.dias, this.vueltas);
  final DateTime inicio;
  final int dias;
  final int vueltas; // 1 = solo ida, 2 = ida y vuelta
}

/// Pide fecha de inicio y días entre jornadas; avisa de que un calendario existente se sustituye.
class GenerarCalendarioDialog extends StatefulWidget {
  const GenerarCalendarioDialog({super.key, this.inicio});
  final DateTime? inicio;
  @override
  State<GenerarCalendarioDialog> createState() => _GenerarCalendarioDialogState();
}

class _GenerarCalendarioDialogState extends State<GenerarCalendarioDialog> {
  late DateTime _inicio = widget.inicio ??
      () {
        final h = DateTime.now();
        return DateTime(h.year, h.month, h.day);
      }();
  final _dias = TextEditingController(text: '7');
  bool _idaYVuelta = false;

  @override
  void dispose() {
    _dias.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return HojaFormulario(
      icono: Icons.calendar_month_rounded,
      titulo: 'Generar calendario',
      subtitulo: 'Se emparejan los equipos inscritos y se reparten las jornadas en fechas.',
      etiquetaAccion: 'Generar',
      iconoAccion: Icons.auto_awesome_rounded,
      onAccion: () => Navigator.of(context)
          .pop(ParamsCalendario(_inicio, (int.tryParse(_dias.text) ?? 7).clamp(1, 60), _idaYVuelta ? 2 : 1)),
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () async {
            final f = await showDatePicker(
                context: context, initialDate: _inicio, firstDate: DateTime(2020), lastDate: DateTime(2100));
            if (f != null) setState(() => _inicio = f);
          },
          child: InputDecorator(
            decoration: decoracionCampo('Primera jornada', Icons.event, sufijo: const Icon(Icons.expand_more)),
            child: Text(fechaLarga(_inicio)),
          ),
        ),
        espacioCampo,
        TextField(
          controller: _dias,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: decoracionCampo('Días entre jornadas', Icons.repeat, ayuda: '7'),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Ida y vuelta'),
          subtitle: const Text('Cada pareja de equipos se enfrenta dos veces'),
          value: _idaYVuelta,
          onChanged: (v) => setState(() => _idaYVuelta = v),
        ),
        espacioCampo,
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: cs.tertiary.withValues(alpha: .12), borderRadius: BorderRadius.circular(14)),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(Icons.info_outline, size: 20, color: cs.tertiary),
            const SizedBox(width: 10),
            const Expanded(child: Text('Si ya existía un calendario sin resultados, se sustituirá.')),
          ]),
        ),
      ],
    );
  }
}
