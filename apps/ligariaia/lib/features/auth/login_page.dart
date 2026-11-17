import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:ligaria_ui/ligaria_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/auth.dart';

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
      await ref.read(authRepositoryProvider).iniciarSesion(_email.text, _pass.text);
    } catch (_) {
      if (mounted) setState(() => _error = 'Correo o contraseña incorrectos.');
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
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Aparece(child: const _Marca()),
                const SizedBox(height: 28),
                Aparece(retardo: 150, child: _tarjeta(context, compacta: true)),
              ]),
            ),
          ),
        ),
      );
    } else {
      cuerpo = Row(children: [
        Expanded(
          flex: 6,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 40),
            child: Center(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 580),
                  child: _Portada(alto: (MediaQuery.sizeOf(context).height * .36).clamp(150.0, 300.0)),
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
      ]);
    }
    return Scaffold(backgroundColor: tinta, body: FondoBlobs(child: cuerpo));
  }

  /// Tarjeta de cristal esmerilado con el formulario.
  Widget _tarjeta(BuildContext context, {bool compacta = false}) {
    final base = Theme.of(context);
    final borde = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Color(0x24FFFFFF)),
    );
    final oscuro = base.copyWith(
      textTheme: base.textTheme.apply(bodyColor: Colors.white, displayColor: Colors.white),
      iconTheme: const IconThemeData(color: Colors.white70),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: .07),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        border: borde,
        enabledBorder: borde,
        focusedBorder: borde.copyWith(borderSide: const BorderSide(color: lima, width: 1.6)),
        errorBorder: borde.copyWith(borderSide: const BorderSide(color: Color(0xFFFF8A80))),
        focusedErrorBorder: borde.copyWith(borderSide: const BorderSide(color: Color(0xFFFF8A80), width: 1.6)),
        labelStyle: const TextStyle(color: Colors.white60),
        floatingLabelStyle: const TextStyle(color: lima),
        prefixIconColor: WidgetStateColor.resolveWith(
            (s) => s.contains(WidgetState.focused) ? lima : Colors.white60),
        suffixIconColor: Colors.white60,
        errorStyle: const TextStyle(color: Color(0xFFFF8A80)),
      ),
      textSelectionTheme: const TextSelectionThemeData(cursorColor: lima),
      textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: lima)),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          padding: EdgeInsets.all(compacta ? 24 : 36),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.white.withValues(alpha: .16)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white.withValues(alpha: .13), Colors.white.withValues(alpha: .04)],
            ),
            boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 50, offset: Offset(0, 24))],
          ),
          child: Theme(data: oscuro, child: _formulario(context)),
        ),
      ),
    );
  }

  Widget _formulario(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return AutofillGroup(
      child: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Hola de nuevo 👋', style: t.headlineSmall?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -.3)),
            const SizedBox(height: 6),
            Text('Entra para ver tus partidos y tu clasificación.',
                style: t.bodyMedium?.copyWith(color: Colors.white60)),
            const SizedBox(height: 28),
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              decoration: const InputDecoration(labelText: 'Correo electrónico', prefixIcon: Icon(Icons.mail_outline_rounded)),
              validator: (v) => (v == null || !v.contains('@')) ? 'Introduce un correo válido' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _pass,
              obscureText: _ocultar,
              autofillHints: const [AutofillHints.password],
              decoration: InputDecoration(
                labelText: 'Contraseña',
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  tooltip: _ocultar ? 'Mostrar contraseña' : 'Ocultar contraseña',
                  icon: Icon(_ocultar ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                  onPressed: () => setState(() => _ocultar = !_ocultar),
                ),
              ),
              validator: (v) => (v == null || v.isEmpty) ? 'Introduce tu contraseña' : null,
              onFieldSubmitted: (_) => _entrar(),
            ),
            if (_error != null) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF5252).withValues(alpha: .14),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFFF8A80).withValues(alpha: .5)),
                ),
                child: Row(children: [
                  const Icon(Icons.error_outline_rounded, size: 20, color: Color(0xFFFF8A80)),
                  const SizedBox(width: 10),
                  Expanded(child: Text(_error!, style: const TextStyle(color: Color(0xFFFFB4AB)))),
                ]),
              ),
            ],
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => context.push('/recuperar'),
                child: const Text('¿Has olvidado tu contraseña?'),
              ),
            ),
            const SizedBox(height: 10),
            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                boxShadow: [BoxShadow(color: lima.withValues(alpha: .35), blurRadius: 28, offset: const Offset(0, 8))],
              ),
              child: FilledButton(
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                  backgroundColor: lima,
                  foregroundColor: tinta,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                onPressed: _cargando ? null : _entrar,
                child: _cargando
                    ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: tinta))
                    : const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text('Entrar'),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward_rounded, size: 20),
                      ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Marca extends StatelessWidget {
  const _Marca();
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
        const LogoLigaria(tam: 46),
        const SizedBox(width: 12),
        Text('Ligaria',
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(color: Colors.white, fontWeight: FontWeight.w800, letterSpacing: -.5)),
      ]);
}

/// Mitad izquierda en pantallas anchas: marca, titular, ventajas e ilustración.
class _Portada extends StatelessWidget {
  const _Portada({required this.alto});
  final double alto;

  Widget _chip(IconData i, String t) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .07),
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: Colors.white.withValues(alpha: .14)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(i, size: 16, color: lima),
          const SizedBox(width: 8),
          Text(t, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      Aparece(child: const _Marca()),
      const SizedBox(height: 36),
      Aparece(
        retardo: 100,
        child: ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (r) => const LinearGradient(colors: [Colors.white, lima]).createShader(r),
          child: Text('Tu liga,\nen una sola pista.',
              style: t.displayMedium?.copyWith(fontWeight: FontWeight.w800, height: 1.05, letterSpacing: -1.5)),
        ),
      ),
      const SizedBox(height: 16),
      Aparece(
        retardo: 200,
        child: Text('Calendarios, resultados y clasificación siempre a mano.',
            style: t.titleMedium?.copyWith(color: Colors.white70, height: 1.4)),
      ),
      const SizedBox(height: 22),
      Aparece(
        retardo: 300,
        child: Wrap(spacing: 10, runSpacing: 10, children: [
          _chip(Icons.calendar_month_rounded, 'Calendarios'),
          _chip(Icons.scoreboard_rounded, 'Resultados'),
          _chip(Icons.leaderboard_rounded, 'Clasificación'),
        ]),
      ),
      const SizedBox(height: 32),
      Aparece(
        retardo: 400,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            boxShadow: [BoxShadow(color: lima.withValues(alpha: .18), blurRadius: 60, offset: const Offset(0, 20))],
          ),
          child: HeroPista(alto: alto, radio: 32),
        ),
      ),
    ]);
  }
}
