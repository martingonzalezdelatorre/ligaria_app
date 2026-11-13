import 'package:flutter/material.dart';
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
  late DateTime? _inicio = widget.liga?.fechaInicio;
  late DateTime? _fin = widget.liga?.fechaFin;
  String? _errorFechas;
  bool _enviando = false;

  bool get _edita => widget.liga != null;

  @override
  void dispose() {
    _nombre.dispose();
    super.dispose();
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
    setState(() => _enviando = true);
    final repo = ref.read(ligaRepositoryProvider);
    try {
      if (_edita) {
        await repo.editarLiga(widget.liga!.id, nombre: _nombre.text.trim(), fechaInicio: _inicio, fechaFin: _fin);
      } else {
        await repo.crearLiga(
          orgId: widget.escuelaId, deporteId: _deporteId, nombre: _nombre.text.trim(), tipo: _tipo,
          fechaInicio: _inicio, fechaFin: _fin,
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
          decoration: decoracionCampo(etiqueta, Icons.event, sufijo: const Icon(Icons.expand_more)),
          child: Text(valor == null ? 'Sin fecha' : fechaLarga(valor)),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final tipos = tiposCompeticionDe(widget.orgTipo);
    return Scaffold(
      appBar: AppBar(title: Text(_edita ? 'Editar liga' : 'Nueva liga')),
      body: Form(
        key: _form,
        child: ListView(padding: const EdgeInsets.all(16), children: [
          TextFormField(
            controller: _nombre,
            autofocus: !_edita,
            textCapitalization: TextCapitalization.sentences,
            decoration: decoracionCampo('Nombre de la liga', Icons.emoji_events_outlined),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Introduce el nombre' : null,
          ),
          espacioCampo,
          DropdownButtonFormField<String>(
            key: const Key('liga-deporte'),
            initialValue: _deporteId,
            decoration: decoracionCampo('Deporte', Icons.sports_tennis),
            items: [for (final d in deportesDisponibles) DropdownMenuItem(value: d.id, child: Text(d.nombre))],
            onChanged: _edita ? null : (v) => setState(() => _deporteId = v ?? _deporteId),
          ),
          if (tipos.length > 1) ...[
            espacioCampo,
            DropdownButtonFormField<String>(
              key: const Key('liga-tipo'),
              initialValue: tipos.any((t) => t.codigo == _tipo) ? _tipo : tipos.first.codigo,
              isExpanded: true,
              decoration: decoracionCampo('Tipo de liga', Icons.category_outlined),
              items: [for (final t in tipos) DropdownMenuItem(value: t.codigo, child: Text(t.etiqueta))],
              onChanged: _edita ? null : (v) => setState(() => _tipo = v ?? _tipo),
            ),
          ],
          espacioCampo,
          _campoFecha('Fecha de inicio', _inicio, true),
          espacioCampo,
          _campoFecha('Fecha de fin', _fin, false),
          if (_errorFechas != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(_errorFechas!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ),
          const SizedBox(height: 24),
          SizedBox(
            height: 52,
            child: FilledButton(
              onPressed: _enviando ? null : _guardar,
              child: _enviando
                  ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(_edita ? 'Guardar cambios' : 'Crear liga'),
            ),
          ),
        ]),
      ),
    );
  }
}
