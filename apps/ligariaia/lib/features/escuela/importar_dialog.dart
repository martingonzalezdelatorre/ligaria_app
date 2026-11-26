import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ligaria_ui/ligaria_ui.dart';
import '../../core/idioma.dart';
import '../../data/liga_repository.dart';
import '../../data/models.dart';
import '../../data/tutores_repository.dart';
import 'escuela_providers.dart';
import 'importar_jugadores.dart';

/// Pide un archivo CSV/TSV/TXT y devuelve su texto, o null si se cancela. Se sustituye en los tests.
final leerArchivoListaProvider = Provider<Future<String?> Function()>(
  (_) => () async {
    final f = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: const ['csv', 'tsv', 'txt'],
    );
    if (f == null) return null;
    final bytes = await f.readAsBytes();
    try {
      return utf8.decode(bytes);
    } on FormatException {
      // Excel en español guarda el CSV en Windows-1252.
      return latin1.decode(bytes);
    }
  },
);

/// Resultado de dar de alta una lista de jugadores.
class ResultadoImport {
  int creados = 0;
  final fallos = <(FilaImport, String)>[];

  /// null si no había familias a las que escribir; false si algún correo no salió.
  bool? correosOk;
}

/// Da de alta las filas válidas una a una (si una falla se sigue con las demás) y manda un correo a
/// cada familia con tutor. Un jugador mayor de edad no necesita la cuenta de un adulto: no se asocia.
Future<ResultadoImport> ejecutarImportacion({
  required LigaRepository liga,
  required TutoresRepository tutores,
  required String orgId,
  required List<FilaImport> filas,
  void Function(int hechas, int total)? progreso,
  DateTime? hoy,
}) async {
  final r = ResultadoImport();
  final validas = filas.where((f) => f.valida).toList();
  final correos = <String>{};
  for (var i = 0; i < validas.length; i++) {
    final f = validas[i];
    progreso?.call(i, validas.length);
    try {
      if (f.conTutor && edadDe(f.fecha!, hoy) < 18) {
        await tutores.crearJugador(orgId, f.nombre, f.apellidos, f.fecha!, [
          TutorNuevo(
            nombre: f.tutor.isEmpty ? f.correo : f.tutor,
            parentesco: f.parentesco,
            email: f.correo,
            telefono: f.telefono,
          ),
        ]);
        correos.add(f.correo);
      } else {
        await liga.crearJugador(orgId, f.nombre, f.apellidos, f.fecha!);
      }
      r.creados++;
    } catch (e) {
      r.fallos.add((f, mensajeErrorEscuela(e)));
    }
  }
  progreso?.call(validas.length, validas.length);
  if (correos.isNotEmpty) {
    // El servicio de correo admite hasta 10 direcciones por llamada.
    final lista = correos.toList();
    var ok = true;
    for (var i = 0; i < lista.length; i += 10) {
      final fin = i + 10 > lista.length ? lista.length : i + 10;
      ok = await tutores.enviarInvitaciones(orgId, lista.sublist(i, fin)) && ok;
    }
    r.correosOk = ok;
  }
  return r;
}

String _textoMotivo(AppL10n l, MotivoFila m) => switch (m) {
  MotivoFila.sinNombre => l.impErrNombre,
  MotivoFila.fechaInvalida => l.impErrFecha,
  MotivoFila.correoInvalido => l.impErrCorreo,
  MotivoFila.repetida => l.impErrRepetida,
  MotivoFila.existe => l.impErrExiste,
};

/// Importar jugadores (y sus tutores) pegando filas de Excel o cargando un CSV.
/// Devuelve true si se dio de alta alguno.
Future<bool> mostrarImportarJugadores(
  BuildContext context,
  String escuelaId,
) async =>
    await mostrarFormulario<bool>(
      context,
      (_) => ImportarJugadoresDialog(escuelaId: escuelaId),
    ) ??
    false;

class ImportarJugadoresDialog extends ConsumerStatefulWidget {
  const ImportarJugadoresDialog({super.key, required this.escuelaId});
  final String escuelaId;
  @override
  ConsumerState<ImportarJugadoresDialog> createState() =>
      _ImportarJugadoresDialogState();
}

