import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'idioma.dart';
import 'package:ligaria_ui/ligaria_ui.dart' show avisar;

/// Abre una dirección web fuera de la app. Se sustituye en los tests.
final abrirUrlProvider = Provider<Future<bool> Function(Uri)>(
  (_) =>
      (uri) => launchUrl(uri, mode: LaunchMode.externalApplication),
);

/// Abre [url] en el navegador; si no se puede, avisa a la persona.
Future<void> abrirEnlace(
  BuildContext context,
  WidgetRef ref,
  String url,
) async {
  var ok = false;
  try {
    ok = await ref.read(abrirUrlProvider)(Uri.parse(url));
  } catch (_) {}
  if (!ok && context.mounted) avisar(context, context.l10n.errAbrirEnlace);
}
