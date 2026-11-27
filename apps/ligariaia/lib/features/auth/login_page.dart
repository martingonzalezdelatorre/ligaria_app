import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:ligaria_ui/ligaria_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/auth.dart';
import '../../core/config.dart';
import '../../core/enlaces.dart';
import '../../core/idioma.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});
  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _cargando = false;
  bool _ocultar = true;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      await ref
          .read(authRepositoryProvider)
          .iniciarSesion(_email.text, _pass.text);
    } catch (_) {
      if (mounted) setState(() => _error = context.l10n.loginError);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ancha = Pantalla.esAncha(context);
    final Widget cuerpo;
    if (!ancha) {
      cuerpo = SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Aparece(child: const _Marca()),
                  const SizedBox(height: 28),
                  Aparece(
                    retardo: 150,
                    child: _tarjeta(context, compacta: true),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      cuerpo = Row(
        children: [
          Expanded(
            flex: 6,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 40),
              child: Center(
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 580),
                    child: _Portada(
                      alto: (MediaQuery.sizeOf(context).height * .36).clamp(
                        150.0,
                        300.0,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Aparece(retardo: 200, child: _tarjeta(context)),
                ),
              ),
            ),
          ),
        ],
      );
    }
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: FondoBlobs(
        child: Stack(
          children: [
            Positioned.fill(child: cuerpo),
            Positioned(
              top: 8,
              right: 8,
              child: SafeArea(
                child: SelectorIdioma(color: _Tono.de(context).textoSuave),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Tarjeta de cristal esmerilado (oscuro) o tarjeta blanca (claro) con el formulario.
  Widget _tarjeta(BuildContext context, {bool compacta = false}) {
    final base = Theme.of(context);
    final tono = _Tono.de(context);
    final borde = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: tono.campoBorde),
    );
    final tema = base.copyWith(
      textTheme: base.textTheme.apply(
        bodyColor: tono.texto,
        displayColor: tono.texto,
      ),
      iconTheme: IconThemeData(color: tono.textoSuave),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: tono.campoRelleno,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        border: borde,
        enabledBorder: borde,
        focusedBorder: borde.copyWith(
          borderSide: BorderSide(color: tono.acento, width: 1.6),
        ),
        errorBorder: borde.copyWith(borderSide: BorderSide(color: tono.error)),
        focusedErrorBorder: borde.copyWith(
          borderSide: BorderSide(color: tono.error, width: 1.6),
        ),
        labelStyle: TextStyle(color: tono.textoTenue),
        floatingLabelStyle: TextStyle(color: tono.acento),
        prefixIconColor: WidgetStateColor.resolveWith(
          (s) => s.contains(WidgetState.focused) ? tono.acento : tono.textoTenue,
        ),
        suffixIconColor: tono.textoTenue,
        errorStyle: TextStyle(color: tono.error),
      ),
      textSelectionTheme: TextSelectionThemeData(cursorColor: tono.acento),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: tono.acento),
      ),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          padding: EdgeInsets.all(compacta ? 24 : 36),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: tono.tarjetaBorde),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: tono.tarjetaGradiente,
            ),
            boxShadow: [
              BoxShadow(
                color: tono.tarjetaSombra,
                blurRadius: 50,
                offset: const Offset(0, 24),
              ),
            ],
          ),
          child: Theme(data: tema, child: _formulario(context)),
        ),
      ),
    );
  }

  Widget _formulario(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final tono = _Tono.de(context);
    return AutofillGroup(
      child: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Icono vectorial: el emoji 👋 no se pinta bien en Flutter web / sin fuente de emojis.
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: context.l10n.loginHola),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Icon(
                      Icons.waving_hand_rounded,
                      size: t.headlineSmall?.fontSize,
                      color: tono.claro
                          ? const Color(0xFFD4A85A)
                          : const Color(0xFFFFC857),
                    ),
                  ),
                ],
              ),
              style: t.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -.3,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              context.l10n.loginSubtitulo,
              style: t.bodyMedium?.copyWith(color: tono.textoTenue),
            ),
            const SizedBox(height: 28),
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              decoration: InputDecoration(
                labelText: context.l10n.correoElectronico,
                prefixIcon: const Icon(Icons.mail_outline_rounded),
              ),
              validator: (v) => (v == null || !v.contains('@'))
                  ? context.l10n.correoInvalido
                  : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _pass,
              obscureText: _ocultar,
              autofillHints: const [AutofillHints.password],
              decoration: InputDecoration(
                labelText: context.l10n.contrasena,
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  tooltip: _ocultar
                      ? context.l10n.mostrarContrasena
                      : context.l10n.ocultarContrasena,
                  icon: Icon(
                    _ocultar
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                  onPressed: () => setState(() => _ocultar = !_ocultar),
                ),
              ),
              validator: (v) => (v == null || v.isEmpty)
                  ? context.l10n.introduceContrasena
                  : null,
              onFieldSubmitted: (_) => _entrar(),
            ),
            if (_error != null) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF5252).withValues(alpha: .14),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: tono.error.withValues(alpha: .5)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 20,
                      color: tono.error,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _error!,
                        style: TextStyle(color: tono.errorTexto),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => context.push('/recuperar'),
                child: Text(context.l10n.olvidoContrasena),
              ),
            ),
            const SizedBox(height: 10),
            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: tono.botonFondo.withValues(alpha: .35),
                    blurRadius: 28,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: FilledButton(
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                  backgroundColor: tono.botonFondo,
                  foregroundColor: tono.botonTexto,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                onPressed: _cargando ? null : _entrar,
                child: _cargando
                    ? SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: tono.botonTexto,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(context.l10n.entrar),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded, size: 20),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: Divider(color: tono.divisor)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    context.l10n.loginPrimeraVez,
                    style: t.bodySmall?.copyWith(color: tono.textoTenue),
                  ),
                ),
                Expanded(child: Divider(color: tono.divisor)),
              ],
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              key: const Key('login-registro'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                foregroundColor: tono.texto,
                side: BorderSide(color: tono.botonBorde),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.school_outlined, size: 20),
              label: Text(
                context.l10n.loginRegistrar,
                textAlign: TextAlign.center,
              ),
              onPressed: () => abrirEnlace(context, ref, AppConfig.registroUrl),
            ),
            const SizedBox(height: 6),
            TextButton.icon(
              key: const Key('login-invitacion'),
              icon: const Icon(Icons.mark_email_read_outlined, size: 20),
              label: Text(context.l10n.loginInvitacion),
              onPressed: () => abrirEnlace(context, ref, AppConfig.familiasUrl),
            ),
          ],
        ),
      ),
    );
  }
}

