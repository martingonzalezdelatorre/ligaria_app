import 'package:flutter/material.dart';
import 'package:ligaria_ui/ligaria_ui.dart';

/// Validadores compartidos.
String? validarEmail(String? v) {
  final t = v?.trim() ?? '';
  if (t.isEmpty) return 'Introduce tu email';
  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(t)) return 'Email no válido';
  return null;
}

String? validarPassword(String? v) {
  if (v == null || v.isEmpty) return 'Introduce tu contraseña';
  if (v.length < 8) return 'Mínimo 8 caracteres';
  return null;
}

/// Armazón de las pantallas de acceso: fondo aurora + panel de marca (solo en pantallas anchas)
/// y tarjeta de cristal con el formulario.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({super.key, required this.child, this.atras = false});
  final Widget child;
  final bool atras;

  @override
  Widget build(BuildContext context) {
    final ancha = Pantalla.esAncha(context);
    return Scaffold(
      body: FondoBlobs(
        child: SafeArea(
          child: Stack(children: [
            if (ancha)
              Row(children: [
                const Expanded(child: _PanelMarca()),
                Expanded(child: _Formulario(child: child)),
              ])
            else
              _Formulario(cabecera: true, child: child),
            if (atras)
              Positioned(
                left: 8,
                top: 8,
                child: IconButton.filledTonal(
                  tooltip: 'Volver',
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
              ),
          ]),
        ),
      ),
    );
  }
}

class _Formulario extends StatelessWidget {
  const _Formulario({required this.child, this.cabecera = false});
  final Widget child;
  final bool cabecera;

  @override
  Widget build(BuildContext context) => Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, cabecera ? 56 : 24, 20, 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              if (cabecera) ...[
                const Aparece(child: _Marca()),
                const SizedBox(height: 24),
              ],
              Aparece(
                retardo: 120,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: cristal,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: bordeCristal),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .35), blurRadius: 40, offset: const Offset(0, 20))],
                  ),
                  // Material propio para que las tintas (ListTile, checkbox) no queden tapadas por la tarjeta.
                  child: Material(type: MaterialType.transparency, child: child),
                ),
              ),
            ]),
          ),
        ),
      );
}

class _Marca extends StatelessWidget {
  const _Marca();
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
        const LogoLigaria(tam: 44, icono: Icons.groups),
        const SizedBox(width: 12),
        Flexible(
          child: Text('Ligaria Friends',
              maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleLarge?.copyWith(letterSpacing: -.5)),
        ),
      ]);
}

class _PanelMarca extends StatelessWidget {
  const _PanelMarca();
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(32),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(36),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF16301F), Color(0xFF0B1F18)]),
          ),
          child: Stack(children: [
            Positioned.fill(child: CustomPaint(painter: const PistaPainter(linea: lima, opacidad: .16, grosor: 2))),
            const Positioned(right: 36, top: 36, child: BolaTenis(tam: 64)),
            Padding(
              padding: const EdgeInsets.all(44),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const _Marca(),
                const Spacer(),
                const Wrap(spacing: 8, runSpacing: 8, children: [
                  Insignia('Tenis', icono: Icons.sports_tennis),
                  Insignia('Pádel', icono: Icons.sports_baseball),
                ]),
                const SizedBox(height: 20),
                Text('Tu liga.\nTus amigos.\nTu pista.', style: t.displaySmall?.copyWith(height: 1.02)),
                const SizedBox(height: 16),
                Text('Organiza partidos de tenis y pádel, sube al ranking y presume de victorias.',
                    style: t.bodyLarge?.copyWith(color: cs.onSurfaceVariant)),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

/// Campo de contraseña con botón mostrar/ocultar.
class CampoPassword extends StatefulWidget {
  const CampoPassword({
    super.key,
    required this.controller,
    this.etiqueta = 'Contraseña',
    this.validator = validarPassword,
    this.accion = TextInputAction.done,
    this.onEnviar,
  });
  final TextEditingController controller;
  final String etiqueta;
  final String? Function(String?) validator;
  final TextInputAction accion;
  final VoidCallback? onEnviar;

  @override
  State<CampoPassword> createState() => _CampoPasswordState();
}

class _CampoPasswordState extends State<CampoPassword> {
  bool _oculta = true;
  @override
  Widget build(BuildContext context) => TextFormField(
        controller: widget.controller,
        obscureText: _oculta,
        autofillHints: const [AutofillHints.password],
        textInputAction: widget.accion,
        validator: widget.validator,
        onFieldSubmitted: (_) => widget.onEnviar?.call(),
        decoration: decoracionCampo(
          widget.etiqueta,
          Icons.lock_outline_rounded,
          sufijo: IconButton(
            tooltip: _oculta ? 'Mostrar contraseña' : 'Ocultar contraseña',
            onPressed: () => setState(() => _oculta = !_oculta),
            icon: Icon(_oculta ? Icons.visibility_outlined : Icons.visibility_off_outlined),
          ),
        ),
      );
}

/// Botón principal con estado de carga.
class BotonPrincipal extends StatelessWidget {
  const BotonPrincipal({super.key, required this.texto, required this.onPressed, this.cargando = false});
  final String texto;
  final VoidCallback onPressed;
  final bool cargando;
  @override
  Widget build(BuildContext context) => FilledButton(
        onPressed: cargando ? null : onPressed,
        style: FilledButton.styleFrom(minimumSize: const Size(64, 54)),
        child: cargando
            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: tinta))
            : Text(texto, style: const TextStyle(fontSize: 16)),
      );
}

/// Mensaje de error en línea.
class AvisoError extends StatelessWidget {
  const AvisoError(this.texto, {super.key});
  final String texto;
  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme.error;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: c.withValues(alpha: .12), borderRadius: BorderRadius.circular(12), border: Border.all(color: c.withValues(alpha: .4))),
      child: Row(children: [
        Icon(Icons.error_outline, color: c, size: 20),
        const SizedBox(width: 10),
        Expanded(child: Text(texto)),
      ]),
    );
  }
}
