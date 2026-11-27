import '../../core/idioma.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ligaria_ui/ligaria_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/widgets.dart';
import '../../data/liga_repository.dart';
import '../../data/models.dart';
import 'organizador_providers.dart';
import 'plantillas_liga.dart';

/// Alta y edición (solo en borrador) de una liga: nombre, deporte, tipo y fechas.
/// El calendario se genera después, cuando ya están inscritos los equipos.
class CrearLigaPage extends ConsumerStatefulWidget {
  const CrearLigaPage({
    super.key,
    required this.escuelaId,
    this.orgTipo,
    this.liga,
  });
  final String escuelaId;
  final String?
  orgTipo; // tipo de la organización organizadora (decide los tipos de competición posibles)
  final Liga? liga; // si viene, se edita

  @override
  ConsumerState<CrearLigaPage> createState() => _CrearLigaPageState();
}

class _CrearLigaPageState extends ConsumerState<CrearLigaPage> {
  final _form = GlobalKey<FormState>();
  late final _nombre = TextEditingController(text: widget.liga?.nombre ?? '');
  late String _deporteId =
      widget.liga?.deporteId ?? deportesDisponibles.first.id;
  late String _tipo =
      widget.liga?.tipo ?? tiposCompeticionDe(widget.orgTipo).first.codigo;
  late String _formato = widget.liga?.formato ?? 'LIGA';
  late String _visibilidad = widget.liga?.visibilidad ?? 'PUBLICA';
  late final _pVictoria = TextEditingController(
    text: '${(widget.liga?.puntuacion ?? puntuacionPorDefecto).victoria}',
  );
  late final _pEmpate = TextEditingController(
    text: '${(widget.liga?.puntuacion ?? puntuacionPorDefecto).empate}',
  );
  late final _pDerrota = TextEditingController(
    text: '${(widget.liga?.puntuacion ?? puntuacionPorDefecto).derrota}',
  );
  String? _errorPuntos;
  late DateTime? _inicio = widget.liga?.fechaInicio;
  late DateTime? _fin = widget.liga?.fechaFin;
  String? _errorFechas;
  bool _enviando = false;

  bool get _edita => widget.liga != null;

  /// La visibilidad solo aplica a ligas que admiten escuelas de fuera.
  bool get _admiteExternas => _tipo == 'MUNICIPAL' || _tipo == 'ENTRE_ESCUELAS';

  @override
  void dispose() {
    _nombre.dispose();
    _pVictoria.dispose();
    _pEmpate.dispose();
    _pDerrota.dispose();
    super.dispose();
  }

  /// Puntuación escrita en el formulario, o null (con el error ya mostrado) si no es válida.
  Puntuacion? _leerPuntuacion() {
    if (_formato == 'ELIMINATORIA') {
      return widget.liga?.puntuacion ?? puntuacionPorDefecto; // no puntúa
    }
    final v = int.tryParse(_pVictoria.text.trim());
    final e = int.tryParse(_pEmpate.text.trim());
    final d = int.tryParse(_pDerrota.text.trim());
    String? error;
    if (v == null || e == null || d == null) {
      error = context.l10n.errPuntosNumero;
    } else if (v > 20 || e < 0 || d < 0 || !(v >= e && e >= d)) {
      error = context.l10n.errPuntosOrden;
    }
    setState(() => _errorPuntos = error);
    return error != null ? null : (victoria: v!, empate: e!, derrota: d!);
  }

  Future<void> _elegir(bool inicio) async {
    final base = (inicio ? _inicio : _fin) ?? _inicio ?? DateTime.now();
    final f = await showDatePicker(
      context: context,
      initialDate: base,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (f != null) {
      setState(() {
        if (inicio) {
          _inicio = f;
        } else {
          _fin = f;
        }
        _errorFechas = null;
      });
    }
  }

  Future<void> _guardar() async {
    if (!_form.currentState!.validate()) return;
    if (_inicio != null && _fin != null && _fin!.isBefore(_inicio!)) {
      setState(() => _errorFechas = context.l10n.errFechaFin);
      return;
    }
    final puntos = _leerPuntuacion();
    if (puntos == null) return;
    setState(() => _enviando = true);
    final repo = ref.read(ligaRepositoryProvider);
    try {
      if (_edita) {
        await repo.editarLiga(
          widget.liga!.id,
          nombre: _nombre.text.trim(),
          fechaInicio: _inicio,
          fechaFin: _fin,
        );
        if (puntos != widget.liga!.puntuacion) {
          await repo.configurarPuntuacion(widget.liga!.id, puntos);
        }
      } else {
        await repo.crearLiga(
          orgId: widget.escuelaId,
          deporteId: _deporteId,
          nombre: _nombre.text.trim(),
          tipo: _tipo,
          fechaInicio: _inicio,
          fechaFin: _fin,
          visibilidad: _admiteExternas ? _visibilidad : 'PUBLICA',
          puntuacion: puntos,
          formato: _formato,
        );
      }
      ref.invalidate(orgLigasProvider(widget.escuelaId));
      if (!mounted) return;
      avisar(
        context,
        _edita ? context.l10n.ligaActualizada : context.l10n.ligaCreada,
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() => _enviando = false);
        avisar(context, mensajeError(e, defecto: context.l10n.errGuardarLiga));
      }
    }
  }

