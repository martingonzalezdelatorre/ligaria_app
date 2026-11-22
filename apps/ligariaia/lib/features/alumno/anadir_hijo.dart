import '../../core/idioma.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ligaria_ui/ligaria_ui.dart';
import '../../core/auth.dart';
import '../../data/categoria_edad.dart';
import '../../data/tutores_repository.dart';
import '../escuela/escuela_providers.dart' show parseFecha, mensajeErrorEscuela;
import 'alumno_providers.dart';

/// Organizaciones en las que el usuario es padre, madre o tutor (puede añadir hijos en ellas).
List<Pertenencia> orgsComoTutor(List<Pertenencia> l) => [
  for (final p in l)
    if (p.rol == Rol.tutor && p.escuelaId != null) p,
];

/// Abre el formulario para dar de alta a un hijo o hija. Devuelve true si se creó.
Future<void> mostrarAnadirHijo(
  BuildContext context,
  WidgetRef ref,
  List<Pertenencia> orgs,
) async {
  final ok = await mostrarFormulario<bool>(
    context,
    (_) => _AnadirHijoDialog(orgs: orgs),
  );
  if (ok == true) {
    ref.invalidate(misFichasProvider);
    if (context.mounted) avisar(context, context.l10n.hijoAnadido);
  }
}

class _AnadirHijoDialog extends ConsumerStatefulWidget {
  const _AnadirHijoDialog({required this.orgs});
  final List<Pertenencia> orgs;
  @override
  ConsumerState<_AnadirHijoDialog> createState() => _AnadirHijoDialogState();
}

class _AnadirHijoDialogState extends ConsumerState<_AnadirHijoDialog> {
  final _form = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _apellidos = TextEditingController();
  final _fecha = TextEditingController();
  late String _orgId = widget.orgs.first.escuelaId!;
  String _parentesco = parentescos.first;
  bool _enviando = false;

  @override
  void dispose() {
    _nombre.dispose();
    _apellidos.dispose();
    _fecha.dispose();
    super.dispose();
  }

  Future<void> _elegirFecha() async {
    final hoy = DateTime.now();
    final f = await showDatePicker(
      context: context,
      initialDate: DateTime(hoy.year - 10),
      firstDate: DateTime(hoy.year - 30),
      lastDate: hoy,
    );
    if (f != null) {
      setState(
        () => _fecha.text =
            '${f.day.toString().padLeft(2, '0')}/${f.month.toString().padLeft(2, '0')}/${f.year}',
      );
    }
  }

  String _error(Object e) {
    final l = context.l10n;
    final t = e.toString().toLowerCase();
    if (t.contains('ya está dado de alta')) return l.errHijoYaAlta;
    if (t.contains('máximo de hijos')) return l.errHijoMax;
    if (t.contains('anadir_hijo') || t.contains('pgrst202')) return l.errMigr13;
    if (t.contains('sin permiso')) return l.errSoloTutores;
    return mensajeErrorEscuela(e);
  }

  Future<void> _guardar() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _enviando = true);
    try {
      await ref
          .read(tutoresRepositoryProvider)
          .anadirHijo(
            _orgId,
            _nombre.text.trim(),
            _apellidos.text.trim(),
            parseFecha(_fecha.text)!,
            _parentesco,
          );
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        setState(() => _enviando = false);
        avisar(context, _error(e));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final f = parseFecha(_fecha.text);
    final valida = f != null && !f.isAfter(DateTime.now());
    final cs = Theme.of(context).colorScheme;
    return HojaFormulario(
      formKey: _form,
      icono: Icons.child_care,
      titulo: context.l10n.anadirHijoTitulo,
      subtitulo: context.l10n.anadirHijoAyuda,
      etiquetaAccion: context.l10n.anadir,
      iconoAccion: Icons.check_rounded,
      enviando: _enviando,
      onAccion: _guardar,
      children: [
        if (widget.orgs.length > 1) ...[
          DropdownButtonFormField<String>(
            initialValue: _orgId,
            isExpanded: true,
            decoration: decoracionCampo(
              context.l10n.escuela,
              Icons.school_outlined,
            ),
            items: [
              for (final o in widget.orgs)
                DropdownMenuItem(
                  value: o.escuelaId,
                  child: Text(o.escuela ?? context.l10n.escuela),
                ),
            ],
            onChanged: (v) => setState(() => _orgId = v ?? _orgId),
          ),
          espacioCampo,
        ],
        TextFormField(
          key: const Key('hijo-nombre'),
          controller: _nombre,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          decoration: decoracionCampo(
            context.l10n.nombre,
            Icons.badge_outlined,
          ),
          validator: (v) => (v == null || v.trim().isEmpty)
              ? context.l10n.introduceNombre
              : null,
        ),
        espacioCampo,
        TextFormField(
          key: const Key('hijo-apellidos'),
          controller: _apellidos,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          decoration: decoracionCampo(
            context.l10n.apellidos,
            Icons.badge_outlined,
          ),
          validator: (v) => (v == null || v.trim().isEmpty)
              ? context.l10n.introduceApellidos
              : null,
        ),
        espacioCampo,
        TextFormField(
          key: const Key('hijo-fecha'),
          controller: _fecha,
          keyboardType: TextInputType.number,
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
            final d = parseFecha(v ?? '');
            if (d == null) return context.l10n.fechaNoValida;
            if (d.isAfter(DateTime.now())) return context.l10n.fechaFutura;
            return null;
          },
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.topCenter,
          child: !valida
              ? const SizedBox(width: double.infinity)
              : Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: Insignia(
                    context.l10n.categoriaX(categoriaPorEdad(f)),
                    color: cs.primary,
                    icono: Icons.emoji_events_outlined,
                  ),
                ),
        ),
        espacioCampo,
        DropdownButtonFormField<String>(
          initialValue: _parentesco,
          decoration: decoracionCampo(
            context.l10n.tuParentesco,
            Icons.family_restroom,
          ),
          items: [
            for (final p in parentescos)
              DropdownMenuItem(
                value: p,
                child: Text(etiquetaParentesco(context.l10n, p)),
              ),
          ],
          onChanged: (v) => setState(() => _parentesco = v ?? _parentesco),
        ),
      ],
    );
  }
}
