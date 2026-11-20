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
  const LigasTab({super.key, required this.escuelaId, this.orgTipo, this.coorganizador = false});
  final String escuelaId;
  final String? orgTipo; // tipo de la organización (ESCUELA, AYUNTAMIENTO, GRUPO_AMIGOS)
  final bool coorganizador; // gestiona solo algunas ligas: no crea ligas nuevas

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ligas = ref.watch(orgLigasProvider(escuelaId));
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: coorganizador
          ? null
          : FloatingActionButton.extended(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => CrearLigaPage(escuelaId: escuelaId, orgTipo: orgTipo))),
              icon: const Icon(Icons.add),
              label: const Text('Nueva liga'),
            ),
      body: AsyncView<List<Liga>>(
        value: ligas,
        onRetry: () => ref.invalidate(orgLigasProvider(escuelaId)),
        builder: (lista) => lista.isEmpty
            ? EstadoVacio(
                icono: Icons.emoji_events_outlined,
                texto: coorganizador
                    ? 'Aún no tienes ligas asignadas.'
                    : 'Aún no has creado ninguna liga.\nPulsa «Nueva liga» para empezar.')
            : RefreshIndicator(
                onRefresh: () => ref.refresh(orgLigasProvider(escuelaId).future),
                child: ListView(
                  padding: const EdgeInsets.only(top: 8, bottom: 96),
                  children: [
                    for (final l in lista)
                      _LigaCard(liga: l, escuelaId: escuelaId, orgTipo: orgTipo, coorganizador: coorganizador),
                  ],
                ),
              ),
      ),
    );
  }
}

class _LigaCard extends ConsumerWidget {
  const _LigaCard({required this.liga, required this.escuelaId, this.orgTipo, this.coorganizador = false});
  final Liga liga;
  final String escuelaId;
  final String? orgTipo;
  final bool coorganizador;

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
      if (!context.mounted) return;
      final cat = await elegirCategoria(context, repo, liga.id, liga.nombre);
      if (!cat.ok) return;
      if (cat.id == null) {
        await repo.inscribirEquipo(liga.id, elegido.id);
      } else {
        await repo.inscribirEquipo(liga.id, elegido.id, categoriaId: cat.id);
      }
      ref.invalidate(orgClasificacionProvider(liga.id));
      if (context.mounted) avisar(context, '${elegido.nombre} agregado a ${liga.nombre}.');
    } catch (e) {
      if (context.mounted) avisar(context, mensajeError(e, defecto: 'No se pudo agregar el equipo.'));
    }
  }

  Future<void> _generar(BuildContext context, WidgetRef ref) async {
    final p = await mostrarFormulario<ParamsCalendario>(
        context, (_) => GenerarCalendarioDialog(inicio: liga.fechaInicio, formato: liga.formato));
    if (p == null) return;
    final repo = ref.read(ligaRepositoryProvider);
    try {
      final String aviso;
      if (liga.esEliminatoria) {
        final n = await repo.generarEliminatoria(liga.id, inicio: p.inicio);
        aviso = 'Cuadro generado: $n encuentros en la primera ronda.';
      } else if (liga.esMixto) {
        final n = await repo.generarCalendario(liga.id,
            inicio: p.inicio, diasEntreJornadas: p.dias, vueltas: p.vueltas, grupos: p.grupos);
        aviso = 'Fase de grupos generada: $n encuentros.';
      } else {
        final n = await repo.generarCalendario(liga.id, inicio: p.inicio, diasEntreJornadas: p.dias, vueltas: p.vueltas);
        aviso = 'Calendario generado: $n encuentros.';
      }
      ref.invalidate(orgEncuentrosProvider(liga.id));
      ref.invalidate(orgByesProvider(liga.id));
      ref.invalidate(orgClasificacionProvider(liga.id));
      ref.invalidate(orgLigasProvider(escuelaId));
      if (context.mounted) avisar(context, aviso);
    } catch (e) {
      if (context.mounted) {
        avisar(context, mensajeError(e, defecto: liga.esEliminatoria ? 'No se pudo generar el cuadro.' : 'No se pudo generar el calendario.'));
      }
    }
  }

  Future<void> _generarPlayoff(BuildContext context, WidgetRef ref) async {
    final p = await mostrarFormulario<ParamsPlayoff>(context, (_) => GenerarPlayoffDialog(inicio: liga.fechaInicio));
    if (p == null) return;
    try {
      final n = await ref.read(ligaRepositoryProvider).generarPlayoff(liga.id, clasifican: p.clasifican, inicio: p.inicio);
      ref.invalidate(orgEncuentrosProvider(liga.id));
      ref.invalidate(orgByesProvider(liga.id));
      ref.invalidate(orgLigasProvider(escuelaId));
      if (context.mounted) avisar(context, 'Playoff generado: $n encuentros en la primera ronda.');
    } catch (e) {
      if (context.mounted) avisar(context, mensajeError(e, defecto: 'No se pudo generar el playoff.'));
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
          Text('${liga.deporte ?? 'Liga'} · ${etiquetaEstadoLiga(liga.estado)}${liga.formato == 'LIGA' ? '' : ' · ${etiquetaFormato(liga.formato)}'}',
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
              OutlinedButton(
                key: Key('generar-${liga.id}'),
                onPressed: () => _generar(context, ref),
                child: Text(liga.esEliminatoria ? 'Generar cuadro' : (liga.esMixto ? 'Generar grupos' : 'Generar calendario')),
              ),
            if (liga.esMixto && liga.estado == 'en_curso')
              OutlinedButton(
                key: Key('playoff-${liga.id}'),
                onPressed: () => _generarPlayoff(context, ref),
                child: const Text('Generar playoff'),
              ),
            TextButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => LigaDetallePage(liga: liga, escuelaId: escuelaId, coorganizador: coorganizador))),
              child: const Text('Ver liga'),
            ),
          ]),
        ]),
      ),
    );
  }
}

