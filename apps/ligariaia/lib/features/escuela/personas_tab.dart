import 'package:flutter/material.dart';
import 'package:ligaria_ui/ligaria_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/auth.dart';
import '../../core/idioma.dart';
import '../../core/widgets.dart';
import '../../data/categoria_edad.dart';
import '../../data/liga_repository.dart';
import '../../data/tutores_repository.dart';
import '../../data/models.dart';
import 'escuela_providers.dart';
import 'importar_dialog.dart';
import 'invitar_dialog.dart';

/// Tutores de todos los jugadores de la escuela. Si no se pueden leer (p. ej. sin la migración), se muestra la lista sin ellos.
final tutoresOrgProvider = FutureProvider.autoDispose
    .family<Map<String, List<TutorJugador>>, String>((ref, escuelaId) async {
      final jugadores = await ref.watch(jugadoresOrgProvider(escuelaId).future);
      try {
        return await ref.watch(tutoresRepositoryProvider).tutoresDe([
          for (final j in jugadores) j.id,
        ]);
      } catch (_) {
        return const {};
      }
    });

class PersonasTab extends ConsumerWidget {
  const PersonasTab({super.key, required this.escuelaId});
  final String escuelaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final datos = ref.watch(jugadoresOrgProvider(escuelaId));
    final tutores =
        ref.watch(tutoresOrgProvider(escuelaId)).value ??
        const <String, List<TutorJugador>>{};
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _nueva(context, ref),
        icon: const Icon(Icons.add),
        label: Text(context.l10n.nuevaPersona),
      ),
      body: Column(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
              child: TextButton.icon(
                key: const Key('importar-lista'),
                onPressed: () => _importar(context, ref),
                icon: const Icon(Icons.upload_file_outlined),
                label: Text(context.l10n.importarLista),
              ),
            ),
          ),
          Expanded(
            child: AsyncView<List<JugadorLite>>(
              value: datos,
              onRetry: () => ref.invalidate(jugadoresOrgProvider(escuelaId)),
              builder: (lista) => lista.isEmpty
                  ? EstadoVacio(
                      icono: Icons.child_care,
                      texto: context.l10n.sinJugadores,
                    )
                  : RefreshIndicator(
                      onRefresh: () async =>
                          ref.invalidate(jugadoresOrgProvider(escuelaId)),
                      child: ListView(
                        padding: const EdgeInsets.only(bottom: 88),
                        children: [
                          for (final p in lista)
                            _fila(context, ref, p, tutores[p.id] ?? const []),
                        ],
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _importar(BuildContext context, WidgetRef ref) async {
    final alguno = await mostrarImportarJugadores(context, escuelaId);
    if (alguno) {
      ref.invalidate(jugadoresOrgProvider(escuelaId));
      ref.invalidate(tutoresOrgProvider(escuelaId));
    }
  }

  Widget _fila(
    BuildContext context,
    WidgetRef ref,
    JugadorLite p,
    List<TutorJugador> tutores,
  ) {
    final nac = p.fechaNacimiento;
    final t = Theme.of(context);
    final cs = t.colorScheme;
    return ListTile(
      isThreeLine: tutores.isNotEmpty,
      leading: const CircleAvatar(child: Icon(Icons.person_outline)),
      title: Row(
        children: [
          Flexible(
            child: Text(p.nombreCompleto, overflow: TextOverflow.ellipsis),
          ),
          if (nac != null) ...[
            const SizedBox(width: 8),
            Insignia(categoriaPorEdad(nac), color: cs.primary),
          ],
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            nac == null
                ? context.l10n.sinFechaNac
                : context.l10n.edadYFecha(edadDe(nac), fechaLarga(nac)),
          ),
          for (final x in tutores)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 4,
                children: [
                  Text(
                    [
                      '${x.nombre}${x.parentesco == null ? '' : ' (${etiquetaParentesco(context.l10n, x.parentesco)})'}',
                      if (x.email.isNotEmpty && x.email != x.nombre) x.email,
                      if ((x.telefono ?? '').isNotEmpty) x.telefono!,
                      if (x.pendiente) context.l10n.pendiente,
                    ].join(' · '),
                    style: t.textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  if (x.pendiente) ...[
                    TextButton.icon(
                      key: Key('reenviar-${x.email}'),
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                      ),
                      onPressed: () => _reenviar(context, ref, [x]),
                      icon: const Icon(Icons.send_outlined, size: 16),
                      label: Text(context.l10n.reenviar),
                    ),
                    IconButton(
                      key: Key('editar-${x.email}'),
                      tooltip: context.l10n.editar,
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      onPressed: () => _editarTutor(context, ref, p, x),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
      trailing: PopupMenuButton<String>(
        tooltip: context.l10n.mas,
        onSelected: (v) => v == 'nuevo_tutor'
            ? _anadirTutor(context, ref, p)
            : v == 'reenviar'
            ? _reenviar(context, ref, tutores)
            : mostrarInvitar(
                context,
                ref,
                escuelaId,
                rolFijo: v == 'tutor' ? Rol.tutor : Rol.alumno,
                jugadorFijo: p,
              ),
        itemBuilder: (_) => [
          PopupMenuItem(
            value: 'nuevo_tutor',
            child: Text(context.l10n.anadirTutor),
          ),
          if (tutores.any((x) => x.pendiente))
            PopupMenuItem(
              value: 'reenviar',
              child: Text(context.l10n.reenviarInvitacion),
            ),
          PopupMenuItem(value: 'tutor', child: Text(context.l10n.invitarTutor)),
          PopupMenuItem(
            value: 'alumno',
            child: Text(context.l10n.invitarAlumno),
          ),
        ],
      ),
    );
  }

  /// Vuelve a mandar el correo a los tutores de la ficha que aún no han creado su cuenta.
  Future<void> _reenviar(
    BuildContext context,
    WidgetRef ref,
    List<TutorJugador> tutores,
  ) async {
    final ok = await ref.read(tutoresRepositoryProvider).enviarInvitaciones(
      escuelaId,
      [
        for (final x in tutores)
          if (x.pendiente) x.email,
      ],
    );
    if (context.mounted) {
      avisar(
        context,
        ok
            ? context.l10n.invitacionCorreoEnviada
            : context.l10n.invitacionCorreoFallo,
      );
    }
  }

  Future<void> _editarTutor(
    BuildContext context,
    WidgetRef ref,
    JugadorLite p,
    TutorJugador x,
  ) async {
    final t = await mostrarFormulario<TutorNuevo>(
      context,
      (_) => _TutorDialog(jugador: p.nombreCompleto, inicial: x),
    );
    if (t == null) return;
    try {
      final estado = await ref
          .read(tutoresRepositoryProvider)
          .editarTutorPendiente(p.id, x.email, t);
      ref.invalidate(tutoresOrgProvider(escuelaId));
      if (context.mounted) {
        avisar(
          context,
          estado == 'vinculado'
              ? context.l10n.tutorAsociado(t.nombre, p.nombre)
              : context.l10n.tutorActualizado,
        );
      }
    } catch (e) {
      if (context.mounted) avisar(context, _errorTutor(context, e));
    }
  }

  Future<void> _anadirTutor(
    BuildContext context,
    WidgetRef ref,
    JugadorLite p,
  ) async {
    final t = await mostrarFormulario<TutorNuevo>(
      context,
      (_) => _TutorDialog(jugador: p.nombreCompleto),
    );
    if (t == null) return;
    try {
      final estado = await ref
          .read(tutoresRepositoryProvider)
          .anadirTutor(p.id, t);
      ref.invalidate(tutoresOrgProvider(escuelaId));
      var correoOk = true;
      if (estado != 'vinculado') {
        correoOk = await ref.read(tutoresRepositoryProvider).enviarInvitaciones(
          escuelaId,
          [t.email],
        );
      }
      if (context.mounted) {
        avisar(
          context,
          estado == 'vinculado'
              ? context.l10n.tutorAsociado(t.nombre, p.nombre)
              : correoOk
              ? context.l10n.invitacionCorreoEnviada
              : context.l10n.invitacionCorreoFallo,
        );
      }
    } catch (e) {
      if (context.mounted) avisar(context, _errorTutor(context, e));
    }
  }

  Future<void> _nueva(BuildContext context, WidgetRef ref) async {
    final ok = await mostrarFormulario<bool>(
      context,
      (_) => _NuevaPersonaDialog(escuelaId: escuelaId),
    );
    if (ok == true) {
      ref.invalidate(jugadoresOrgProvider(escuelaId));
      ref.invalidate(tutoresOrgProvider(escuelaId));
      if (context.mounted) avisar(context, context.l10n.personaAnadida);
    }
  }
}

class _NuevaPersonaDialog extends ConsumerStatefulWidget {
  const _NuevaPersonaDialog({required this.escuelaId});
  final String escuelaId;
  @override
  ConsumerState<_NuevaPersonaDialog> createState() =>
      _NuevaPersonaDialogState();
}

/// Alta en dos pasos: 1) padres, madres o tutores (uno o dos); 2) los jugadores asociados a ellos.
class _NuevaPersonaDialogState extends ConsumerState<_NuevaPersonaDialog> {
  static const _maxTutores = 2;
  final _formTutores = GlobalKey<FormState>();
  final _formJugadores = GlobalKey<FormState>();
  final _tutores = <_EntradaTutor>[_EntradaTutor()];
  final _jugadores = <_EntradaJugador>[_EntradaJugador()];
  int _paso = 0;
  bool _enviando = false;

  @override
  void dispose() {
    for (final t in _tutores) {
      t.dispose();
    }
    for (final j in _jugadores) {
      j.dispose();
    }
    super.dispose();
  }

  void _siguiente() {
    if (_formTutores.currentState!.validate()) setState(() => _paso = 1);
  }

  Future<void> _guardar() async {
    if (!_formJugadores.currentState!.validate()) return;
    setState(() => _enviando = true);
    final tutores = [for (final t in _tutores) t.valor];
    var hayMenores = false;
    try {
      for (final j in List.of(_jugadores)) {
        final nombre = j.nombre.text.trim();
        final apellidos = j.apellidos.text.trim();
        final nac = parseFecha(j.fecha.text)!;
        // Un jugador mayor de edad no necesita la cuenta de un adulto: no se asocia a los tutores.
        final mayor = edadDe(nac) >= 18;
        if (!mayor) hayMenores = true;
        if (tutores.isEmpty || mayor) {
          await ref
              .read(ligaRepositoryProvider)
              .crearJugador(widget.escuelaId, nombre, apellidos, nac);
        } else {
          await ref
              .read(tutoresRepositoryProvider)
              .crearJugador(widget.escuelaId, nombre, apellidos, nac, tutores);
        }
        // Ya guardado: si falla uno posterior no se duplica al reintentar.
        if (_jugadores.length > 1) {
          _jugadores.remove(j);
          j.dispose();
        }
      }
      // Cada madre, padre o tutor recibe un correo para crear su cuenta; sus hijos quedarán asociados a ella.
      var correoOk = true;
      final conTutores = tutores.isNotEmpty && hayMenores;
      if (conTutores) {
        correoOk = await ref.read(tutoresRepositoryProvider).enviarInvitaciones(
          widget.escuelaId,
          [for (final t in tutores) t.email],
        );
      }
      if (mounted) {
        if (conTutores) {
          avisar(
            context,
            correoOk
                ? context.l10n.invitacionCorreoEnviada
                : context.l10n.invitacionCorreoFallo,
          );
        }
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _enviando = false);
        avisar(context, _errorTutor(context, e));
      }
    }
  }

  Widget _pasos(BuildContext context) {
    final titulos = [
      context.l10n.pasoTutoresTitulo,
      context.l10n.pasoJugadoresTitulo,
    ];
    return Row(
      children: [
        for (var i = 0; i < titulos.length; i++) ...[
          if (i > 0)
            Expanded(
              child: Container(
                height: 2,
                margin: const EdgeInsets.symmetric(horizontal: 10),
                color: _paso >= i
                    ? Theme.of(context).colorScheme.primary
                    : Marca.de(context).borde,
              ),
            ),
          _PuntoPaso(numero: i + 1, titulo: titulos[i], activo: _paso >= i),
        ],
      ],
    );
  }

  List<Widget> _pasoTutores(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    return [
      Text(
        context.l10n.tutoresPregunta,
        style: t.titleMedium?.copyWith(fontWeight: FontWeight.w800),
      ),
      const SizedBox(height: 4),
      Text(
        context.l10n.tutoresAyuda,
        style: t.bodySmall?.copyWith(color: cs.onSurfaceVariant),
      ),
      const SizedBox(height: 16),
      if (_tutores.isEmpty)
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Marca.de(context).borde),
          ),
          child: Text(
            context.l10n.sinTutor,
            style: t.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
        ),
      for (var i = 0; i < _tutores.length; i++)
        _TutorCampos(
          key: ObjectKey(_tutores[i]),
          entrada: _tutores[i],
          titulo: context.l10n.tutorN(i + 1),
          onQuitar: () => setState(() => _tutores.removeAt(i).dispose()),
        ),
      if (_tutores.length < _maxTutores)
        OutlinedButton.icon(
          key: const Key('anadir-tutor'),
          onPressed: () => setState(() => _tutores.add(_EntradaTutor())),
          icon: const Icon(Icons.person_add_alt_1_rounded),
          label: Text(
            _tutores.isEmpty
                ? context.l10n.anadirTutor
                : context.l10n.anadirSegundoTutor,
          ),
        ),
    ];
  }

  List<Widget> _pasoJugadores(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    return [
      if (_tutores.isNotEmpty)
        Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: cs.primary.withValues(alpha: .08),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(Icons.family_restroom, color: cs.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  context.l10n.hijosDe(
                    [
                      for (final x in _tutores)
                        x.nombre.text.trim().isEmpty
                            ? etiquetaParentesco(context.l10n, x.parentesco)
                            : x.nombre.text.trim(),
                    ].join(' / '),
                  ),
                  style: t.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      Text(
        context.l10n.jugadoresPregunta,
        style: t.titleMedium?.copyWith(fontWeight: FontWeight.w800),
      ),
      const SizedBox(height: 4),
      Text(
        context.l10n.jugadoresAyuda,
        style: t.bodySmall?.copyWith(color: cs.onSurfaceVariant),
      ),
      const SizedBox(height: 16),
      for (var i = 0; i < _jugadores.length; i++)
        _JugadorCampos(
          key: ObjectKey(_jugadores[i]),
          entrada: _jugadores[i],
          titulo: context.l10n.jugadorN(i + 1),
          autofocus: i == 0,
          onQuitar: _jugadores.length > 1
              ? () => setState(() => _jugadores.removeAt(i).dispose())
              : null,
        ),
      OutlinedButton.icon(
        key: const Key('anadir-jugador'),
        onPressed: () => setState(() => _jugadores.add(_EntradaJugador())),
        icon: const Icon(Icons.add),
        label: Text(context.l10n.anadirOtroJugador),
      ),
      const SizedBox(height: 4),
      Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          onPressed: _enviando ? null : () => setState(() => _paso = 0),
          icon: const Icon(Icons.arrow_back_rounded),
          label: Text(context.l10n.volverTutores),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final primero = _paso == 0;
    final n = _jugadores.length;
    return HojaFormulario(
      key: ValueKey(_paso),
      formKey: primero ? _formTutores : _formJugadores,
      icono: primero ? Icons.family_restroom : Icons.sports_soccer_rounded,
      titulo: context.l10n.nuevoJugador,
      subtitulo: primero
          ? context.l10n.paso1Subtitulo
          : context.l10n.paso2Subtitulo,
      etiquetaAccion: primero
          ? context.l10n.siguiente
          : (n == 1
                ? context.l10n.guardarJugador
                : context.l10n.guardarJugadores(n)),
      iconoAccion: primero ? Icons.arrow_forward_rounded : Icons.check_rounded,
      enviando: _enviando,
      onAccion: primero ? _siguiente : _guardar,
      children: [
        _pasos(context),
        const SizedBox(height: 22),
        ...(primero ? _pasoTutores(context) : _pasoJugadores(context)),
      ],
    );
  }
}

class _PuntoPaso extends StatelessWidget {
  const _PuntoPaso({
    required this.numero,
    required this.titulo,
    required this.activo,
  });
  final int numero;
  final String titulo;
  final bool activo;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: activo ? cs.primary : cs.surfaceContainerHighest,
          foregroundColor: activo ? cs.onPrimary : cs.onSurfaceVariant,
          child: Text(
            '$numero',
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          titulo,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: activo ? FontWeight.w800 : FontWeight.w500,
            color: activo ? cs.onSurface : cs.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// Datos en edición de un jugador.
class _EntradaJugador {
  final nombre = TextEditingController();
  final apellidos = TextEditingController();
  final fecha = TextEditingController();
  void dispose() {
    nombre.dispose();
    apellidos.dispose();
    fecha.dispose();
  }
}

class _JugadorCampos extends StatefulWidget {
  const _JugadorCampos({
    super.key,
    required this.entrada,
    required this.titulo,
    this.autofocus = false,
    this.onQuitar,
  });
  final _EntradaJugador entrada;
  final String titulo;
  final bool autofocus;
  final VoidCallback? onQuitar;
  @override
  State<_JugadorCampos> createState() => _JugadorCamposState();
}

class _JugadorCamposState extends State<_JugadorCampos> {
  Future<void> _elegirFecha() async {
    final hoy = DateTime.now();
    final f = await showDatePicker(
      context: context,
      initialDate:
          parseFecha(widget.entrada.fecha.text) ?? DateTime(hoy.year - 10),
      firstDate: DateTime(1940),
      lastDate: hoy,
    );
    if (f != null) {
      setState(
        () => widget.entrada.fecha.text =
            '${f.day.toString().padLeft(2, '0')}/${f.month.toString().padLeft(2, '0')}/${f.year}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.entrada;
    final cs = Theme.of(context).colorScheme;
    final marca = Marca.de(context);
    final f = parseFecha(e.fecha.text);
    final edad = (f != null && !f.isAfter(DateTime.now())) ? edadDe(f) : null;
    final nombreCampo = TextFormField(
      key: widget.autofocus ? const Key('persona-nombre') : null,
      controller: e.nombre,
      autofocus: widget.autofocus,
      textCapitalization: TextCapitalization.words,
      textInputAction: TextInputAction.next,
      decoration: decoracionCampo(context.l10n.nombre, Icons.badge_outlined),
      validator: (v) =>
          (v == null || v.trim().isEmpty) ? context.l10n.introduceNombre : null,
    );
    final apellidosCampo = TextFormField(
      key: widget.autofocus ? const Key('persona-apellidos') : null,
      controller: e.apellidos,
      textCapitalization: TextCapitalization.words,
      textInputAction: TextInputAction.next,
      decoration: decoracionCampo(context.l10n.apellidos, Icons.badge_outlined),
    );
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: marca.superficie,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: marca.borde),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.sports_soccer_rounded, color: cs.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.titulo,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              if (widget.onQuitar != null)
                IconButton(
                  tooltip: context.l10n.quitar,
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.delete_outline),
                  onPressed: widget.onQuitar,
                ),
            ],
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, c) => c.maxWidth >= 400
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: nombreCampo),
                      const SizedBox(width: 12),
                      Expanded(child: apellidosCampo),
                    ],
                  )
                : Column(children: [nombreCampo, espacioCampo, apellidosCampo]),
          ),
          espacioCampo,
          TextFormField(
            key: widget.autofocus ? const Key('persona-fecha') : null,
            controller: e.fecha,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            onChanged: (_) => setState(() {}),
            inputFormatters: [FormateadorFecha()],
            decoration: decoracionCampo(
              context.l10n.fechaNacimiento,
              Icons.cake_outlined,
              ayuda: context.l10n.formatoFecha,
              sufijo: IconButton(
                tooltip: context.l10n.elegirCalendario,
                icon: const Icon(Icons.calendar_month),
                onPressed: _elegirFecha,
              ),
            ),
            validator: (v) {
              final f = parseFecha(v ?? '');
              if (f == null) return context.l10n.fechaNoValida;
              if (f.isAfter(DateTime.now())) return context.l10n.fechaFutura;
              return null;
            },
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            alignment: Alignment.topCenter,
            child: edad == null
                ? const SizedBox(width: double.infinity)
                : Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Insignia(
                          context.l10n.edadAnios(edad),
                          color: cs.secondary,
                          icono: Icons.cake_outlined,
                        ),
                        Insignia(
                          context.l10n.categoriaX(categoriaPorEdad(f!)),
                          color: cs.primary,
                          icono: Icons.emoji_events_outlined,
                        ),
                        if (edad >= 18)
                          Insignia(
                            context.l10n.mayorEdadSinTutor,
                            color: cs.tertiary,
                            icono: Icons.verified_user_outlined,
                          ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

String _errorTutor(BuildContext context, Object e) {
  final l = context.l10n;
  final t = e.toString().toLowerCase();
  if (t.contains('ya está asociado')) return l.errTutorDuplicado;
  if (t.contains('mayor de edad')) return l.errTutorMayor;
  if (t.contains('email del tutor')) return l.errTutorEmail;
  if (t.contains('sin permiso')) return l.errSinPermiso;
  if (t.contains('anadir_tutor') ||
      t.contains('editar_tutor_pendiente') ||
      t.contains('crear_jugador_con_tutores') ||
      t.contains('pgrst202')) {
    return l.errMigracion;
  }
  return mensajeErrorEscuela(e);
}

/// Datos en edición de un padre, madre o tutor.
class _EntradaTutor {
  final nombre = TextEditingController();
  final email = TextEditingController();
  final telefono = TextEditingController();
  String parentesco = parentescos.first;

  TutorNuevo get valor => TutorNuevo(
    nombre: nombre.text.trim(),
    parentesco: parentesco,
    email: email.text.trim(),
    telefono: telefono.text.trim(),
  );

  void dispose() {
    nombre.dispose();
    email.dispose();
    telefono.dispose();
  }
}

String? _validarEmail(BuildContext context, String? v) =>
    (v != null && RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim()))
    ? null
    : context.l10n.emailValido;

/// Campos de un tutor: parentesco, nombre, email (obligatorio: es con lo que se vincula su cuenta) y teléfono.
class _TutorCampos extends StatefulWidget {
  const _TutorCampos({
    super.key,
    required this.entrada,
    this.onQuitar,
    this.titulo,
  });
  final _EntradaTutor entrada;
  final VoidCallback? onQuitar;
  final String? titulo;
  @override
  State<_TutorCampos> createState() => _TutorCamposState();
}

class _TutorCamposState extends State<_TutorCampos> {
  @override
  Widget build(BuildContext context) {
    final e = widget.entrada;
    final marca = Marca.de(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: marca.superficie,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: marca.borde),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.titulo != null) ...[
            Text(
              widget.titulo!,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
          ],
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: e.parentesco,
                  decoration: decoracionCampo(
                    context.l10n.parentesco,
                    Icons.family_restroom,
                  ),
                  items: [
                    for (final p in parentescos)
                      DropdownMenuItem(
                        value: p,
                        child: Text(etiquetaParentesco(context.l10n, p)),
                      ),
                  ],
                  onChanged: (v) =>
                      setState(() => e.parentesco = v ?? e.parentesco),
                ),
              ),
              if (widget.onQuitar != null)
                IconButton(
                  tooltip: context.l10n.quitar,
                  icon: const Icon(Icons.delete_outline),
                  onPressed: widget.onQuitar,
                ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: e.nombre,
            textCapitalization: TextCapitalization.words,
            decoration: decoracionCampo(
              context.l10n.nombreCompleto,
              Icons.badge_outlined,
            ),
            validator: (v) => (v == null || v.trim().isEmpty)
                ? context.l10n.introduceNombre
                : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: e.email,
            keyboardType: TextInputType.emailAddress,
            decoration: decoracionCampo(
              context.l10n.correoElectronico,
              Icons.mail_outline_rounded,
            ),
            validator: (v) => _validarEmail(context, v),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: e.telefono,
            keyboardType: TextInputType.phone,
            decoration: decoracionCampo(
              context.l10n.telefonoOpc,
              Icons.phone_outlined,
            ),
          ),
        ],
      ),
    );
  }
}

