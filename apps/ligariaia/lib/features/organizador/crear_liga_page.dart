import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ligaria_ui/ligaria_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/widgets.dart';
import '../../data/liga_repository.dart';
import '../../data/models.dart';
import 'organizador_providers.dart';

/// Alta y edición (solo en borrador) de una liga: nombre, deporte, tipo y fechas.
/// El calendario se genera después, cuando ya están inscritos los equipos.
class CrearLigaPage extends ConsumerStatefulWidget {
  const CrearLigaPage({super.key, required this.escuelaId, this.orgTipo, this.liga});
  final String escuelaId;
  final String? orgTipo; // tipo de la organización organizadora (decide los tipos de competición posibles)
  final Liga? liga; // si viene, se edita

  @override
  ConsumerState<CrearLigaPage> createState() => _CrearLigaPageState();
}

class _CrearLigaPageState extends ConsumerState<CrearLigaPage> {
  final _form = GlobalKey<FormState>();
  late final _nombre = TextEditingController(text: widget.liga?.nombre ?? '');
  late String _deporteId = widget.liga?.deporteId ?? deportesDisponibles.first.id;
  late String _tipo = widget.liga?.tipo ?? tiposCompeticionDe(widget.orgTipo).first.codigo;
  late String _formato = widget.liga?.formato ?? 'LIGA';
  late String _visibilidad = widget.liga?.visibilidad ?? 'PUBLICA';
  late final _pVictoria = TextEditingController(text: '${(widget.liga?.puntuacion ?? puntuacionPorDefecto).victoria}');
  late final _pEmpate = TextEditingController(text: '${(widget.liga?.puntuacion ?? puntuacionPorDefecto).empate}');
  late final _pDerrota = TextEditingController(text: '${(widget.liga?.puntuacion ?? puntuacionPorDefecto).derrota}');
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
    if (_formato == 'ELIMINATORIA') return widget.liga?.puntuacion ?? puntuacionPorDefecto; // no puntúa
    final v = int.tryParse(_pVictoria.text.trim());
    final e = int.tryParse(_pEmpate.text.trim());
    final d = int.tryParse(_pDerrota.text.trim());
    String? error;
    if (v == null || e == null || d == null) {
      error = 'Escribe un número en los tres campos.';
    } else if (v > 20 || e < 0 || d < 0 || !(v >= e && e >= d)) {
      error = 'Debe cumplirse victoria ≥ empate ≥ derrota ≥ 0 (máximo 20).';
    }
    setState(() => _errorPuntos = error);
    return error != null ? null : (victoria: v!, empate: e!, derrota: d!);
  }

  Future<void> _elegir(bool inicio) async {
    final base = (inicio ? _inicio : _fin) ?? _inicio ?? DateTime.now();
    final f = await showDatePicker(
        context: context, initialDate: base, firstDate: DateTime(2020), lastDate: DateTime(2100));
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
      setState(() => _errorFechas = 'La fecha de fin no puede ser anterior a la de inicio.');
      return;
    }
    final puntos = _leerPuntuacion();
    if (puntos == null) return;
    setState(() => _enviando = true);
    final repo = ref.read(ligaRepositoryProvider);
    try {
      if (_edita) {
        await repo.editarLiga(widget.liga!.id, nombre: _nombre.text.trim(), fechaInicio: _inicio, fechaFin: _fin);
        if (puntos != widget.liga!.puntuacion) await repo.configurarPuntuacion(widget.liga!.id, puntos);
      } else {
        await repo.crearLiga(
          orgId: widget.escuelaId, deporteId: _deporteId, nombre: _nombre.text.trim(), tipo: _tipo,
          fechaInicio: _inicio, fechaFin: _fin,
          visibilidad: _admiteExternas ? _visibilidad : 'PUBLICA',
          puntuacion: puntos,
          formato: _formato,
        );
      }
      ref.invalidate(orgLigasProvider(widget.escuelaId));
      if (!mounted) return;
      avisar(context, _edita ? 'Liga actualizada.' : 'Liga creada. Publícala para abrir la inscripción.');
      Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() => _enviando = false);
        avisar(context, mensajeError(e, defecto: 'No se pudo guardar la liga.'));
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
                    tooltip: 'Quitar fecha',
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
          child: Text(valor == null ? 'Sin fecha' : fechaLarga(valor)),
        ),
      );

  /// Los selectores no se pueden cambiar al editar (deporte y tipo quedan fijados al crear la liga).
  Widget _bloqueable(Widget hijo) => _edita ? Opacity(opacity: .55, child: IgnorePointer(child: hijo)) : hijo;

  static IconData _iconoTipo(String codigo) => switch (codigo) {
        'ENTRE_ESCUELAS' => Icons.public_rounded,
        'ESCUELA' => Icons.school_outlined,
        'MUNICIPAL' => Icons.location_city_rounded,
        'AMIGOS' => Icons.groups_rounded,
        _ => Icons.category_outlined,
      };

  static String? _descripcionTipo(String codigo) => switch (codigo) {
        'ENTRE_ESCUELAS' => 'Otras escuelas pueden inscribir equipos.',
        'ESCUELA' => 'Solo participan equipos de tu escuela.',
        _ => null,
      };

  @override
  Widget build(BuildContext context) {
    final tipos = tiposCompeticionDe(widget.orgTipo);
    final ancho = MediaQuery.sizeOf(context).width;
    final ampli = ancho >= Pantalla.compacta;
    final lateral = ancho >= Pantalla.media ? 32.0 : 16.0;

    final fechas = ampli
        ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: _campoFecha('Fecha de inicio', _inicio, true)),
            const SizedBox(width: 14),
            Expanded(child: _campoFecha('Fecha de fin', _fin, false)),
          ])
        : Column(children: [
            _campoFecha('Fecha de inicio', _inicio, true),
            const SizedBox(height: 14),
            _campoFecha('Fecha de fin', _fin, false),
          ]);

    final boton = FilledButton(
      onPressed: _enviando ? null : _guardar,
      style: FilledButton.styleFrom(minimumSize: const Size(64, 54)),
      child: _enviando
          ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: tinta))
          : Row(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [
              Icon(_edita ? Icons.check_rounded : Icons.add_rounded, size: 22),
              const SizedBox(width: 8),
              Flexible(child: Text(_edita ? 'Guardar cambios' : 'Crear liga', overflow: TextOverflow.ellipsis, maxLines: 1)),
            ]),
    );

    return Scaffold(
      appBar: AppBar(title: Text(_edita ? 'Editar liga' : 'Nueva liga')),
      // En móvil el botón queda fijo abajo; en pantallas anchas va al final del formulario.
      bottomNavigationBar: ampli
          ? null
          : SafeArea(
              child: Padding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 12), child: boton),
            ),
      body: Form(
        key: _form,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(lateral, 16, lateral, 32),
          child: ContenidoCentrado(
            maxAncho: 760,
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Aparece(desplazamiento: 8, child: _Cabecera(edita: _edita)),
              const SizedBox(height: 16),
              Aparece(
                retardo: 60,
                desplazamiento: 8,
                child: _Seccion(
                  icono: Icons.edit_note_rounded,
                  titulo: 'Datos básicos',
                  hijo: TextFormField(
                    controller: _nombre,
                    autofocus: !_edita && ampli,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: decoracionCampo('Nombre de la liga', Icons.emoji_events_outlined,
                        ayuda: 'Ej.: Liga infantil 2026'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Introduce el nombre' : null,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Aparece(
                retardo: 120,
                desplazamiento: 8,
                child: _Seccion(
                  icono: Icons.sports_tennis_rounded,
                  titulo: 'Deporte, formato y acceso',
                  nota: _edita ? 'El deporte, el tipo, el formato y el acceso no se pueden cambiar una vez creada la liga.' : null,
                  hijo: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    _bloqueable(SelectorTarjetas<String>(
                      key: const Key('liga-deporte'),
                      etiqueta: 'Deporte',
                      valor: _deporteId,
                      onCambio: (v) => setState(() => _deporteId = v),
                      opciones: [
                        for (final d in deportesDisponibles)
                          OpcionTarjeta<String>(
                              d.id, d.nombre, d.id == 'TENIS' ? Icons.sports_tennis_rounded : Icons.sports_baseball_rounded),
                      ],
                    )),
                    if (tipos.length > 1) ...[
                      const SizedBox(height: 20),
                      _bloqueable(SelectorTarjetas<String>(
                        key: const Key('liga-tipo'),
                        etiqueta: 'Tipo de liga',
                        valor: tipos.any((t) => t.codigo == _tipo) ? _tipo : tipos.first.codigo,
                        onCambio: (v) => setState(() => _tipo = v),
                        opciones: [
                          for (final t in tipos)
                            OpcionTarjeta<String>(t.codigo, t.etiqueta.split(' (').first, _iconoTipo(t.codigo),
                                descripcion: _descripcionTipo(t.codigo)),
                        ],
                      )),
                    ],
                    const SizedBox(height: 20),
                    _bloqueable(SelectorTarjetas<String>(
                      key: const Key('liga-formato'),
                      etiqueta: 'Formato de competición',
                      valor: _formato,
                      onCambio: (v) => setState(() {
                        _formato = v;
                        _errorPuntos = null;
                      }),
                      opciones: const [
                        OpcionTarjeta<String>('LIGA', 'Liga', Icons.format_list_numbered_rounded,
                            descripcion: 'Todos contra todos, por jornadas.'),
                        OpcionTarjeta<String>('ELIMINATORIA', 'Eliminatoria', Icons.account_tree_outlined,
                            descripcion: 'Cuadro por rondas: quien pierde queda fuera.'),
                        OpcionTarjeta<String>('MIXTO', 'Grupos y playoff', Icons.view_module_outlined,
                            descripcion: 'Liga por grupos y un cuadro final con los mejores.'),
                      ],
                    )),
                    if (_admiteExternas) ...[
                      const SizedBox(height: 20),
                      _bloqueable(SelectorTarjetas<String>(
                        key: const Key('liga-visibilidad'),
                        etiqueta: 'Quién puede participar',
                        valor: _visibilidad,
                        onCambio: (v) => setState(() => _visibilidad = v),
                        opciones: const [
                          OpcionTarjeta<String>('PUBLICA', 'Abierta', Icons.lock_open_rounded,
                              descripcion: 'Cualquier escuela la ve y solicita inscribir; tú apruebas.'),
                          OpcionTarjeta<String>('PRIVADA', 'Por invitación', Icons.mark_email_read_outlined,
                              descripcion: 'Solo participan las escuelas que invites y acepten.'),
                        ],
                      )),
                    ],
                  ]),
                ),
              ),
              if (_formato != 'ELIMINATORIA') ...[
              const SizedBox(height: 16),
              Aparece(
                retardo: 150,
                desplazamiento: 8,
                child: _Seccion(
                  icono: Icons.scoreboard_outlined,
                  titulo: 'Puntuación',
                  nota: _formato == 'MIXTO'
                      ? 'Puntos por encuentro en la fase de grupos. Lo habitual es 3, 1 y 0.'
                      : 'Puntos que suma un equipo por cada encuentro. Lo habitual es 3, 1 y 0.',
                  hijo: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      for (final (clave, etiqueta, ctrl) in [
                        ('victoria', 'Victoria', _pVictoria),
                        ('empate', 'Empate', _pEmpate),
                        ('derrota', 'Derrota', _pDerrota),
                      ]) ...[
                        Expanded(
                          child: TextFormField(
                            key: Key('puntos-$clave'),
                            controller: ctrl,
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            decoration: decoracionCampo(etiqueta, Icons.exposure_plus_1_rounded),
                            onChanged: (_) {
                              if (_errorPuntos != null) setState(() => _errorPuntos = null);
                            },
                          ),
                        ),
                        if (clave != 'derrota') const SizedBox(width: 12),
                      ],
                    ]),
                    if (_errorPuntos != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Row(children: [
                          Icon(Icons.error_outline_rounded, size: 18, color: Theme.of(context).colorScheme.error),
                          const SizedBox(width: 8),
                          Expanded(child: Text(_errorPuntos!, style: TextStyle(color: Theme.of(context).colorScheme.error))),
                        ]),
                      ),
                  ]),
                ),
              ),
              ],
              const SizedBox(height: 16),
              Aparece(
                retardo: 180,
                desplazamiento: 8,
                child: _Seccion(
                  icono: Icons.calendar_month_rounded,
                  titulo: 'Fechas',
                  nota: 'Opcionales. Puedes definirlas más tarde.',
                  hijo: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    fechas,
                    if (_errorFechas != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Row(children: [
                          Icon(Icons.error_outline_rounded, size: 18, color: Theme.of(context).colorScheme.error),
                          const SizedBox(width: 8),
                          Expanded(
                              child: Text(_errorFechas!, style: TextStyle(color: Theme.of(context).colorScheme.error))),
                        ]),
                      ),
                  ]),
                ),
              ),
              if (ampli) ...[
                const SizedBox(height: 24),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  OutlinedButton(
                    onPressed: _enviando ? null : () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(minimumSize: const Size(120, 54)),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(width: 260, child: boton),
                ]),
              ],
            ]),
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
          colors: [lima.withValues(alpha: .18), menta.withValues(alpha: .05)],
        ),
        border: Border.all(color: Marca.de(context).borde),
      ),
      child: Row(children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [lima, menta]),
            boxShadow: [BoxShadow(color: lima.withValues(alpha: .35), blurRadius: 18, offset: const Offset(0, 6))],
          ),
          child: Icon(edita ? Icons.edit_rounded : Icons.emoji_events_rounded, color: tinta, size: 30),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(edita ? 'Ajusta tu liga' : 'Crea tu liga',
                style: t.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -.4)),
            const SizedBox(height: 4),
            Text(
              edita
                  ? 'Mientras esté en borrador puedes cambiar el nombre y las fechas.'
                  : 'Define lo básico. El calendario se genera cuando haya equipos inscritos.',
              style: t.textTheme.bodyMedium?.copyWith(color: t.colorScheme.onSurfaceVariant),
            ),
          ]),
        ),
      ]),
    );
  }
}

/// Bloque con título e icono que agrupa campos relacionados.
class _Seccion extends StatelessWidget {
  const _Seccion({required this.icono, required this.titulo, required this.hijo, this.nota});
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
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            Icon(icono, size: 20, color: t.colorScheme.primary),
            const SizedBox(width: 10),
            Text(titulo, style: t.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          ]),
          if (nota != null) ...[
            const SizedBox(height: 4),
            Text(nota!, style: t.textTheme.bodySmall?.copyWith(color: t.colorScheme.onSurfaceVariant)),
          ],
          const SizedBox(height: 16),
          hijo,
        ]),
      ),
    );
  }
}
