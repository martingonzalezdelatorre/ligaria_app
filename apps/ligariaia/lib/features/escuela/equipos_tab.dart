import '../../core/idioma.dart';
import 'package:flutter/material.dart';
import 'package:ligaria_ui/ligaria_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/auth.dart';
import '../../core/widgets.dart';
import '../../data/liga_repository.dart';
import '../../data/models.dart';
import 'escuela_providers.dart';

class EquiposTab extends ConsumerWidget {
  const EquiposTab({super.key, required this.escuelaId});
  final String escuelaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final datos = ref.watch(equiposEscuelaProvider(escuelaId));
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _crear(context, ref),
        icon: const Icon(Icons.add),
        label: Text(context.l10n.nuevoEquipo),
      ),
      body: AsyncView<List<EquipoLite>>(
        value: datos,
        onRetry: () => ref.invalidate(equiposEscuelaProvider(escuelaId)),
        builder: (lista) => lista.isEmpty
            ? EstadoVacio(
                icono: Icons.groups_outlined,
                texto: context.l10n.sinEquipos,
              )
            : RefreshIndicator(
                onRefresh: () async =>
                    ref.invalidate(equiposEscuelaProvider(escuelaId)),
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 88),
                  children: [
                    for (final e in lista)
                      ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.groups_outlined),
                        ),
                        title: Text(e.nombre),
                        subtitle: Text(
                          e.categoria == null
                              ? context.l10n.sinCategoria
                              : '${e.categoria!.nombre} · ${e.categoria!.rotuloAnios()}',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                EquipoPage(escuelaId: escuelaId, equipo: e),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
      ),
    );
  }

  Future<void> _crear(BuildContext context, WidgetRef ref) async {
    final ok = await mostrarFormulario<bool>(
      context,
      (_) => _NuevoEquipoDialog(escuelaId: escuelaId),
    );
    if (ok == true) {
      ref.invalidate(equiposEscuelaProvider(escuelaId));
      if (context.mounted) avisar(context, context.l10n.equipoCreado);
    }
  }
}

class _NuevoEquipoDialog extends ConsumerStatefulWidget {
  const _NuevoEquipoDialog({required this.escuelaId});
  final String escuelaId;
  @override
  ConsumerState<_NuevoEquipoDialog> createState() => _NuevoEquipoDialogState();
}

class _NuevoEquipoDialogState extends ConsumerState<_NuevoEquipoDialog> {
  final _form = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  String? _deporteId;
  CategoriaEquipo? _categoria;
  bool _enviando = false;

