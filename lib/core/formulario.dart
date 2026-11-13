import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme.dart';
import 'widgets.dart';

/// Abre un formulario con presentación adaptable:
/// hoja inferior en móvil (se adapta al teclado) y diálogo centrado en pantallas anchas.
Future<T?> mostrarFormulario<T>(BuildContext context, WidgetBuilder builder) {
  if (MediaQuery.sizeOf(context).width < Pantalla.compacta) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
        child: builder(ctx),
      ),
    );
  }
  return showDialog<T>(
    context: context,
    builder: (ctx) => Dialog(
      clipBehavior: Clip.antiAlias,
      insetPadding: const EdgeInsets.all(24),
      child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 520), child: builder(ctx)),
    ),
  );
}

/// Estructura común de un formulario: cabecera con icono, cuerpo desplazable y pie fijo con acciones.
class HojaFormulario extends StatelessWidget {
  const HojaFormulario({
    super.key,
    required this.icono,
    required this.titulo,
    this.subtitulo,
    required this.children,
    this.etiquetaAccion,
    this.onAccion,
    this.iconoAccion,
    this.enviando = false,
    this.formKey,
  });
  final IconData icono;
  final String titulo;
  final String? subtitulo;
  final List<Widget> children;
  final String? etiquetaAccion;
  final IconData? iconoAccion;
  final VoidCallback? onAccion;
  final bool enviando;
  final GlobalKey<FormState>? formKey;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final cs = tema.colorScheme;
    final movil = MediaQuery.sizeOf(context).width < Pantalla.compacta;
    return Column(mainAxisSize: MainAxisSize.min, children: [
      // Cabecera
      Container(
        padding: EdgeInsets.fromLTRB(24, movil ? 4 : 24, 12, 18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [lima.withValues(alpha: .16), menta.withValues(alpha: .04)],
          ),
          border: Border(bottom: BorderSide(color: Marca.de(context).borde)),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [lima, menta]),
              boxShadow: [BoxShadow(color: lima.withValues(alpha: .35), blurRadius: 18, offset: const Offset(0, 6))],
            ),
            child: Icon(icono, color: tinta, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(titulo, style: tema.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -.4)),
                if (subtitulo != null) ...[
                  const SizedBox(height: 4),
                  Text(subtitulo!, style: tema.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
                ],
              ]),
            ),
          ),
          IconButton(
            tooltip: 'Cerrar',
            onPressed: enviando ? null : () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
          ),
        ]),
      ),
      // Cuerpo
      Flexible(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 22, 24, 8),
          child: Form(
            key: formKey,
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
          ),
        ),
      ),
      // Pie fijo
      Padding(
        padding: EdgeInsets.fromLTRB(24, 12, 24, movil ? 20 : 24),
        child: Row(children: [
          if (etiquetaAccion == null)
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(foregroundColor: cs.onSurface, side: BorderSide(color: cs.outline)),
                child: const Text('Cancelar'),
              ),
            )
          else ...[
          if (!movil) ...[
            Expanded(
              flex: 2,
              child: OutlinedButton(
                onPressed: enviando ? null : () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(foregroundColor: cs.onSurface, side: BorderSide(color: cs.outline)),
                child: const Text('Cancelar'),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            flex: 3,
            child: FilledButton(
              onPressed: enviando ? null : onAccion,
              style: FilledButton.styleFrom(minimumSize: const Size(64, 52), padding: const EdgeInsets.symmetric(horizontal: 14)),
              child: enviando
                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: tinta))
                  : Row(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [
                      if (iconoAccion != null) ...[Icon(iconoAccion, size: 20), const SizedBox(width: 8)],
                      Flexible(child: Text(etiquetaAccion!, overflow: TextOverflow.ellipsis, maxLines: 1)),
                    ]),
            ),
          ),
          ],
        ]),
      ),
    ]);
  }
}

/// Separación estándar entre campos.
const espacioCampo = SizedBox(height: 18);

/// Decoración de campo con icono, coherente en todos los formularios.
InputDecoration decoracionCampo(String etiqueta, IconData icono, {String? ayuda, Widget? sufijo}) => InputDecoration(
      labelText: etiqueta,
      hintText: ayuda,
      prefixIcon: Icon(icono, size: 22),
      suffixIcon: sufijo,
    );

