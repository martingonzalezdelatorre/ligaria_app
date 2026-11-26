import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ligaria_ui/ligaria_ui.dart';
import '../../core/auth.dart';
import '../../core/config.dart';
import '../../core/enlaces.dart';
import '../../core/idioma.dart';
import '../../data/liga_repository.dart';
import 'escuela_providers.dart';
import 'primeros_pasos.dart';

/// Correos sacados de un texto pegado: separados por comas, punto y coma, espacios o saltos de línea,
/// o con el formato de Outlook/Gmail «Nombre `<correo@ejemplo.com>`».
class ListaCorreos {
  const ListaCorreos(this.validos, this.repetidos, this.invalidos);

  /// Sin repetir y en minúsculas, en el orden en que aparecen.
  final List<String> validos;
  final int repetidos;

  /// Elementos que parecen un correo (llevan «@») pero no lo son.
  final List<String> invalidos;
}

final _reCorreoCompleto = RegExp(r'^[^@\s<>,;"]+@[^@\s<>,;"]+\.[^@\s<>,;"]+$');

ListaCorreos correosDeTexto(String texto) {
  final validos = <String>[];
  final vistos = <String>{};
  var repetidos = 0;
  final invalidos = <String>[];
  for (final bruto in texto.split(RegExp(r'[\s,;]+'))) {
    final t = bruto.replaceAll(RegExp(r'''^[<("']+|[>)"',.]+$'''), '');
    if (t.isEmpty || !t.contains('@')) {
      continue; // palabras sueltas: nombres, etc.
    }
    if (!_reCorreoCompleto.hasMatch(t)) {
      invalidos.add(t);
      continue;
    }
    final c = t.toLowerCase();
    if (vistos.add(c)) {
      validos.add(c);
    } else {
      repetidos++;
    }
  }
  return ListaCorreos(validos, repetidos, invalidos);
}

/// Resultado de invitar a una lista de correos.
class ResultadoBloque {
  final enviadas = <String>[];
  final fallidas = <(String, String)>[];
}

Future<ResultadoBloque> invitarEnBloque({
  required LigaRepository repo,
  required String orgId,
  required Rol rol,
  required List<String> correos,
  void Function(int hechas, int total)? progreso,
}) async {
  final r = ResultadoBloque();
  for (var i = 0; i < correos.length; i++) {
    progreso?.call(i, correos.length);
    try {
      await repo.invitar(orgId, correos[i], rol);
      r.enviadas.add(correos[i]);
    } catch (e) {
      r.fallidas.add((correos[i], mensajeErrorEscuela(e)));
    }
  }
  progreso?.call(correos.length, correos.length);
  return r;
}

/// Enlace `mailto:` con todos los destinatarios en copia oculta, para abrir el correo de la persona.
String mailtoCopiaOculta(List<String> correos, String asunto, String cuerpo) =>
    'mailto:?bcc=${Uri.encodeComponent(correos.join(','))}'
    '&subject=${Uri.encodeComponent(asunto)}'
    '&body=${Uri.encodeComponent(cuerpo)}';

/// Invita a varias personas de una vez pegando sus correos. Devuelve true si se invitó a alguna.
Future<bool> mostrarInvitarEnBloque(
  BuildContext context,
  WidgetRef ref,
  String escuelaId,
) async {
  final ok =
      await mostrarFormulario<bool>(
        context,
        (_) => InvitarBloqueDialog(escuelaId: escuelaId),
      ) ??
      false;
  if (ok) {
    ref.invalidate(usuariosEscuelaProvider(escuelaId));
    ref.invalidate(entrenadorInvitadoProvider(escuelaId));
  }
  return ok;
}

class InvitarBloqueDialog extends ConsumerStatefulWidget {
  const InvitarBloqueDialog({super.key, required this.escuelaId});
  final String escuelaId;
  @override
  ConsumerState<InvitarBloqueDialog> createState() =>
      _InvitarBloqueDialogState();
}

class _InvitarBloqueDialogState extends ConsumerState<InvitarBloqueDialog> {
  final _texto = TextEditingController();
  Rol _rol = Rol.tutor;
  bool _enviando = false;
  ResultadoBloque? _resultado;
  int _hechas = 0, _total = 0;

  @override
  void dispose() {
    _texto.dispose();
    super.dispose();
  }