class ParamsCalendario {
  const ParamsCalendario(this.inicio, this.dias, this.vueltas, [this.grupos = 2]);
  final DateTime inicio;
  final int dias;
  final int vueltas; // 1 = solo ida, 2 = ida y vuelta
  final int grupos; // solo en formato MIXTO
}

/// Pide la fecha de inicio y lo propio del formato: días entre jornadas e ida y vuelta (liga y grupos),
/// número de grupos (MIXTO). En eliminatoria solo pide la fecha de la primera ronda.
class GenerarCalendarioDialog extends StatefulWidget {
  const GenerarCalendarioDialog({super.key, this.inicio, this.formato = 'LIGA'});
  final DateTime? inicio;
  final String formato; // LIGA | ELIMINATORIA | MIXTO
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
  final _grupos = TextEditingController(text: '2');
  bool _idaYVuelta = false;

  bool get _eliminatoria => widget.formato == 'ELIMINATORIA';
  bool get _mixto => widget.formato == 'MIXTO';

  @override
  void dispose() {
    _dias.dispose();
    _grupos.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return HojaFormulario(
      icono: _eliminatoria ? Icons.account_tree_outlined : Icons.calendar_month_rounded,
      titulo: _eliminatoria ? 'Generar cuadro' : (_mixto ? 'Generar fase de grupos' : 'Generar calendario'),
      subtitulo: _eliminatoria
          ? 'Se emparejan los equipos por orden de inscripción; las siguientes rondas se crean al terminar cada una.'
          : (_mixto
              ? 'Los equipos se reparten en grupos y cada grupo juega una liga. Después podrás generar el playoff.'
              : 'Se emparejan los equipos inscritos y se reparten las jornadas en fechas.'),
      etiquetaAccion: 'Generar',
      iconoAccion: Icons.auto_awesome_rounded,
      onAccion: () => Navigator.of(context).pop(ParamsCalendario(
        _inicio,
        (int.tryParse(_dias.text) ?? 7).clamp(1, 60),
        _idaYVuelta ? 2 : 1,
        (int.tryParse(_grupos.text) ?? 2).clamp(2, 8),
      )),
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () async {
            final f = await showDatePicker(
                context: context, initialDate: _inicio, firstDate: DateTime(2020), lastDate: DateTime(2100));
            if (f != null) setState(() => _inicio = f);
          },
          child: InputDecorator(
            decoration: decoracionCampo(_eliminatoria ? 'Primera ronda' : 'Primera jornada', Icons.event,
                sufijo: const Icon(Icons.expand_more)),
            child: Text(fechaLarga(_inicio)),
          ),
        ),
        if (_mixto) ...[
          espacioCampo,
          TextField(
            key: const Key('generar-grupos'),
            controller: _grupos,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: decoracionCampo('Número de grupos', Icons.view_module_outlined, ayuda: '2'),
          ),
        ],
        if (!_eliminatoria) ...[
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
        ],
        espacioCampo,
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: cs.tertiary.withValues(alpha: .12), borderRadius: BorderRadius.circular(14)),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(Icons.info_outline, size: 20, color: cs.tertiary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(_eliminatoria
                  ? 'Si el número de equipos no es potencia de 2, los primeros por orden de inscripción pasan directamente a la segunda ronda. Si ya había un cuadro sin resultados, se sustituirá.'
                  : 'Si ya existía un calendario sin resultados, se sustituirá.'),
            ),
          ]),
        ),
      ],
    );
  }
}

class ParamsPlayoff {
  const ParamsPlayoff(this.inicio, this.clasifican);
  final DateTime? inicio;
  final int clasifican; // equipos que pasan por cada grupo
}

/// Playoff de un formato MIXTO: cuántos equipos de cada grupo pasan y desde qué fecha se juega.
class GenerarPlayoffDialog extends StatefulWidget {
  const GenerarPlayoffDialog({super.key, this.inicio});
  final DateTime? inicio;
  @override
  State<GenerarPlayoffDialog> createState() => _GenerarPlayoffDialogState();
}

class _GenerarPlayoffDialogState extends State<GenerarPlayoffDialog> {
  late DateTime _inicio = widget.inicio ??
      () {
        final h = DateTime.now();
        return DateTime(h.year, h.month, h.day);
      }();
  final _clasifican = TextEditingController(text: '2');

  @override
  void dispose() {
    _clasifican.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => HojaFormulario(
        icono: Icons.account_tree_outlined,
        titulo: 'Generar playoff',
        subtitulo: 'Los mejores de cada grupo juegan un cuadro de eliminatoria. Requiere la fase de grupos terminada.',
        etiquetaAccion: 'Generar',
        iconoAccion: Icons.auto_awesome_rounded,
        onAccion: () =>
            Navigator.of(context).pop(ParamsPlayoff(_inicio, (int.tryParse(_clasifican.text) ?? 2).clamp(1, 8))),
        children: [
          TextField(
            key: const Key('playoff-clasifican'),
            controller: _clasifican,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: decoracionCampo('Clasificados por grupo', Icons.emoji_events_outlined, ayuda: '2'),
          ),
          espacioCampo,
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () async {
              final f = await showDatePicker(
                  context: context, initialDate: _inicio, firstDate: DateTime(2020), lastDate: DateTime(2100));
              if (f != null) setState(() => _inicio = f);
            },
            child: InputDecorator(
              decoration: decoracionCampo('Primera ronda', Icons.event, sufijo: const Icon(Icons.expand_more)),
              child: Text(fechaLarga(_inicio)),
            ),
          ),
        ],
      );
}
