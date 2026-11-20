import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ligaria_ui/ligaria_ui.dart';
import '../../core/widgets.dart';
import '../../data/liga_repository.dart';
import '../../data/models.dart';
import 'organizador_providers.dart';

/// Ajustes de una liga: puntuación (solo lectura), categorías y co-organizadores.
/// Con [coorganizador] no se pueden añadir ni quitar organizadores (solo quien gestiona la organización).
class AjustesLigaTab extends ConsumerWidget {
  const AjustesLigaTab({super.key, required this.liga, this.coorganizador = false});
  final Liga liga;
  final bool coorganizador;

  Future<void> _nuevaCategoria(BuildContext context, WidgetRef ref) async {
    final ok = await mostrarFormulario<bool>(context, (_) => _CategoriaDialog(ligaId: liga.id));
    if (ok == true) {
      ref.invalidate(orgCategoriasProvider(liga.id));
      if (context.mounted) avisar(context, 'Categoría creada.');
    }
  }

  Future<void> _eliminarCategoria(BuildContext context, WidgetRef ref, CategoriaLiga c) async {
    try {
      await ref.read(ligaRepositoryProvider).eliminarCategoria(c.id);
      ref.invalidate(orgCategoriasProvider(liga.id));
      if (context.mounted) avisar(context, 'Categoría «${c.nombre}» eliminada.');
    } catch (e) {
      if (context.mounted) avisar(context, mensajeError(e, defecto: 'No se pudo eliminar la categoría.'));
    }
  }

  Future<void> _nuevoOrganizador(BuildContext context, WidgetRef ref) async {
    final estado = await mostrarFormulario<String>(context, (_) => _OrganizadorDialog(ligaId: liga.id));
    if (estado != null) {
      ref.invalidate(orgOrganizadoresProvider(liga.id));
      if (context.mounted) {
        avisar(
            context,
            estado == 'invitado'
                ? 'Invitación guardada: tendrá acceso a esta liga cuando se registre con ese correo.'
                : 'Organizador añadido.');
      }
    }
  }

  /// Quita a un co-organizador, o retira su invitación si aún no se ha registrado.
  Future<void> _quitarOrganizador(BuildContext context, WidgetRef ref, OrganizadorLiga o) async {
    try {
      final repo = ref.read(ligaRepositoryProvider);
      if (o.pendiente) {
        await repo.retirarInvitacionOrganizador(liga.id, o.email);
      } else {
        await repo.quitarOrganizador(liga.id, o.usuarioId!);
      }
      ref.invalidate(orgOrganizadoresProvider(liga.id));
      if (context.mounted) {
        avisar(context, o.pendiente ? 'Invitación a ${o.email} retirada.' : 'Ya no organiza esta liga: ${o.email}.');
      }
    } catch (e) {
      if (context.mounted) avisar(context, mensajeError(e, defecto: 'No se pudo quitar al organizador.'));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tema = Theme.of(context);
    final apagado = tema.textTheme.bodySmall?.copyWith(color: tema.colorScheme.onSurfaceVariant);
    final p = liga.puntuacion;
    Widget titulo(String t, {Widget? accion}) => Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 12, 4),
          child: Row(children: [
            Expanded(child: Text(t, style: tema.textTheme.titleSmall)),
            ?accion,
          ]),
        );