  Widget _campoFecha(String etiqueta, DateTime? valor, bool inicio) => InkWell(
    borderRadius: BorderRadius.circular(14),
    onTap: () => _elegir(inicio),
    child: InputDecorator(
      decoration: decoracionCampo(
        etiqueta,
        Icons.event_rounded,
        sufijo: valor == null
            ? const Icon(Icons.expand_more_rounded)
            : IconButton(
                tooltip: context.l10n.quitarFecha,
                icon: const Icon(Icons.close_rounded, size: 20),
                onPressed: () => setState(() {
                  if (inicio) {
                    _inicio = null;
                  } else {
                    _fin = null;
                  }
                  _errorFechas = null;
                }),
              ),
      ),
      child: Text(valor == null ? context.l10n.sinFecha : fechaLarga(valor)),
    ),
  );

  String? _plantilla;

  /// Rellena nombre, formato y fechas con la plantilla; todo sigue siendo editable.
  void _aplicarPlantilla(PlantillaLiga p) {
    final (ini, fin) = p.fechas(DateTime.now());
    setState(() {
      _plantilla = p.id;
      _nombre.text = p.nombre(context.l10n, ini.year);
      _formato = p.formato;
      _inicio = ini;
      _fin = fin;
      _errorFechas = null;
      _errorPuntos = null;
    });
  }