enum _Fase { entrada, revision, enCurso, hecho }

class _ImportarJugadoresDialogState
    extends ConsumerState<ImportarJugadoresDialog> {
  final _texto = TextEditingController();
  _Fase _fase = _Fase.entrada;
  List<FilaImport> _filas = const [];
  String? _error;
  int _hechas = 0, _total = 0;
  ResultadoImport? _resultado;

  @override
  void dispose() {
    _texto.dispose();
    super.dispose();
  }

  Future<void> _elegirArchivo() async {
    try {
      final t = await ref.read(leerArchivoListaProvider)();
      if (t != null && mounted) {
        setState(() {
          _texto.text = t;
          _error = null;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _error = context.l10n.impArchivoError);
    }
  }

  Future<void> _copiarModelo() async {
    await Clipboard.setData(const ClipboardData(text: modeloImportacion));
    if (mounted) avisar(context, context.l10n.impModeloCopiado);
  }

  Future<void> _revisar() async {
    final existentes = await ref
        .read(jugadoresOrgProvider(widget.escuelaId).future)
        .catchError((_) => const <JugadorLite>[]);
    final filas = leerJugadores(_texto.text, existentes: existentes);
    if (!mounted) return;
    setState(() {
      if (filas.isEmpty) {
        _error = context.l10n.impSinFilas;
      } else {
        _error = null;
        _filas = filas;
        _fase = _Fase.revision;
      }
    });
  }

  Future<void> _importar() async {
    final validas = _filas.where((f) => f.valida).length;
    setState(() {
      _fase = _Fase.enCurso;
      _hechas = 0;
      _total = validas;
    });
    final r = await ejecutarImportacion(
      liga: ref.read(ligaRepositoryProvider),
      tutores: ref.read(tutoresRepositoryProvider),
      orgId: widget.escuelaId,
      filas: _filas,
      progreso: (h, t) {
        if (mounted) {
          setState(() {
            _hechas = h;
            _total = t;
          });
        }
      },
    );
    if (mounted) {
      setState(() {
        _resultado = r;
        _fase = _Fase.hecho;
      });
    }
  }

  Widget _linea(IconData icono, String texto, {Color? color, Key? clave}) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icono, size: 20, color: color),
            const SizedBox(width: 10),
            Expanded(child: Text(texto, key: clave)),
          ],
        ),
      );

  List<Widget> _entrada(AppL10n l) {
    final cs = Theme.of(context).colorScheme;
    return [
      Text(
        l.impAyuda,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
      ),
      const SizedBox(height: 12),
      TextField(
        key: const Key('imp-texto'),
        controller: _texto,
        minLines: 6,
        maxLines: 10,
        keyboardType: TextInputType.multiline,
        onChanged: (_) => setState(() => _error = null),
        decoration: decoracionCampo(l.impPegar, Icons.table_chart_outlined),
      ),
      const SizedBox(height: 10),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          OutlinedButton.icon(
            key: const Key('imp-archivo'),
            onPressed: _elegirArchivo,
            icon: const Icon(Icons.upload_file_outlined),
            label: Text(l.impElegirArchivo),
          ),
          TextButton.icon(
            key: const Key('imp-modelo'),
            onPressed: _copiarModelo,
            icon: const Icon(Icons.copy_all_outlined),
            label: Text(l.impCopiarModelo),
          ),
        ],
      ),
      if (_error != null) ...[
        const SizedBox(height: 10),
        Text(
          _error!,
          key: const Key('imp-error'),
          style: TextStyle(color: cs.error),
        ),
      ],
    ];
  }

  List<Widget> _revision(AppL10n l) {
    final cs = Theme.of(context).colorScheme;
    final validas = _filas.where((f) => f.valida).toList();
    final existen = _filas.where((f) => f.motivo == MotivoFila.existe).length;
    final errores = _filas
        .where((f) => !f.valida && f.motivo != MotivoFila.existe)
        .toList();
    final familias = {
      for (final f in validas)
        if (f.conTutor && edadDe(f.fecha!) < 18) f.correo,
    }.length;
    return [
      _linea(
        Icons.check_circle_outline,
        l.impListos(validas.length),
        color: cs.primary,
        clave: const Key('imp-listos'),
      ),
      if (existen > 0)
        _linea(
          Icons.person_outline,
          l.impYaExisten(existen),
          clave: const Key('imp-existen'),
        ),
      if (errores.isNotEmpty)
        _linea(
          Icons.error_outline,
          l.impConErrores(errores.length),
          color: cs.error,
          clave: const Key('imp-errores'),
        ),
      if (familias > 0)
        _linea(
          Icons.mark_email_unread_outlined,
          l.impFamiliasCorreo(familias),
          clave: const Key('imp-familias'),
        ),
      if (errores.isNotEmpty) ...[
        const SizedBox(height: 8),
        for (final f in errores.take(30))
          Padding(
            padding: const EdgeInsets.only(left: 30, top: 2),
            child: Text(
              l.impFila(
                f.linea,
                f.nombreCompleto.isEmpty ? '—' : f.nombreCompleto,
                _textoMotivo(l, f.motivo!),
              ),
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: cs.error),
            ),
          ),
        if (errores.length > 30)
          Padding(
            padding: const EdgeInsets.only(left: 30, top: 2),
            child: Text(
              l.impYOtras(errores.length - 30),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
      ],
      const SizedBox(height: 8),
      TextButton.icon(
        key: const Key('imp-volver'),
        onPressed: () => setState(() => _fase = _Fase.entrada),
        icon: const Icon(Icons.arrow_back),
        label: Text(l.impVolver),
      ),
    ];
  }

  List<Widget> _enCurso(AppL10n l) => [
    LinearProgressIndicator(value: _total == 0 ? null : _hechas / _total),
    const SizedBox(height: 12),
    Text(l.impProgreso(_hechas, _total), key: const Key('imp-progreso')),
  ];

  List<Widget> _hecho(AppL10n l) {
    final cs = Theme.of(context).colorScheme;
    final r = _resultado!;
    return [
      _linea(
        Icons.check_circle_outline,
        l.impCreados(r.creados),
        color: cs.primary,
        clave: const Key('imp-creados'),
      ),
      if (r.fallos.isNotEmpty) ...[
        _linea(
          Icons.error_outline,
          l.impFallidos(r.fallos.length),
          color: cs.error,
          clave: const Key('imp-fallidos'),
        ),
        for (final (f, motivo) in r.fallos.take(30))
          Padding(
            padding: const EdgeInsets.only(left: 30, top: 2),
            child: Text(
              l.impFila(f.linea, f.nombreCompleto, motivo),
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: cs.error),
            ),
          ),
      ],
      if (r.correosOk != null)
        _linea(
          r.correosOk! ? Icons.mark_email_read_outlined : Icons.warning_amber,
          r.correosOk! ? l.impCorreosOk : l.impCorreosFallo,
          clave: const Key('imp-correos'),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final validas = _filas.where((f) => f.valida).length;
    final (etiqueta, accion) = switch (_fase) {
      _Fase.entrada => (
        l.impRevisar,
        _texto.text.trim().isEmpty ? null : _revisar,
      ),
      _Fase.revision => (l.impBoton(validas), validas == 0 ? null : _importar),
      _Fase.enCurso => (l.impImportando, null),
      _Fase.hecho => (
        l.cerrar,
        () => Navigator.of(context).pop((_resultado?.creados ?? 0) > 0),
      ),
    };
    return HojaFormulario(
      icono: Icons.upload_file_outlined,
      titulo: l.impTitulo,
      subtitulo: l.impSub,
      etiquetaAccion: etiqueta,
      iconoAccion: _fase == _Fase.hecho ? Icons.check : Icons.arrow_forward,
      enviando: _fase == _Fase.enCurso,
      onAccion: accion,
      children: switch (_fase) {
        _Fase.entrada => _entrada(l),
        _Fase.revision => _revision(l),
        _Fase.enCurso => _enCurso(l),
        _Fase.hecho => _hecho(l),
      },
    );
  }
}