    return ListView(padding: const EdgeInsets.only(bottom: 24), children: [
      titulo('Puntuación'),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          'Victoria ${p.victoria} · Empate ${p.empate} · Derrota ${p.derrota}',
          key: const Key('ajustes-puntuacion'),
          style: tema.textTheme.bodyLarge,
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 2, 16, 0),
        child: Text('Se puede cambiar con «Editar» mientras la liga está en borrador.', style: apagado),
      ),
      titulo(
        'Categorías',
        accion: TextButton.icon(
          key: const Key('nueva-categoria'),
          icon: const Icon(Icons.add),
          label: const Text('Añadir'),
          onPressed: () => _nuevaCategoria(context, ref),
        ),
      ),
      AsyncView<List<CategoriaLiga>>(
        value: ref.watch(orgCategoriasProvider(liga.id)),
        onRetry: () => ref.invalidate(orgCategoriasProvider(liga.id)),
        builder: (cats) => Column(children: [
          for (final c in cats)
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: ListTile(
                leading: const Icon(Icons.category_outlined),
                title: Text(c.nombre),
                subtitle: c.detalle == null ? null : Text(c.detalle!),
                trailing: IconButton(
                  key: Key('eliminar-categoria-${c.id}'),
                  tooltip: 'Eliminar categoría',
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _eliminarCategoria(context, ref, c),
                ),
              ),
            ),
          if (cats.length > 1)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: Text(
                'Cada categoría tiene su propio calendario y clasificación. '
                'Las escuelas eligen categoría al inscribir un equipo.',
                style: apagado,
              ),
            ),
        ]),
      ),
      titulo(
        'Co-organizadores',
        accion: coorganizador
            ? null
            : TextButton.icon(
                key: const Key('nuevo-organizador'),
                icon: const Icon(Icons.person_add_alt_1_outlined),
                label: const Text('Añadir'),
                onPressed: () => _nuevoOrganizador(context, ref),
              ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
        child: Text('Personas que gestionan solo esta liga (calendario, resultados, solicitudes e invitaciones).', style: apagado),
      ),
      AsyncView<List<OrganizadorLiga>>(
        value: ref.watch(orgOrganizadoresProvider(liga.id)),
        onRetry: () => ref.invalidate(orgOrganizadoresProvider(liga.id)),
        builder: (lista) => lista.isEmpty
            ? Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Text('Todavía no hay co-organizadores.', style: apagado),
              )
            : Column(children: [
                for (final o in lista)
                  Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: ListTile(
                      leading: Icon(o.pendiente ? Icons.mark_email_unread_outlined : Icons.manage_accounts_outlined),
                      title: Text(o.etiqueta),
                      subtitle: o.pendiente ? const Text('Pendiente de registrarse') : null,
                      trailing: coorganizador
                          ? null
                          : IconButton(
                              key: Key(o.pendiente ? 'retirar-invitacion-${o.email}' : 'quitar-organizador-${o.usuarioId}'),
                              tooltip: o.pendiente ? 'Retirar invitación' : 'Quitar organizador',
                              icon: const Icon(Icons.close_rounded),
                              onPressed: () => _quitarOrganizador(context, ref, o),
                            ),
                    ),
                  ),
              ]),
      ),
    ]);
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
      await ref.read(ligaRepositoryProvider).crearCategoria(
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
        avisar(context, mensajeError(e, defecto: 'No se pudo crear la categoría.'));
      }
    }
  }

  String? _validaEdad(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    final n = int.tryParse(v.trim());
    return (n == null || n < 3 || n > 99) ? 'Entre 3 y 99' : null;
  }

  @override
  Widget build(BuildContext context) => HojaFormulario(
        formKey: _form,
        icono: Icons.category_outlined,
        titulo: 'Nueva categoría',
        subtitulo: 'Cada categoría tiene su propio calendario y clasificación.',
        etiquetaAccion: 'Crear categoría',
        iconoAccion: Icons.add_rounded,
        enviando: _enviando,
        onAccion: _guardar,
        children: [
          TextFormField(
            key: const Key('categoria-nombre'),
            controller: _nombre,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: decoracionCampo('Nombre', Icons.label_outline, ayuda: 'Ej.: Sub-12 femenino'),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Introduce el nombre' : null,
          ),
          espacioCampo,
          DropdownButtonFormField<String?>(
            key: const Key('categoria-genero'),
            initialValue: _genero,
            isExpanded: true,
            decoration: decoracionCampo('Género (opcional)', Icons.people_outline),
            items: const [
              DropdownMenuItem(value: null, child: Text('Sin restricción')),
              DropdownMenuItem(value: 'MASCULINO', child: Text('Masculino')),
              DropdownMenuItem(value: 'FEMENINO', child: Text('Femenino')),
              DropdownMenuItem(value: 'MIXTO', child: Text('Mixto')),
            ],
            onChanged: (v) => setState(() => _genero = v),
          ),
          espacioCampo,
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              child: TextFormField(
                key: const Key('categoria-edad-min'),
                controller: _edadMin,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: decoracionCampo('Edad mínima', Icons.cake_outlined),
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
                decoration: decoracionCampo('Edad máxima', Icons.cake_outlined),
                validator: (v) {
                  final base = _validaEdad(v);
                  if (base != null) return base;
                  final min = int.tryParse(_edadMin.text.trim());
                  final max = int.tryParse((v ?? '').trim());
                  return (min != null && max != null && max < min) ? 'Menor que la mínima' : null;
                },
              ),
            ),
          ]),
          espacioCampo,
          TextFormField(
            key: const Key('categoria-nivel'),
            controller: _nivel,
            textCapitalization: TextCapitalization.sentences,
            decoration: decoracionCampo('Nivel (opcional)', Icons.stacked_bar_chart_outlined, ayuda: 'Ej.: Iniciación'),
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
      final estado = await ref.read(ligaRepositoryProvider).asignarOrganizador(widget.ligaId, _email.text.trim());
      if (mounted) Navigator.of(context).pop(estado);
    } catch (e) {
      if (mounted) {
        setState(() => _enviando = false);
        avisar(context, mensajeError(e, defecto: 'No se pudo añadir al organizador.'));
      }
    }
  }

  @override
  Widget build(BuildContext context) => HojaFormulario(
        formKey: _form,
        icono: Icons.person_add_alt_1_outlined,
        titulo: 'Añadir co-organizador',
        subtitulo: 'Podrá gestionar esta liga. Si aún no tiene cuenta, el acceso se activará cuando se registre con ese correo.',
        etiquetaAccion: 'Añadir',
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
            decoration: decoracionCampo('Correo electrónico', Icons.alternate_email, ayuda: 'nombre@ejemplo.com'),
            validator: (v) => (v == null || !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim()))
                ? 'Introduce un correo válido'
                : null,
          ),
        ],
      );
}
