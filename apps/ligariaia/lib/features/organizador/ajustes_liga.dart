import '../../core/idioma.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ligaria_ui/ligaria_ui.dart';
import '../../core/widgets.dart';
import '../../data/liga_repository.dart';
import '../../data/models.dart';
import 'organizador_providers.dart';
import 'resumen_liga_page.dart';

/// Ajustes de una liga: puntuación (solo lectura), categorías y co-organizadores.
/// Con [coorganizador] no se pueden añadir ni quitar organizadores (solo quien gestiona la organización).
class AjustesLigaTab extends ConsumerWidget {
  const AjustesLigaTab({
    super.key,
    required this.liga,
    this.coorganizador = false,
    this.escuelaId,
  });
  final Liga liga;
  final bool coorganizador;

  /// Organización desde la que se gestiona (para refrescar la lista de ligas al cerrar o reabrir).
  final String? escuelaId;

  Future<void> _nuevaCategoria(BuildContext context, WidgetRef ref) async {
    final ok = await mostrarFormulario<bool>(
      context,
      (_) => _CategoriaDialog(ligaId: liga.id),
    );
    if (ok == true) {
      ref.invalidate(orgCategoriasProvider(liga.id));
      if (context.mounted) avisar(context, context.l10n.categoriaCreada);
    }
  }

  Future<void> _eliminarCategoria(
    BuildContext context,
    WidgetRef ref,
    CategoriaLiga c,
  ) async {
    try {
      await ref.read(ligaRepositoryProvider).eliminarCategoria(c.id);
      ref.invalidate(orgCategoriasProvider(liga.id));
      if (context.mounted)
        avisar(context, context.l10n.categoriaEliminada(c.nombre));
    } catch (e) {
      if (context.mounted)
        avisar(
          context,
          mensajeError(e, defecto: context.l10n.errEliminarCategoria),
        );
    }
  }

  Future<void> _nuevoOrganizador(BuildContext context, WidgetRef ref) async {
    final estado = await mostrarFormulario<String>(
      context,
      (_) => _OrganizadorDialog(ligaId: liga.id),
    );
    if (estado != null) {
      ref.invalidate(orgOrganizadoresProvider(liga.id));
      if (context.mounted) {
        avisar(
          context,
          estado == 'invitado'
              ? context.l10n.organizadorInvitado
              : context.l10n.organizadorAnadido,
        );
      }
    }
  }

  /// Quita a un co-organizador, o retira su invitación si aún no se ha registrado.
  Future<void> _quitarOrganizador(
    BuildContext context,
    WidgetRef ref,
    OrganizadorLiga o,
  ) async {
    try {
      final repo = ref.read(ligaRepositoryProvider);
      if (o.pendiente) {
        await repo.retirarInvitacionOrganizador(liga.id, o.email);
      } else {
        await repo.quitarOrganizador(liga.id, o.usuarioId!);
      }
      ref.invalidate(orgOrganizadoresProvider(liga.id));
      if (context.mounted) {
        avisar(
          context,
          o.pendiente
              ? context.l10n.invitacionRetirada(o.email)
              : context.l10n.yaNoOrganiza(o.email),
        );
      }
    } catch (e) {
      if (context.mounted)
        avisar(
          context,
          mensajeError(e, defecto: context.l10n.errQuitarOrganizador),
        );
    }
  }

  String _etiquetaCriterio(BuildContext context, String c) => switch (c) {
    'ENFRENTAMIENTO' => context.l10n.critEnfrentamiento,
    'DIF_PARTIDOS' => context.l10n.critDifPartidos,
    'DIF_SETS' => context.l10n.critDifSets,
    'DIF_JUEGOS' => context.l10n.critDifJuegos,
    _ => c,
  };

  void _refrescarLiga(WidgetRef ref) {
    ref.invalidate(orgLigasProvider(escuelaId ?? liga.organizationId ?? ''));
    ref.invalidate(orgClasificacionProvider(liga.id));
    ref.invalidate(orgEncuentrosProvider(liga.id));
  }