/// Asocia un tutor a un jugador que ya existe.
class _TutorDialog extends StatefulWidget {
  const _TutorDialog({required this.jugador, this.inicial});
  final String jugador;

  /// Si viene, el formulario edita a ese tutor (invitación pendiente) en vez de añadir uno nuevo.
  final TutorJugador? inicial;
  @override
  State<_TutorDialog> createState() => _TutorDialogState();
}

class _TutorDialogState extends State<_TutorDialog> {
  final _form = GlobalKey<FormState>();
  final _e = _EntradaTutor();

  @override
  void initState() {
    super.initState();
    final i = widget.inicial;
    if (i != null) {
      _e.nombre.text = i.nombre == i.email ? '' : i.nombre;
      _e.email.text = i.email;
      _e.telefono.text = i.telefono ?? '';
      if (i.parentesco != null && parentescos.contains(i.parentesco)) {
        _e.parentesco = i.parentesco!;
      }
    }
  }

  @override
  void dispose() {
    _e.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => HojaFormulario(
    formKey: _form,
    icono: Icons.family_restroom,
    titulo: widget.inicial == null
        ? context.l10n.padreMadreTutor
        : context.l10n.editarTutorTitulo,
    subtitulo: widget.inicial == null
        ? context.l10n.tutorDeJugador(widget.jugador)
        : widget.jugador,
    etiquetaAccion: widget.inicial == null
        ? context.l10n.asociar
        : context.l10n.guardar,
    iconoAccion: Icons.check_rounded,
    enviando: false,
    onAccion: () {
      if (_form.currentState!.validate()) Navigator.of(context).pop(_e.valor);
    },
    children: [_TutorCampos(entrada: _e)],
  );
}
