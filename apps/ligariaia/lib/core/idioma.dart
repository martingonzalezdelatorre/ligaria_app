import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ligaria_notificaciones/ligaria_notificaciones.dart';
import '../l10n/app_localizations.dart';

export '../l10n/app_localizations.dart';

/// Idiomas disponibles, cada uno con su nombre en su propia lengua.
const idiomasApp = <(Locale, String)>[
  (Locale('es'), 'Español'),
  (Locale('gl'), 'Galego'),
  (Locale('ca'), 'Català'),
  (Locale('eu'), 'Euskara'),
  (Locale('en'), 'English'),
  (Locale('fr'), 'Français'),
];

/// Idioma activo (para textos que se formatean sin acceso a `BuildContext`, como las fechas).
String codigoIdiomaActual = 'es';

/// Traducciones del idioma activo, para textos que se generan sin `BuildContext`.
AppL10n get l10nActual => lookupAppL10n(Locale(codigoIdiomaActual));

/// Idioma elegido por la persona, guardado en el dispositivo. Español por defecto.
class IdiomaNotifier extends Notifier<Locale> {
  static const _clave = 'idioma';

  @override
  Locale build() {
    _cargar();
    return const Locale('es');
  }

  Future<void> _cargar() async {
    try {
      final c = (await SharedPreferences.getInstance()).getString(_clave);
      final l = idiomasApp.where((x) => x.$1.languageCode == c).firstOrNull;
      if (l != null) _aplicar(l.$1);
    } catch (_) {}
  }

  void _aplicar(Locale l) {
    codigoIdiomaActual = l.languageCode;
    final t = l10nActual;
    TextosNotificaciones.actual = TextosNotificaciones(
      ver: t.ntVer,
      notificaciones: t.ntNotificaciones,
      marcarLeidas: t.ntMarcarLeidas,
      preferencias: t.ntPreferencias,
      errorCargarReintentar: t.ntErrorCargar,
      sinNotificaciones: t.ntSinNotificaciones,
      errorGuardar: t.ntErrorGuardar,
      preferenciasAvisos: t.ntPreferenciasAvisos,
      errorCargarPreferencias: t.ntErrorPreferencias,
      enLaApp: t.ntEnLaApp,
      porEmail: t.ntPorEmail,
      ahora: t.ntAhora,
      haceMin: t.ntHaceMin('{n}'),
      haceHoras: t.ntHaceHoras('{n}'),
      haceDias: t.ntHaceDias('{n}'),
    );
    state = l;
    // Los textos generados sin contexto no dependen del idioma: se fuerza a repintar todo el árbol.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      void marcar(Element e) {
        e.markNeedsBuild();
        e.visitChildren(marcar);
      }

      WidgetsBinding.instance.rootElement?.visitChildren(marcar);
    });
  }

  Future<void> set(Locale l) async {
    _aplicar(l);
    try {
      await (await SharedPreferences.getInstance()).setString(
        _clave,
        l.languageCode,
      );
    } catch (_) {}
  }
}

final idiomaProvider = NotifierProvider<IdiomaNotifier, Locale>(
  IdiomaNotifier.new,
);

extension L10nContexto on BuildContext {
  AppL10n get l10n => AppL10n.of(this);
}

/// Menú para cambiar de idioma.
class SelectorIdioma extends ConsumerWidget {
  const SelectorIdioma({super.key, this.color});
  final Color? color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actual = ref.watch(idiomaProvider);
    return PopupMenuButton<Locale>(
      key: const Key('selector-idioma'),
      tooltip: context.l10n.idioma,
      icon: Icon(Icons.language, color: color),
      initialValue: actual,
      onSelected: (l) => ref.read(idiomaProvider.notifier).set(l),
      itemBuilder: (_) => [
        for (final (l, nombre) in idiomasApp)
          PopupMenuItem(value: l, child: Text(nombre)),
      ],
    );
  }
}

/// Etiqueta del parentesco (el valor guardado sigue siendo el texto en español).
String etiquetaParentesco(AppL10n l, String? v) => switch (v) {
  'Madre' => l.parMadre,
  'Padre' => l.parPadre,
  'Tutor legal' => l.parTutorLegal,
  'Otro familiar' => l.parOtroFamiliar,
  _ => v ?? '',
};

/// Nombre del deporte en el idioma activo (los demás se muestran tal cual vienen).
String nombreDeporte(String? valor) {
  final v = (valor ?? '').toLowerCase().replaceAll('á', 'a');
  return switch (v) {
    'tenis' => l10nActual.deporteTenis,
    'padel' => l10nActual.deportePadel,
    _ => valor ?? '',
  };
}
