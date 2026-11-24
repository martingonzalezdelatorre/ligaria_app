import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'config.dart';
import 'idioma.dart';

/// Abre una página legal en el navegador; avisa si no se puede abrir.
Future<void> abrirEnlaceLegal(BuildContext context, String url) async {
  final aviso = context.l10n.noSePudoAbrirEnlace;
  final mensajero = ScaffoldMessenger.of(context);
  var ok = false;
  try {
    ok = await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  } catch (_) {}
  if (!ok) mensajero.showSnackBar(SnackBar(content: Text(aviso)));
}

/// Enlaces a la política de privacidad y a los términos de uso.
class EnlacesLegales extends StatelessWidget {
  const EnlacesLegales({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Wrap(
      alignment: WrapAlignment.center,
      children: [
        TextButton(
          onPressed: () => abrirEnlaceLegal(context, AppConfig.urlPrivacidad),
          child: Text(l.politicaPrivacidad),
        ),
        TextButton(
          onPressed: () => abrirEnlaceLegal(context, AppConfig.urlTerminos),
          child: Text(l.terminosUso),
        ),
      ],
    );
  }
}