/// Selector de una opción entre varias, con tarjetas grandes (icono + título + descripción).
class SelectorTarjetas<T> extends StatelessWidget {
  const SelectorTarjetas({
    super.key,
    required this.etiqueta,
    required this.opciones,
    required this.valor,
    required this.onCambio,
  });
  final String etiqueta;
  final List<OpcionTarjeta<T>> opciones;
  final T? valor;
  final ValueChanged<T> onCambio;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final cs = tema.colorScheme;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(etiqueta, style: tema.textTheme.labelLarge?.copyWith(color: cs.onSurfaceVariant)),
      const SizedBox(height: 10),
      LayoutBuilder(builder: (context, c) {
        final columnas = c.maxWidth >= 400 ? 2 : 1;
        final ancho = (c.maxWidth - (columnas - 1) * 10) / columnas;
        return Wrap(spacing: 10, runSpacing: 10, children: [
          for (final o in opciones)
            SizedBox(
              width: ancho,
              child: _Tarjeta(opcion: o, activa: o.valor == valor, onTap: () => onCambio(o.valor)),
            ),
        ]);
      }),
    ]);
  }
}

class OpcionTarjeta<T> {
  const OpcionTarjeta(this.valor, this.titulo, this.icono, {this.descripcion, this.clave});
  final T valor;
  final String titulo;
  final String? descripcion;
  final IconData icono;
  final Key? clave;
}

class _Tarjeta<T> extends StatelessWidget {
  const _Tarjeta({required this.opcion, required this.activa, required this.onTap});
  final OpcionTarjeta<T> opcion;
  final bool activa;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final cs = tema.colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: activa ? lima.withValues(alpha: .12) : cristal,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: activa ? lima : bordeCristal, width: activa ? 1.6 : 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: opcion.clave,
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              Icon(opcion.icono, color: activa ? lima : cs.onSurfaceVariant, size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(opcion.titulo, style: tema.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                  if (opcion.descripcion != null)
                    Text(opcion.descripcion!, style: tema.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                ]),
              ),
              if (activa) const Icon(Icons.check_circle, color: lima, size: 20),
            ]),
          ),
        ),
      ),
    );
  }
}

/// Inserta las barras de «dd/mm/aaaa» mientras se escribe (solo dígitos, máx. 8).
class FormateadorFecha extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue anterior, TextEditingValue nuevo) {
    final t = nuevo.text;
    // Si ya trae barras (pegado o valor completo) se respeta tal cual, filtrando caracteres.
    final soloValido = t.replaceAll(RegExp(r'[^0-9/]'), '');
    if (soloValido.contains('/')) {
      final v = soloValido.length > 10 ? soloValido.substring(0, 10) : soloValido;
      return TextEditingValue(text: v, selection: TextSelection.collapsed(offset: v.length));
    }
    final d = soloValido.length > 8 ? soloValido.substring(0, 8) : soloValido;
    final b = StringBuffer();
    for (var i = 0; i < d.length; i++) {
      if (i == 2 || i == 4) b.write('/');
      b.write(d[i]);
    }
    final s = b.toString();
    return TextEditingValue(text: s, selection: TextSelection.collapsed(offset: s.length));
  }
}

/// Elige un elemento de una lista con el mismo diseño de formulario; devuelve el valor tocado.
Future<T?> elegirDeLista<T>(
  BuildContext context, {
  required IconData icono,
  required String titulo,
  String? subtitulo,
  required List<(T valor, String titulo, String? detalle)> opciones,
  required String vacio,
}) =>
    mostrarFormulario<T>(
      context,
      (ctx) => HojaFormulario(
        icono: icono,
        titulo: titulo,
        subtitulo: subtitulo,
        children: [
          if (opciones.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(vacio,
                  textAlign: TextAlign.center,
                  style: Theme.of(ctx).textTheme.bodyLarge?.copyWith(color: Theme.of(ctx).colorScheme.onSurfaceVariant)),
            )
          else
            for (final o in opciones)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Material(
                  color: cristal,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: bordeCristal)),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => Navigator.of(ctx).pop(o.$1),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      child: Row(children: [
                        AvatarEquipo(o.$2, tam: 38),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(o.$2, style: Theme.of(ctx).textTheme.titleSmall),
                            if (o.$3 != null)
                              Text(o.$3!, style: Theme.of(ctx).textTheme.bodySmall?.copyWith(color: Theme.of(ctx).colorScheme.onSurfaceVariant)),
                          ]),
                        ),
                        const Icon(Icons.chevron_right),
                      ]),
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
