import '../../../core/idioma.dart';

List<String> get _dias => l10nActual.diasCortos.split(',');
List<String> get _meses => l10nActual.mesesCortos.split(',');

String _dos(int n) => n.toString().padLeft(2, '0');

/// «sáb 14 nov»
String fechaCorta(DateTime f) =>
    '${_dias[f.weekday - 1]} ${f.day} ${_meses[f.month - 1]}';

/// «sáb 14 nov · 18:30»
String fechaHora(DateTime f) =>
    '${fechaCorta(f)} · ${_dos(f.hour)}:${_dos(f.minute)}';
