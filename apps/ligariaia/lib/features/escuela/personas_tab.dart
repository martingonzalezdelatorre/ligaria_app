import 'package:flutter/material.dart';
import 'package:ligaria_ui/ligaria_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/auth.dart';
import '../../core/widgets.dart';
import '../../data/liga_repository.dart';
import '../../data/models.dart';
import 'escuela_providers.dart';
import 'invitar_dialog.dart';

class PersonasTab extends ConsumerWidget {
  const PersonasTab({super.key, required this.escuelaId});
  final String escuelaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final datos = ref.watch(jugadoresOrgProvider(escuelaId));
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _nueva(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Nueva persona'),
      ),
      body: AsyncView<List<JugadorLite>>(
        value: datos,
        onRetry: () => ref.invalidate(jugadoresOrgProvider(escuelaId)),
        builder: (lista) => lista.isEmpty
            ? const EstadoVacio(icono: Icons.child_care, texto: 'Todavía no hay jugadores. Añade el primero.')
            : RefreshIndicator(
                onRefresh: () async => ref.invalidate(jugadoresOrgProvider(escuelaId)),
                child: ListView(padding: const EdgeInsets.only(bottom: 88), children: [
                  for (final p in lista) _fila(context, ref, p),
                ]),
              ),
      ),
    );
  }

  Widget _fila(BuildContext context, WidgetRef ref, JugadorLite p) {
    final nac = p.fechaNacimiento;
    return ListTile(
      leading: const CircleAvatar(child: Icon(Icons.person_outline)),
      title: Text(p.nombreCompleto),
      subtitle: Text(nac == null ? 'Sin fecha de nacimiento' : '${edadDe(nac)} años · ${fechaLarga(nac)}'),
      trailing: PopupMenuButton<String>(
        tooltip: 'Invitar',
        onSelected: (v) => mostrarInvitar(context, ref, escuelaId,
            rolFijo: v == 'tutor' ? Rol.tutor : Rol.alumno, jugadorFijo: p),
        itemBuilder: (_) => const [
          PopupMenuItem(value: 'tutor', child: Text('Invitar a su tutor')),
          PopupMenuItem(value: 'alumno', child: Text('Invitar como alumno')),
        ],
      ),
    );
  }

  Future<void> _nueva(BuildContext context, WidgetRef ref) async {
    final ok = await mostrarFormulario<bool>(context, (_) => _NuevaPersonaDialog(escuelaId: escuelaId));
    if (ok == true) {
      ref.invalidate(jugadoresOrgProvider(escuelaId));
      if (context.mounted) avisar(context, 'Persona añadida.');
    }
  }
}

class _NuevaPersonaDialog extends ConsumerStatefulWidget {
  const _NuevaPersonaDialog({required this.escuelaId});
  final String escuelaId;
  @override
  ConsumerState<_NuevaPersonaDialog> createState() => _NuevaPersonaDialogState();
}

class _NuevaPersonaDialogState extends ConsumerState<_NuevaPersonaDialog> {
  final _form = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _apellidos = TextEditingController();
  final _fecha = TextEditingController();
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
      firstDate: DateTime(1940),
      lastDate: hoy,
    );
    if (f != null) setState(() => _fecha.text = '${f.day.toString().padLeft(2, '0')}/${f.month.toString().padLeft(2, '0')}/${f.year}');
  }

  Future<void> _guardar() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _enviando = true);
    try {
      await ref.read(ligaRepositoryProvider).crearJugador(
          widget.escuelaId, _nombre.text.trim(), _apellidos.text.trim(), parseFecha(_fecha.text)!);
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        setState(() => _enviando = false);
        avisar(context, mensajeErrorEscuela(e));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final f = parseFecha(_fecha.text);
    final edad = (f != null && !f.isAfter(DateTime.now())) ? edadDe(f) : null;
    final cs = Theme.of(context).colorScheme;
    final nombreCampo = TextFormField(
      key: const Key('persona-nombre'),
      controller: _nombre,
      autofocus: true,
      textCapitalization: TextCapitalization.words,
      textInputAction: TextInputAction.next,
      decoration: decoracionCampo('Nombre', Icons.badge_outlined),
      validator: (v) => (v == null || v.trim().isEmpty) ? 'Introduce el nombre' : null,
    );
    final apellidosCampo = TextFormField(
      key: const Key('persona-apellidos'),
      controller: _apellidos,
      textCapitalization: TextCapitalization.words,
      textInputAction: TextInputAction.next,
      decoration: decoracionCampo('Apellidos', Icons.badge_outlined),
    );
    return HojaFormulario(
      formKey: _form,
      icono: Icons.person_add_alt_1_rounded,
      titulo: 'Nuevo jugador',
      subtitulo: 'Añade al jugador a la organización. Podrás invitarlo a él o a su tutor después.',
      etiquetaAccion: 'Guardar jugador',
      iconoAccion: Icons.check_rounded,
      enviando: _enviando,
      onAccion: _guardar,
      children: [
        LayoutBuilder(
          builder: (context, c) => c.maxWidth >= 440
              ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(child: nombreCampo),
                  const SizedBox(width: 12),
                  Expanded(child: apellidosCampo),
                ])
              : Column(children: [nombreCampo, espacioCampo, apellidosCampo]),
        ),
        espacioCampo,
        TextFormField(
          key: const Key('persona-fecha'),
          controller: _fecha,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          onChanged: (_) => setState(() {}),
          onFieldSubmitted: (_) => _guardar(),
          inputFormatters: [FormateadorFecha()],
          decoration: decoracionCampo(
            'Fecha de nacimiento',
            Icons.cake_outlined,
            ayuda: 'dd/mm/aaaa',
            sufijo: IconButton(tooltip: 'Elegir en el calendario', icon: const Icon(Icons.calendar_month), onPressed: _elegirFecha),
          ),
          validator: (v) {
            final f = parseFecha(v ?? '');
            if (f == null) return 'Fecha no válida';
            if (f.isAfter(DateTime.now())) return 'No puede ser futura';
            return null;
          },
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.topCenter,
          child: edad == null
              ? const SizedBox(width: double.infinity)
              : Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: Wrap(spacing: 8, runSpacing: 8, children: [
                    Insignia('$edad años', color: cs.secondary, icono: Icons.cake_outlined),
                  ]),
                ),
        ),
      ],
    );
  }
}