  Future<void> _invitar(List<String> correos) async {
    setState(() {
      _enviando = true;
      _hechas = 0;
      _total = correos.length;
    });
    final r = await invitarEnBloque(
      repo: ref.read(ligaRepositoryProvider),
      orgId: widget.escuelaId,
      rol: _rol,
      correos: correos,
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
        _enviando = false;
      });
    }
  }

  String get _mensaje => context.l10n.bloqueMensaje(AppConfig.familiasUrl);

  Future<void> _copiarMensaje() async {
    await Clipboard.setData(ClipboardData(text: _mensaje));
    if (mounted) avisar(context, context.l10n.mensajeCopiado);
  }

  Future<void> _abrirCorreo(List<String> correos) => abrirEnlace(
    context,
    ref,
    mailtoCopiaOculta(correos, context.l10n.bloqueAsunto, _mensaje),
  );

  Map<Rol, (IconData, String)> _roles(AppL10n l) => {
    Rol.tutor: (Icons.family_restroom, l.padreMadreTutor),
    Rol.entrenador: (Icons.sports, l.rolDescEntrenador),
    Rol.adminEscuela: (Icons.admin_panel_settings_outlined, l.rolDescAdmin),
    Rol.organizadorLiga: (Icons.emoji_events_outlined, l.rolDescOrganizador),
  };

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

  List<Widget> _formulario(AppL10n l, ListaCorreos lista) {
    final cs = Theme.of(context).colorScheme;
    return [
      TextField(
        key: const Key('bloque-texto'),
        controller: _texto,
        minLines: 5,
        maxLines: 9,
        keyboardType: TextInputType.multiline,
        onChanged: (_) => setState(() {}),
        decoration: decoracionCampo(
          l.bloqueCorreos,
          Icons.alternate_email,
          ayuda: l.bloqueAyuda,
        ),
      ),
      if (lista.validos.isNotEmpty ||
          lista.repetidos > 0 ||
          lista.invalidos.isNotEmpty) ...[
        const SizedBox(height: 10),
        _linea(
          Icons.check_circle_outline,
          l.bloqueValidos(lista.validos.length),
          color: cs.primary,
          clave: const Key('bloque-validos'),
        ),
        if (lista.repetidos > 0)
          _linea(
            Icons.content_copy_outlined,
            l.bloqueRepetidos(lista.repetidos),
            clave: const Key('bloque-repetidos'),
          ),
        if (lista.invalidos.isNotEmpty)
          _linea(
            Icons.error_outline,
            l.bloqueInvalidos(lista.invalidos.take(5).join(', ')),
            color: cs.error,
            clave: const Key('bloque-invalidos'),
          ),
      ],
      espacioCampo,
      SelectorTarjetas<Rol>(
        etiqueta: l.rol,
        valor: _rol,
        onCambio: (r) => setState(() => _rol = r),
        opciones: [
          for (final e in _roles(l).entries)
            OpcionTarjeta(
              e.key,
              etiquetaRol(e.key),
              e.value.$1,
              descripcion: e.value.$2,
              clave: Key('bloque-rol-${e.key.name}'),
            ),
        ],
      ),
      if (_rol == Rol.tutor) ...[
        const SizedBox(height: 10),
        Text(
          l.sinAlumnoAviso,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
        ),
      ],
    ];
  }

  List<Widget> _hecho(AppL10n l) {
    final cs = Theme.of(context).colorScheme;
    final r = _resultado!;
    return [
      _linea(
        Icons.check_circle_outline,
        l.bloqueGuardadas(r.enviadas.length),
        color: cs.primary,
        clave: const Key('bloque-guardadas'),
      ),
      if (r.fallidas.isNotEmpty) ...[
        _linea(
          Icons.error_outline,
          l.bloqueFallidas(r.fallidas.length),
          color: cs.error,
          clave: const Key('bloque-fallidas'),
        ),
        for (final (correo, motivo) in r.fallidas.take(30))
          Padding(
            padding: const EdgeInsets.only(left: 30, top: 2),
            child: Text(
              '$correo — $motivo',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: cs.error),
            ),
          ),
      ],
      if (r.enviadas.isNotEmpty) ...[
        const SizedBox(height: 14),
        Text(
          l.bloqueAvisales,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          l.bloqueAvisalesAyuda,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton.tonalIcon(
              key: const Key('bloque-correo'),
              onPressed: () => _abrirCorreo(r.enviadas),
              icon: const Icon(Icons.mail_outline),
              label: Text(l.bloqueAbrirCorreo),
            ),
            OutlinedButton.icon(
              key: const Key('bloque-copiar'),
              onPressed: _copiarMensaje,
              icon: const Icon(Icons.copy_outlined),
              label: Text(l.bloqueCopiarMensaje),
            ),
          ],
        ),
      ],
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final hecho = _resultado != null;
    final lista = correosDeTexto(_texto.text);
    final n = lista.validos.length;
    return HojaFormulario(
      icono: Icons.group_add_outlined,
      titulo: l.bloqueTitulo,
      subtitulo: _enviando ? l.impProgreso(_hechas, _total) : l.bloqueSub,
      etiquetaAccion: hecho ? l.cerrar : l.bloqueBoton(n),
      iconoAccion: hecho ? Icons.check : Icons.send_rounded,
      enviando: _enviando,
      onAccion: hecho
          ? () => Navigator.of(context).pop(_resultado!.enviadas.isNotEmpty)
          : (n == 0 ? null : () => _invitar(lista.validos)),
      children: hecho ? _hecho(l) : _formulario(l, lista),
    );
  }
}