  @override
  void dispose() {
    _nombre.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _enviando = true);
    try {
      await ref
          .read(ligaRepositoryProvider)
          .crearEquipo(
            widget.escuelaId,
            _nombre.text.trim(),
            _deporteId!,
            categoria: _categoria,
          );
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        setState(() => _enviando = false);
        avisar(context, mensajeErrorEscuela(e));
      }
    }
  }

  static IconData _icono(String nombre) {
    final n = nombre.toLowerCase();
    if (n.contains('tenis') || n.contains('pádel') || n.contains('padel')) {
      return Icons.sports_tennis;
    }
    if (n.contains('baloncesto')) return Icons.sports_basketball;
    if (n.contains('fútbol') || n.contains('futbol')) {
      return Icons.sports_soccer;
    }
    if (n.contains('balonmano')) return Icons.sports_handball;
    if (n.contains('voley')) return Icons.sports_volleyball;
    return Icons.sports;
  }

  @override
  Widget build(BuildContext context) {
    final deportes = ref.watch(deportesProvider).value ?? const <Deporte>[];
    return HojaFormulario(
      formKey: _form,
      icono: Icons.groups_rounded,
      titulo: context.l10n.nuevoEquipo,
      subtitulo: context.l10n.eligeNombreDeporte,
      etiquetaAccion: context.l10n.crearEquipo,
      iconoAccion: Icons.check_rounded,
      enviando: _enviando,
      onAccion: _guardar,
      children: [
        TextFormField(
          key: const Key('equipo-nombre'),
          controller: _nombre,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          textInputAction: TextInputAction.done,
          decoration: decoracionCampo(
            context.l10n.nombreEquipo,
            Icons.shield_outlined,
            ayuda: context.l10n.ejInfantil,
          ),
          validator: (v) => (v == null || v.trim().isEmpty)
              ? context.l10n.introduceUnNombre
              : null,
        ),
        espacioCampo,
        DropdownButtonFormField<CategoriaEquipo>(
          key: const Key('equipo-categoria'),
          initialValue: _categoria,
          isExpanded: true,
          decoration: decoracionCampo(
            context.l10n.categoriaEdad,
            Icons.cake_outlined,
          ),
          items: [
            for (final c in CategoriaEquipo.values)
              DropdownMenuItem(
                value: c,
                child: Text(
                  '${c.nombre} · ${c.rotuloAnios()}',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
          validator: (v) => v == null ? context.l10n.eligeCategoria : null,
          onChanged: (v) => setState(() => _categoria = v),
        ),
        espacioCampo,
        FormField<String>(
          key: const Key('equipo-deporte'),
          initialValue: _deporteId,
          validator: (v) => v == null ? context.l10n.eligeDeporte : null,
          builder: (f) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SelectorTarjetas<String>(
                etiqueta: context.l10n.deporte,
                valor: _deporteId,
                opciones: [
                  for (final d in deportes)
                    OpcionTarjeta(
                      d.id,
                      nombreDeporte(d.nombre),
                      _icono(d.nombre),
                    ),
                ],
                onCambio: (v) {
                  setState(() => _deporteId = v);
                  f.didChange(v);
                },
              ),
              if (f.hasError)
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 4),
                  child: Text(
                    f.errorText!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Detalle de un equipo: plantilla, añadir jugadores y asignar entrenador.
class EquipoPage extends ConsumerWidget {
  const EquipoPage({super.key, required this.escuelaId, required this.equipo});
  final String escuelaId;
  final EquipoLite equipo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jugadores = ref.watch(jugadoresEquipoEscuelaProvider(equipo.id));
    return Scaffold(
      appBar: AppBar(title: Text(equipo.nombre)),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  key: const Key('anadir-jugador'),
                  onPressed: () => _anadirJugador(context, ref),
                  icon: const Icon(Icons.person_add_alt),
                  label: Text(context.l10n.anadirJugador),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  key: const Key('asignar-entrenador'),
                  onPressed: () => _asignarEntrenador(context, ref),
                  icon: const Icon(Icons.sports),
                  label: Text(context.l10n.rolEntrenador),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            context.l10n.plantilla,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          jugadores.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(16),
              child: LinearProgressIndicator(),
            ),
            error: (_, _) => Padding(
              padding: const EdgeInsets.all(8),
              child: Text(context.l10n.errPlantilla),
            ),
            data: (js) => js.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(context.l10n.sinJugadoresTodavia),
                  )
                : Column(
                    children: [
                      for (final j in js)
                        ListTile(
                          leading: const Icon(Icons.person_outline),
                          title: Text(j.nombreCompleto),
                          dense: true,
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Future<String?> _elegir(
    BuildContext context,
    String titulo,
    IconData icono,
    List<(String, String)> opciones,
    String vacio,
  ) => elegirDeLista<String>(
    context,
    icono: icono,
    titulo: titulo,
    subtitulo: equipo.nombre,
    opciones: [for (final o in opciones) (o.$1, o.$2, null)],
    vacio: vacio,
  );

  Future<void> _anadirJugador(BuildContext context, WidgetRef ref) async {
    final repo = ref.read(ligaRepositoryProvider);
    try {
      final personas = await ref.read(jugadoresOrgProvider(escuelaId).future);
      final actuales = (await ref.read(
        jugadoresEquipoEscuelaProvider(equipo.id).future,
      )).map((j) => j.jugadorId).toSet();
      // Solo los jugadores cuya edad (por año de nacimiento) encaja en la categoría del equipo.
      final cat = equipo.categoria;
      final libres = personas
          .where(
            (p) =>
                !actuales.contains(p.id) &&
                (cat == null || cat.admite(p.fechaNacimiento)),
          )
          .toList();
      if (!context.mounted) return;
      final id = await elegirDeLista<String>(
        context,
        icono: Icons.person_add_alt_1_rounded,
        titulo: context.l10n.anadirJugador,
        subtitulo: cat == null
            ? equipo.nombre
            : '${equipo.nombre} · ${cat.nombre} (${cat.rotuloAnios()})',
        opciones: [
          for (final p in libres)
            (
              p.id,
              p.nombreCompleto,
              p.fechaNacimiento == null ? null : '${p.fechaNacimiento!.year}',
            ),
        ],
        vacio: cat == null || cat == CategoriaEquipo.absoluto
            ? context.l10n.noQuedanPersonas
            : context.l10n.sinJugadoresCategoria(cat.nombre),
      );
      if (id == null) return;
      await repo.anadirJugador(equipo.id, id);
      ref.invalidate(jugadoresEquipoEscuelaProvider(equipo.id));
      if (context.mounted) avisar(context, context.l10n.jugadorAnadido);
    } catch (e) {
      if (context.mounted) avisar(context, mensajeErrorEscuela(e));
    }
  }

  Future<void> _asignarEntrenador(BuildContext context, WidgetRef ref) async {
    final repo = ref.read(ligaRepositoryProvider);
    try {
      final usuarios = await ref.read(
        usuariosEscuelaProvider(escuelaId).future,
      );
      final entrenadores = usuarios
          .where((u) => u.rol == rolADb(Rol.entrenador))
          .toList();
      if (!context.mounted) return;
      final id = await _elegir(
        context,
        context.l10n.asignarEntrenador,
        Icons.sports,
        [
          for (final u in entrenadores)
            (u.usuarioId, u.nombre?.isNotEmpty == true ? u.nombre! : u.email),
        ],
        context.l10n.sinEntrenadores,
      );
      if (id == null) return;
      await repo.asignarEntrenador(equipo.id, id);
      if (context.mounted) avisar(context, context.l10n.entrenadorAsignado);
    } catch (e) {
      if (context.mounted) avisar(context, mensajeErrorEscuela(e));
    }
  }
}
