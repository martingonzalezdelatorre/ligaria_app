import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Sustituye a [TextField]: igual, pero con un botón para borrar de golpe todo el texto
/// (aparece solo cuando hay algo escrito). Si el campo ya tiene un `suffixIcon`
/// (p. ej. el ojo de una contraseña), el botón de borrar va a su izquierda.
class CampoTexto extends StatelessWidget {
  const CampoTexto({
    super.key,
    this.controller,
    this.focusNode,
    this.decoration = const InputDecoration(),
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.style,
    this.textAlign = TextAlign.start,
    this.autofocus = false,
    this.obscureText = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.enabled,
    this.autofillHints,
    this.inputFormatters,
    this.onChanged,
    this.onSubmitted,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final InputDecoration decoration;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final TextStyle? style;
  final TextAlign textAlign;
  final bool autofocus, obscureText;
  final int? maxLines, minLines, maxLength;
  final bool? enabled;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) => _ConBorrar(
    controller: controller,
    enabled: enabled ?? true,
    decoration: decoration,
    onChanged: onChanged,
    builder: (ctrl, deco) => TextField(
      controller: ctrl,
      focusNode: focusNode,
      decoration: deco,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      textCapitalization: textCapitalization,
      style: style,
      textAlign: textAlign,
      autofocus: autofocus,
      obscureText: obscureText,
      maxLines: maxLines,
      minLines: minLines,
      maxLength: maxLength,
      enabled: enabled,
      autofillHints: autofillHints,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
    ),
  );
}

/// Sustituye a [TextFormField] con el mismo botón de borrar.
class CampoTextoForm extends StatelessWidget {
  const CampoTextoForm({
    super.key,
    this.controller,
    this.initialValue,
    this.focusNode,
    this.decoration = const InputDecoration(),
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.style,
    this.textAlign = TextAlign.start,
    this.autofocus = false,
    this.obscureText = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.enabled,
    this.autofillHints,
    this.inputFormatters,
    this.validator,
    this.autovalidateMode,
    this.onChanged,
    this.onFieldSubmitted,
  });

  final TextEditingController? controller;
  final String? initialValue;
  final FocusNode? focusNode;
  final InputDecoration decoration;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final TextStyle? style;
  final TextAlign textAlign;
  final bool autofocus, obscureText;
  final int? maxLines, minLines, maxLength;
  final bool? enabled;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;
  final FormFieldValidator<String>? validator;
  final AutovalidateMode? autovalidateMode;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  Widget build(BuildContext context) => _ConBorrar(
    controller: controller,
    initialValue: initialValue,
    enabled: enabled ?? true,
    decoration: decoration,
    onChanged: onChanged,
    builder: (ctrl, deco) => TextFormField(
      controller: ctrl,
      focusNode: focusNode,
      decoration: deco,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      textCapitalization: textCapitalization,
      style: style,
      textAlign: textAlign,
      autofocus: autofocus,
      obscureText: obscureText,
      maxLines: maxLines,
      minLines: minLines,
      maxLength: maxLength,
      enabled: enabled,
      autofillHints: autofillHints,
      inputFormatters: inputFormatters,
      validator: validator,
      autovalidateMode: autovalidateMode,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
    ),
  );
}

/// Gestiona el controlador (propio si no se pasa uno) y añade el botón de borrar a la decoración.
class _ConBorrar extends StatefulWidget {
  const _ConBorrar({
    required this.controller,
    required this.enabled,
    required this.decoration,
    required this.onChanged,
    required this.builder,
    this.initialValue,
  });
  final TextEditingController? controller;
  final String? initialValue;
  final bool enabled;
  final InputDecoration decoration;
  final ValueChanged<String>? onChanged;
  final Widget Function(TextEditingController, InputDecoration) builder;

  @override
  State<_ConBorrar> createState() => _ConBorrarState();
}

class _ConBorrarState extends State<_ConBorrar> {
  TextEditingController? _propio;
  TextEditingController get _ctrl =>
      widget.controller ??
      (_propio ??= TextEditingController(text: widget.initialValue));

  @override
  void dispose() {
    _propio?.dispose();
    super.dispose();
  }

  void _borrar() {
    _ctrl.clear();
    widget.onChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = _ctrl;
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: ctrl,
      builder: (context, v, _) {
        final d = widget.decoration;
        if (v.text.isEmpty || !widget.enabled) return widget.builder(ctrl, d);
        final borrar = IconButton(
          tooltip: MaterialLocalizations.of(context).clearButtonTooltip,
          visualDensity: VisualDensity.compact,
          onPressed: _borrar,
          icon: const Icon(Icons.cancel, size: 20),
        );
        return widget.builder(
          ctrl,
          d.copyWith(
            suffixIcon: d.suffixIcon == null
                ? borrar
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [borrar, d.suffixIcon!],
                  ),
          ),
        );
      },
    );
  }
}
