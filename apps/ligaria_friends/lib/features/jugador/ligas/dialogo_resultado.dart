import 'package:flutter/material.dart';
import 'package:ligaria_ui/ligaria_ui.dart';

/// Introduce los sets de un partido (juegos de cada lado).
class DialogoResultado extends StatefulWidget {
  const DialogoResultado({
    super.key,
    required this.localNombre,
    required this.visitanteNombre,
    required this.setsParaGanar,
  });
  final String localNombre, visitanteNombre;
  final int setsParaGanar;
  @override
  State<DialogoResultado> createState() => _DialogoResultadoState();
}

class _DialogoResultadoState extends State<DialogoResultado> {
  late final List<(TextEditingController, TextEditingController)> _sets = [
    for (var i = 0; i < widget.setsParaGanar; i++)
      (TextEditingController(), TextEditingController()),
  ];

  int get _max => widget.setsParaGanar * 2 - 1;

  @override
  void dispose() {
    for (final (a, b) in _sets) {
      a.dispose();
      b.dispose();
    }
    super.dispose();
  }

  List<List<int>>? _leer() {
    final out = <List<int>>[];
    for (final (a, b) in _sets) {
      final x = int.tryParse(a.text.trim()), y = int.tryParse(b.text.trim());
      if (x == null || y == null) return null;
      out.add([x, y]);
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    Widget campo(TextEditingController c) => SizedBox(
      width: 64,
      child: TextField(
        controller: c,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        decoration: const InputDecoration(isDense: true),
      ),
    );
    return AlertDialog(
      title: const Text('Resultado'),
      content: SizedBox(
        width: 380,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.localNombre,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('vs'),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.visitanteNombre,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              for (var i = 0; i < _sets.length; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Set ${i + 1}'),
                      const SizedBox(width: 12),
                      campo(_sets[i].$1),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text('-'),
                      ),
                      campo(_sets[i].$2),
                    ],
                  ),
                ),
              if (_sets.length < _max)
                TextButton.icon(
                  onPressed: () => setState(
                    () => _sets.add((
                      TextEditingController(),
                      TextEditingController(),
                    )),
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text('Añadir set'),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            final sets = _leer();
            if (sets == null) {
              avisar(context, 'Rellena los juegos de todos los sets.');
            } else {
              Navigator.pop(context, sets);
            }
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