/// Colores de la pantalla de acceso según el modo: cristal blanco sobre fondo oscuro, o tarjeta
/// blanca limpia sobre fondo claro.
class _Tono {
  const _Tono(this.claro);
  factory _Tono.de(BuildContext c) =>
      _Tono(Theme.of(c).brightness == Brightness.light);
  final bool claro;

  Color get texto => claro ? tintaClara : Colors.white;
  Color get textoSuave => claro ? const Color(0xFF4F5A56) : Colors.white70;
  Color get textoTenue => claro ? textoSecundarioClaro : Colors.white60;
  Color get acento => claro ? primarioClaro : lima;
  Color get error => claro ? const Color(0xFFB4473F) : const Color(0xFFFF8A80);
  Color get errorTexto =>
      claro ? const Color(0xFF8E342E) : const Color(0xFFFFB4AB);
  Color get divisor => claro ? bordeClaro : Colors.white24;
  Color get botonFondo => claro ? primarioClaro : lima;
  Color get botonTexto => claro ? Colors.white : tinta;
  Color get botonBorde => claro ? const Color(0xFFC5CEC8) : Colors.white38;
  Color get campoBorde => claro ? bordeClaro : const Color(0x24FFFFFF);
  Color get campoRelleno =>
      claro ? const Color(0xFFF7F9F6) : Colors.white.withValues(alpha: .07);
  Color get tarjetaBorde =>
      claro ? Colors.white : Colors.white.withValues(alpha: .16);
  List<Color> get tarjetaGradiente => claro
      ? [Colors.white.withValues(alpha: .96), Colors.white.withValues(alpha: .86)]
      : [
          Colors.white.withValues(alpha: .13),
          Colors.white.withValues(alpha: .04),
        ];
  Color get tarjetaSombra =>
      claro ? tintaClara.withValues(alpha: .10) : const Color(0x66000000);
  Color get chipFondo =>
      claro ? Colors.white.withValues(alpha: .8) : Colors.white.withValues(alpha: .07);
  Color get chipBorde =>
      claro ? bordeClaro : Colors.white.withValues(alpha: .14);
  List<Color> get titular =>
      claro ? const [tintaClara, primarioClaro] : const [Colors.white, lima];
  Color get brillo => claro ? primarioClaro : lima;
}

class _Marca extends StatelessWidget {
  const _Marca();
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      const LogoLigaria(tam: 46),
      const SizedBox(width: 12),
      Text(
        'Ligaria',
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
          color: _Tono.de(context).texto,
          fontWeight: FontWeight.w800,
          letterSpacing: -.5,
        ),
      ),
    ],
  );
}

/// Mitad izquierda en pantallas anchas: marca, titular, ventajas e ilustración.
class _Portada extends StatelessWidget {
  const _Portada({required this.alto});
  final double alto;

  Widget _chip(_Tono tono, IconData i, String t) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
    decoration: BoxDecoration(
      color: tono.chipFondo,
      borderRadius: BorderRadius.circular(40),
      border: Border.all(color: tono.chipBorde),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(i, size: 16, color: tono.acento),
        const SizedBox(width: 8),
        Text(
          t,
          style: TextStyle(
            color: tono.texto,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final tono = _Tono.de(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Aparece(child: const _Marca()),
        const SizedBox(height: 36),
        Aparece(
          retardo: 100,
          child: ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (r) =>
                LinearGradient(colors: tono.titular).createShader(r),
            child: Text(
              context.l10n.portadaTitular,
              style: t.displayMedium?.copyWith(
                fontWeight: FontWeight.w800,
                height: 1.05,
                letterSpacing: -1.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Aparece(
          retardo: 200,
          child: Text(
            context.l10n.portadaSub,
            style: t.titleMedium?.copyWith(color: tono.textoSuave, height: 1.4),
          ),
        ),
        const SizedBox(height: 22),
        Aparece(
          retardo: 300,
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _chip(tono, Icons.calendar_month_rounded, context.l10n.calendarios),
              _chip(tono, Icons.scoreboard_rounded, context.l10n.resultados),
              _chip(tono, Icons.leaderboard_rounded, context.l10n.clasificacion),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Aparece(
          retardo: 400,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: tono.brillo.withValues(alpha: .18),
                  blurRadius: 60,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: HeroPista(alto: alto, radio: 32),
          ),
        ),
      ],
    );
  }
}