  Future<void> _editarDesempate(BuildContext context, WidgetRef ref) async {
    final orden = await mostrarFormulario<List<String>>(
      context,
      (_) => _DesempateDialog(
        inicial: liga.desempate,
        etiqueta: _etiquetaCriterio,
      ),
    );
    if (orden == null) return;
    try {
      await ref.read(ligaRepositoryProvider).fijarDesempate(liga.id, orden);
      _refrescarLiga(ref);
      if (context.mounted) avisar(context, context.l10n.desempateGuardado);
    } catch (e) {
      if (context.mounted) {
        avisar(
          context,
          mensajeError(e, defecto: context.l10n.errGuardarDesempate),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tema = Theme.of(context);
    final apagado = tema.textTheme.bodySmall?.copyWith(
      color: tema.colorScheme.onSurfaceVariant,
    );
    final p = liga.puntuacion;
    Widget titulo(String t, {Widget? accion}) => Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 12, 4),
      child: Row(
        children: [
          Expanded(child: Text(t, style: tema.textTheme.titleSmall)),
          ?accion,
        ],
      ),
    );

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        titulo(context.l10n.puntuacion),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            context.l10n.victoriaEmpateDerrota(p.victoria, p.empate, p.derrota),
            key: const Key('ajustes-puntuacion'),
            style: tema.textTheme.bodyLarge,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 2, 16, 0),
          child: Text(context.l10n.puntuacionEditarAyuda, style: apagado),
        ),
        titulo(
          context.l10n.desempateTitulo,
          accion: TextButton.icon(
            key: const Key('editar-desempate'),
            icon: const Icon(Icons.swap_vert),
            label: Text(context.l10n.editarDesempate),
            onPressed: () => _editarDesempate(context, ref),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            [
              for (var i = 0; i < liga.desempate.length; i++)
                '${i + 1}. ${_etiquetaCriterio(context, liga.desempate[i])}',
            ].join('\n'),
            key: const Key('ajustes-desempate'),
            style: tema.textTheme.bodyLarge,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 2, 16, 0),
          child: Text(context.l10n.desempateAyuda, style: apagado),
        ),
        if (liga.enCurso || liga.finalizada) ...[
          titulo(context.l10n.cierreLigaTitulo),
          _ResumenLiga(liga: liga, escuelaId: escuelaId),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: AccionesCierreLiga(
              liga: liga,
              escuelaId: escuelaId,
              alFinalizar: () {
                final eid = escuelaId ?? liga.organizationId;
                if (eid == null) return;
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ResumenLigaPage(liga: liga, escuelaId: eid),
                  ),
                );
              },
            ),
          ),
        ],
        titulo(
          context.l10n.categorias,
          accion: TextButton.icon(
            key: const Key('nueva-categoria'),
            icon: const Icon(Icons.add),
            label: Text(context.l10n.anadir),
            onPressed: () => _nuevaCategoria(context, ref),
          ),
        ),
        AsyncView<List<CategoriaLiga>>(
          value: ref.watch(orgCategoriasProvider(liga.id)),
          onRetry: () => ref.invalidate(orgCategoriasProvider(liga.id)),
          builder: (cats) => Column(
            children: [
              for (final c in cats)
                Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.category_outlined),
                    title: Text(c.nombre),
                    subtitle: c.detalle == null ? null : Text(c.detalle!),
                    trailing: IconButton(
                      key: Key('eliminar-categoria-${c.id}'),
                      tooltip: context.l10n.eliminarCategoria,
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _eliminarCategoria(context, ref, c),
                    ),
                  ),
                ),
              if (cats.length > 1)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                  child: Text(context.l10n.categoriasAyuda, style: apagado),
                ),
            ],
          ),
        ),
        titulo(
          context.l10n.coorganizadores,
          accion: coorganizador
              ? null
              : TextButton.icon(
                  key: const Key('nuevo-organizador'),
                  icon: const Icon(Icons.person_add_alt_1_outlined),
                  label: Text(context.l10n.anadir),
                  onPressed: () => _nuevoOrganizador(context, ref),
                ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
          child: Text(context.l10n.coorganizadoresAyuda, style: apagado),
        ),
        AsyncView<List<OrganizadorLiga>>(
          value: ref.watch(orgOrganizadoresProvider(liga.id)),
          onRetry: () => ref.invalidate(orgOrganizadoresProvider(liga.id)),
          builder: (lista) => lista.isEmpty
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Text(context.l10n.sinCoorganizadores, style: apagado),
                )
              : Column(
                  children: [
                    for (final o in lista)
                      Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        child: ListTile(
                          leading: Icon(
                            o.pendiente
                                ? Icons.mark_email_unread_outlined
                                : Icons.manage_accounts_outlined,
                          ),
                          title: Text(o.etiqueta),
                          subtitle: o.pendiente
                              ? Text(context.l10n.pendienteRegistro)
                              : null,
                          trailing: coorganizador
                              ? null
                              : IconButton(
                                  key: Key(
                                    o.pendiente
                                        ? 'retirar-invitacion-${o.email}'
                                        : 'quitar-organizador-${o.usuarioId}',
                                  ),
                                  tooltip: o.pendiente
                                      ? context.l10n.retirarInvitacion
                                      : context.l10n.quitarOrganizador,
                                  icon: const Icon(Icons.close_rounded),
                                  onPressed: () =>
                                      _quitarOrganizador(context, ref, o),
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

/// Partidos jugados y campeón de cada categoría (provisional mientras la liga está en curso).
class _ResumenLiga extends ConsumerWidget {
  const _ResumenLiga({required this.liga, this.escuelaId});
  final Liga liga;
  final String? escuelaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tema = Theme.of(context);
    final encs = ref.watch(orgEncuentrosProvider(liga.id)).value;
    final clas = ref.watch(orgClasificacionProvider(liga.id)).value ?? const [];
    if (encs == null) return const SizedBox.shrink();
    final r = resumenLiga(encs, clas);
    final eid = escuelaId ?? liga.organizationId;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.partidosJugadosDe(r.jugados, r.total),
              key: const Key('resumen-jugados'),
              style: tema.textTheme.titleSmall,
            ),
            if (eid != null)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  key: const Key('ver-resumen'),
                  icon: const Icon(Icons.insights_outlined),
                  label: Text(context.l10n.verResumenCompleto),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          ResumenLigaPage(liga: liga, escuelaId: eid),
                    ),
                  ),
                ),
              ),
            for (final c in r.categorias) ...[
              const SizedBox(height: 10),
              if (c.categoria.isNotEmpty)
                Text(c.categoria, style: tema.textTheme.labelLarge),
              Row(
                children: [
                  Icon(
                    Icons.emoji_events_outlined,
                    size: 18,
                    color: tema.colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      c.campeon == null
                          ? context.l10n.sinCampeonAun
                          : '${context.l10n.campeonTitulo}: ${c.campeon}',
                      style: tema.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              if (c.subcampeon != null)
                Padding(
                  padding: const EdgeInsets.only(left: 24),
                  child: Text(
                    '${context.l10n.subcampeonTitulo}: ${c.subcampeon}',
                    style: tema.textTheme.bodyMedium?.copyWith(
                      color: tema.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Criterios de desempate: se marcan los que se usan y se arrastran para ordenarlos.
class _DesempateDialog extends StatefulWidget {
  const _DesempateDialog({required this.inicial, required this.etiqueta});
  final List<String> inicial;
  final String Function(BuildContext, String) etiqueta;
  @override
  State<_DesempateDialog> createState() => _DesempateDialogState();
}

class _DesempateDialogState extends State<_DesempateDialog> {
  late final List<String> _orden = [
    ...widget.inicial,
    for (final c in criteriosDesempate)
      if (!widget.inicial.contains(c)) c,
  ];
  late final Set<String> _usados = {...widget.inicial};

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return HojaFormulario(
      icono: Icons.swap_vert,
      titulo: l.desempateTitulo,
      subtitulo: l.arrastraOrden,
      etiquetaAccion: l.guardar,
      iconoAccion: Icons.check_rounded,
      onAccion: () {
        final orden = [
          for (final c in _orden)
            if (_usados.contains(c)) c,
        ];
        if (orden.isEmpty) {
          avisar(context, l.desempateMinimo);
          return;
        }
        Navigator.of(context).pop(orden);
      },
      children: [
        ReorderableListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          onReorderItem: (a, b) =>
              setState(() => _orden.insert(b, _orden.removeAt(a))),
          children: [
            for (final c in _orden)
              CheckboxListTile(
                key: Key('desempate-$c'),
                value: _usados.contains(c),
                title: Text(widget.etiqueta(context, c)),
                secondary: const Icon(Icons.drag_handle),
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: (v) => setState(() {
                  v == true ? _usados.add(c) : _usados.remove(c);
                }),
              ),
          ],
        ),
      ],
    );
  }
}

/// Alta de una categoría: nombre y, opcionalmente, género, edades y nivel.
class _CategoriaDialog extends ConsumerStatefulWidget {
  const _CategoriaDialog({required this.ligaId});
  final String ligaId;
  @override
  ConsumerState<_CategoriaDialog> createState() => _CategoriaDialogState();
}

class _CategoriaDialogState extends ConsumerState<_CategoriaDialog> {
  final _form = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _edadMin = TextEditingController();
  final _edadMax = TextEditingController();
  final _nivel = TextEditingController();
  String? _genero;
  bool _enviando = false;

  @override
  void dispose() {
    _nombre.dispose();
    _edadMin.dispose();
    _edadMax.dispose();
    _nivel.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _enviando = true);
    try {
      await ref
          .read(ligaRepositoryProvider)
          .crearCategoria(
            widget.ligaId,
            _nombre.text.trim(),
            genero: _genero,
            edadMin: int.tryParse(_edadMin.text.trim()),
            edadMax: int.tryParse(_edadMax.text.trim()),
            nivel: _nivel.text.trim().isEmpty ? null : _nivel.text.trim(),
          );
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        setState(() => _enviando = false);
        avisar(
          context,
          mensajeError(e, defecto: context.l10n.errCrearCategoria),
        );
      }
    }
  }

  String? _validaEdad(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    final n = int.tryParse(v.trim());
    return (n == null || n < 3 || n > 99) ? context.l10n.entre3y99 : null;
  }

  @override
  Widget build(BuildContext context) => HojaFormulario(
    formKey: _form,
    icono: Icons.category_outlined,
    titulo: context.l10n.nuevaCategoria,
    subtitulo: context.l10n.nuevaCategoriaAyuda,
    etiquetaAccion: context.l10n.crearCategoria,
    iconoAccion: Icons.add_rounded,
    enviando: _enviando,
    onAccion: _guardar,
    children: [
      TextFormField(
        key: const Key('categoria-nombre'),
        controller: _nombre,
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
        decoration: decoracionCampo(
          context.l10n.nombre,
          Icons.label_outline,
          ayuda: context.l10n.ejSub12,
        ),
        validator: (v) => (v == null || v.trim().isEmpty)
            ? context.l10n.introduceNombre
            : null,
      ),
      espacioCampo,
      DropdownButtonFormField<String?>(
        key: const Key('categoria-genero'),
        initialValue: _genero,
        isExpanded: true,
        decoration: decoracionCampo(
          context.l10n.generoOpc,
          Icons.people_outline,
        ),
        items: [
          DropdownMenuItem(
            value: null,
            child: Text(context.l10n.sinRestriccion),
          ),
          DropdownMenuItem(
            value: 'MASCULINO',
            child: Text(context.l10n.masculino),
          ),
          DropdownMenuItem(
            value: 'FEMENINO',
            child: Text(context.l10n.femenino),
          ),
          DropdownMenuItem(value: 'MIXTO', child: Text(context.l10n.mixto)),
        ],
        onChanged: (v) => setState(() => _genero = v),
      ),
      espacioCampo,
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: TextFormField(
              key: const Key('categoria-edad-min'),
              controller: _edadMin,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: decoracionCampo(
                context.l10n.edadMin,
                Icons.cake_outlined,
              ),
              validator: _validaEdad,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              key: const Key('categoria-edad-max'),
              controller: _edadMax,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: decoracionCampo(
                context.l10n.edadMax,
                Icons.cake_outlined,
              ),
              validator: (v) {
                final base = _validaEdad(v);
                if (base != null) return base;
                final min = int.tryParse(_edadMin.text.trim());
                final max = int.tryParse((v ?? '').trim());
                return (min != null && max != null && max < min)
                    ? context.l10n.menorQueMinima
                    : null;
              },
            ),
          ),
        ],
      ),
      espacioCampo,
      TextFormField(
        key: const Key('categoria-nivel'),
        controller: _nivel,
        textCapitalization: TextCapitalization.sentences,
        decoration: decoracionCampo(
          context.l10n.nivelOpc,
          Icons.stacked_bar_chart_outlined,
          ayuda: context.l10n.ejIniciacion,
        ),
      ),
    ],
  );
}

/// Añade un co-organizador por correo (debe tener cuenta en Ligaria).
class _OrganizadorDialog extends ConsumerStatefulWidget {
  const _OrganizadorDialog({required this.ligaId});
  final String ligaId;
  @override
  ConsumerState<_OrganizadorDialog> createState() => _OrganizadorDialogState();
}

class _OrganizadorDialogState extends ConsumerState<_OrganizadorDialog> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  bool _enviando = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _enviando = true);
    try {
      final estado = await ref
          .read(ligaRepositoryProvider)
          .asignarOrganizador(widget.ligaId, _email.text.trim());
      if (mounted) Navigator.of(context).pop(estado);
    } catch (e) {
      if (mounted) {
        setState(() => _enviando = false);
        avisar(
          context,
          mensajeError(e, defecto: context.l10n.errAnadirOrganizador),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => HojaFormulario(
    formKey: _form,
    icono: Icons.person_add_alt_1_outlined,
    titulo: context.l10n.anadirCoorganizador,
    subtitulo: context.l10n.anadirCoorganizadorAyuda,
    etiquetaAccion: context.l10n.anadir,
    iconoAccion: Icons.check_rounded,
    enviando: _enviando,
    onAccion: _enviar,
    children: [
      TextFormField(
        key: const Key('organizador-email'),
        controller: _email,
        autofocus: true,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.done,
        onFieldSubmitted: (_) => _enviar(),
        decoration: decoracionCampo(
          context.l10n.correoElectronico,
          Icons.alternate_email,
          ayuda: 'nombre@ejemplo.com',
        ),
        validator: (v) =>
            (v == null ||
                !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim()))
            ? context.l10n.correoInvalido
            : null,
      ),
    ],
  );
}