  Widget _plantillas(BuildContext context) {
    final l = context.l10n;
    final elegida = plantillasLiga.where((p) => p.id == _plantilla).firstOrNull;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final p in plantillasLiga)
              ChoiceChip(
                key: Key('plantilla-${p.id}'),
                avatar: Icon(switch (p.formato) {
                  'ELIMINATORIA' => Icons.account_tree_outlined,
                  'MIXTO' => Icons.view_module_outlined,
                  _ => Icons.format_list_numbered_rounded,
                }, size: 18),
                label: Text(p.nombre(l, p.fechas(DateTime.now()).$1.year)),
                selected: _plantilla == p.id,
                onSelected: (_) => _aplicarPlantilla(p),
              ),
          ],
        ),
        if (elegida != null) ...[
          const SizedBox(height: 10),
          Text(
            elegida.descripcion(l),
            key: const Key('plantilla-descripcion'),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ],
    );
  }

  /// Los selectores no se pueden cambiar al editar (deporte y tipo quedan fijados al crear la liga).
  Widget _bloqueable(Widget hijo) =>
      _edita ? Opacity(opacity: .55, child: IgnorePointer(child: hijo)) : hijo;

  static IconData _iconoTipo(String codigo) => switch (codigo) {
    'ENTRE_ESCUELAS' => Icons.public_rounded,
    'ESCUELA' => Icons.school_outlined,
    'MUNICIPAL' => Icons.location_city_rounded,
    'AMIGOS' => Icons.groups_rounded,
    _ => Icons.category_outlined,
  };

  static String? _descripcionTipo(String codigo) => switch (codigo) {
    'ENTRE_ESCUELAS' => l10nActual.descEntreEscuelas,
    'ESCUELA' => l10nActual.descSoloEscuela,
    _ => null,
  };

  @override
  Widget build(BuildContext context) {
    final tipos = tiposCompeticionDe(widget.orgTipo);
    final ancho = MediaQuery.sizeOf(context).width;
    final ampli = ancho >= Pantalla.compacta;
    final lateral = ancho >= Pantalla.media ? 32.0 : 16.0;

    final fechas = ampli
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _campoFecha(context.l10n.fechaInicio, _inicio, true),
              ),
              const SizedBox(width: 14),
              Expanded(child: _campoFecha(context.l10n.fechaFin, _fin, false)),
            ],
          )
        : Column(
            children: [
              _campoFecha(context.l10n.fechaInicio, _inicio, true),
              const SizedBox(height: 14),
              _campoFecha(context.l10n.fechaFin, _fin, false),
            ],
          );

    final boton = FilledButton(
      onPressed: _enviando ? null : _guardar,
      style: FilledButton.styleFrom(minimumSize: const Size(64, 54)),
      child: _enviando
          ? const SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(strokeWidth: 2.5, color: tinta),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _edita ? Icons.check_rounded : Icons.add_rounded,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    _edita
                        ? context.l10n.guardarCambios
                        : context.l10n.crearLiga,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(_edita ? context.l10n.editarLiga : context.l10n.nuevaLiga),
      ),
      // En móvil el botón queda fijo abajo; en pantallas anchas va al final del formulario.
      bottomNavigationBar: ampli
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: boton,
              ),
            ),
      body: Form(
        key: _form,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(lateral, 16, lateral, 32),
          child: ContenidoCentrado(
            maxAncho: 760,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Aparece(desplazamiento: 8, child: _Cabecera(edita: _edita)),
                const SizedBox(height: 16),
                if (!_edita) ...[
                  Aparece(
                    retardo: 30,
                    desplazamiento: 8,
                    child: _Seccion(
                      icono: Icons.auto_awesome_outlined,
                      titulo: context.l10n.plantillasTitulo,
                      nota: context.l10n.plantillasNota,
                      hijo: _plantillas(context),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Aparece(
                  retardo: 60,
                  desplazamiento: 8,
                  child: _Seccion(
                    icono: Icons.edit_note_rounded,
                    titulo: context.l10n.datosBasicos,
                    hijo: TextFormField(
                      controller: _nombre,
                      autofocus: !_edita && ampli,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: decoracionCampo(
                        context.l10n.nombreLiga,
                        Icons.emoji_events_outlined,
                        ayuda: context.l10n.ejLiga,
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? context.l10n.introduceNombre
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Aparece(
                  retardo: 120,
                  desplazamiento: 8,
                  child: _Seccion(
                    icono: Icons.sports_tennis_rounded,
                    titulo: context.l10n.deporteFormatoAcceso,
                    nota: _edita ? context.l10n.noCambiarLiga : null,
                    hijo: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _bloqueable(
                          SelectorTarjetas<String>(
                            key: const Key('liga-deporte'),
                            etiqueta: context.l10n.deporte,
                            valor: _deporteId,
                            onCambio: (v) => setState(() => _deporteId = v),
                            opciones: [
                              for (final d in deportesDisponibles)
                                OpcionTarjeta<String>(
                                  d.id,
                                  nombreDeporte(d.nombre),
                                  d.id == 'TENIS'
                                      ? Icons.sports_tennis_rounded
                                      : Icons.sports_baseball_rounded,
                                ),
                            ],
                          ),
                        ),
                        if (tipos.length > 1) ...[
                          const SizedBox(height: 20),
                          _bloqueable(
                            SelectorTarjetas<String>(
                              key: const Key('liga-tipo'),
                              etiqueta: context.l10n.tipoLiga,
                              valor: tipos.any((t) => t.codigo == _tipo)
                                  ? _tipo
                                  : tipos.first.codigo,
                              onCambio: (v) => setState(() => _tipo = v),
                              opciones: [
                                for (final t in tipos)
                                  OpcionTarjeta<String>(
                                    t.codigo,
                                    t.etiqueta.split(' (').first,
                                    _iconoTipo(t.codigo),
                                    descripcion: _descripcionTipo(t.codigo),
                                  ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),
                        _bloqueable(
                          SelectorTarjetas<String>(
                            key: const Key('liga-formato'),
                            etiqueta: context.l10n.formatoCompeticion,
                            valor: _formato,
                            onCambio: (v) => setState(() {
                              _formato = v;
                              _errorPuntos = null;
                            }),
                            opciones: [
                              OpcionTarjeta<String>(
                                'LIGA',
                                context.l10n.fmtLiga,
                                Icons.format_list_numbered_rounded,
                                descripcion: context.l10n.fmtLigaDesc,
                              ),
                              OpcionTarjeta<String>(
                                'ELIMINATORIA',
                                context.l10n.fmtEliminatoria,
                                Icons.account_tree_outlined,
                                descripcion: context.l10n.fmtEliminatoriaDesc,
                              ),
                              OpcionTarjeta<String>(
                                'MIXTO',
                                context.l10n.fmtMixto,
                                Icons.view_module_outlined,
                                descripcion: context.l10n.fmtMixtoDesc,
                              ),
                            ],
                          ),
                        ),
                        if (_admiteExternas) ...[
                          const SizedBox(height: 20),
                          _bloqueable(
                            SelectorTarjetas<String>(
                              key: const Key('liga-visibilidad'),
                              etiqueta: context.l10n.quienParticipa,
                              valor: _visibilidad,
                              onCambio: (v) => setState(() => _visibilidad = v),
                              opciones: [
                                OpcionTarjeta<String>(
                                  'PUBLICA',
                                  context.l10n.visAbierta,
                                  Icons.lock_open_rounded,
                                  descripcion: context.l10n.visAbiertaDesc,
                                ),
                                OpcionTarjeta<String>(
                                  'PRIVADA',
                                  context.l10n.visPrivada,
                                  Icons.mark_email_read_outlined,
                                  descripcion: context.l10n.visPrivadaDesc,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                if (_formato != 'ELIMINATORIA') ...[
                  const SizedBox(height: 16),
                  Aparece(
                    retardo: 150,
                    desplazamiento: 8,
                    child: _Seccion(
                      icono: Icons.scoreboard_outlined,
                      titulo: context.l10n.puntuacion,
                      nota: _formato == 'MIXTO'
                          ? context.l10n.puntuacionNotaMixto
                          : context.l10n.puntuacionNota,
                      hijo: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (final (clave, etiqueta, ctrl) in [
                                ('victoria', context.l10n.victoria, _pVictoria),
                                ('empate', context.l10n.empate, _pEmpate),
                                ('derrota', context.l10n.derrota, _pDerrota),
                              ]) ...[
                                Expanded(
                                  child: TextFormField(
                                    key: Key('puntos-$clave'),
                                    controller: ctrl,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    decoration: decoracionCampo(
                                      etiqueta,
                                      Icons.exposure_plus_1_rounded,
                                    ),
                                    onChanged: (_) {
                                      if (_errorPuntos != null) {
                                        setState(() => _errorPuntos = null);
                                      }
                                    },
                                  ),
                                ),
                                if (clave != 'derrota')
                                  const SizedBox(width: 12),
                              ],
                            ],
                          ),
                          if (_errorPuntos != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.error_outline_rounded,
                                    size: 18,
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _errorPuntos!,
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.error,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Aparece(
                  retardo: 180,
                  desplazamiento: 8,
                  child: _Seccion(
                    icono: Icons.calendar_month_rounded,
                    titulo: context.l10n.fechas,
                    nota: context.l10n.opcionalesFechas,
                    hijo: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        fechas,
                        if (_errorFechas != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.error_outline_rounded,
                                  size: 18,
                                  color: Theme.of(context).colorScheme.error,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _errorFechas!,
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.error,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                if (ampli) ...[
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: _enviando
                            ? null
                            : () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(120, 54),
                        ),
                        child: Text(context.l10n.cancelar),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(width: 260, child: boton),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Cabecera con degradado: explica en una frase qué se está haciendo.
class _Cabecera extends StatelessWidget {
  const _Cabecera({required this.edita});
  final bool edita;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            acentoDe(context).withValues(alpha: .18),
            acentoSuaveDe(context).withValues(alpha: .05),
          ],
        ),
        border: Border.all(color: Marca.de(context).borde),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [acentoDe(context), acentoSuaveDe(context)],
              ),
              boxShadow: [
                BoxShadow(
                  color: acentoDe(context).withValues(alpha: .35),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(
              edita ? Icons.edit_rounded : Icons.emoji_events_rounded,
              color: tinta,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  edita ? context.l10n.ajustaLiga : context.l10n.creaLiga,
                  style: t.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: -.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  edita
                      ? context.l10n.ajustaLigaAyuda
                      : context.l10n.creaLigaAyuda,
                  style: t.textTheme.bodyMedium?.copyWith(
                    color: t.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Bloque con título e icono que agrupa campos relacionados.
class _Seccion extends StatelessWidget {
  const _Seccion({
    required this.icono,
    required this.titulo,
    required this.hijo,
    this.nota,
  });
  final IconData icono;
  final String titulo;
  final String? nota;
  final Widget hijo;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(icono, size: 20, color: t.colorScheme.primary),
                const SizedBox(width: 10),
                Text(
                  titulo,
                  style: t.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            if (nota != null) ...[
              const SizedBox(height: 4),
              Text(
                nota!,
                style: t.textTheme.bodySmall?.copyWith(
                  color: t.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 16),
            hijo,
          ],
        ),
      ),
    );
  }
}
