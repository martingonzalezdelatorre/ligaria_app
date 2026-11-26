import 'package:flutter/material.dart';
import 'theme.dart';

/// Una sección de un área (icono + etiqueta + contenido).
class SeccionArea {
  const SeccionArea(
    this.icono,
    this.etiqueta,
    this.contenido, {
    this.iconoActivo,
  });
  final IconData icono;
  final IconData? iconoActivo;
  final String etiqueta;
  final Widget contenido;
}

/// Navegación de secciones adaptable: barra inferior flotante en móvil y píldoras arriba en pantallas anchas.
///
/// Con [seleccion] otro widget puede cambiar de sección (p. ej. una guía de primeros pasos):
/// al asignar un índice a ese notificador se abre esa sección.
class AreaTabs extends StatefulWidget {
  const AreaTabs({super.key, required this.secciones, this.seleccion});
  final List<SeccionArea> secciones;
  final ValueNotifier<int>? seleccion;
  @override
  State<AreaTabs> createState() => _AreaTabsState();
}

class _AreaTabsState extends State<AreaTabs> {
  int _i = 0;

  @override
  void initState() {
    super.initState();
    widget.seleccion?.addListener(_alCambiarSeleccion);
  }

  @override
  void didUpdateWidget(AreaTabs old) {
    super.didUpdateWidget(old);
    if (old.seleccion != widget.seleccion) {
      old.seleccion?.removeListener(_alCambiarSeleccion);
      widget.seleccion?.addListener(_alCambiarSeleccion);
    }
  }

  @override
  void dispose() {
    widget.seleccion?.removeListener(_alCambiarSeleccion);
    super.dispose();
  }

  /// Elección de la persona: se refleja en [AreaTabs.seleccion] para que pueda repetirse el mismo salto.
  void _elegir(int i) {
    setState(() => _i = i);
    widget.seleccion?.value = i;
  }

  void _alCambiarSeleccion() {
    final i = widget.seleccion!.value;
    if (i != _i && i >= 0 && i < widget.secciones.length) {
      setState(() => _i = i);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.secciones;
    final ancha = MediaQuery.sizeOf(context).width >= Pantalla.compacta + 120;
    final cuerpo = AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      child: KeyedSubtree(key: ValueKey(_i), child: s[_i].contenido),
    );
    if (ancha) {
      return Column(
        children: [
          _Pildoras(secciones: s, indice: _i, onSelect: _elegir),
          Expanded(child: cuerpo),
        ],
      );
    }
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: cuerpo,
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.fromLTRB(14, 0, 14, 10),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .4),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: NavigationBar(
              height: 68,
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              indicatorColor: cs.primaryContainer,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              selectedIndex: _i,
              onDestinationSelected: _elegir,
              destinations: [
                for (final x in s)
                  NavigationDestination(
                    icon: Icon(x.icono),
                    selectedIcon: Icon(
                      x.iconoActivo ?? x.icono,
                      color: cs.primary,
                    ),
                    label: x.etiqueta,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Pildoras extends StatefulWidget {
  const _Pildoras({
    required this.secciones,
    required this.indice,
    required this.onSelect,
  });
  final List<SeccionArea> secciones;
  final int indice;
  final ValueChanged<int> onSelect;

  @override
  State<_Pildoras> createState() => _PildorasState();
}

class _PildorasState extends State<_Pildoras> {
  late final _claves = List.generate(
    widget.secciones.length,
    (_) => GlobalKey(),
  );

  /// Si la sección elegida (a mano o desde otro widget) queda fuera de la barra, la desplaza hasta verla.
  @override
  void didUpdateWidget(_Pildoras old) {
    super.didUpdateWidget(old);
    if (old.indice != widget.indice) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || widget.indice >= _claves.length) return;
        final c = _claves[widget.indice].currentContext;
        if (c != null) {
          Scrollable.ensureVisible(
            c,
            duration: const Duration(milliseconds: 250),
            alignment: .5,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final secciones = widget.secciones;
    final indice = widget.indice;
    final onSelect = widget.onSelect;
    final cs = Theme.of(context).colorScheme;
    final oscuro = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: oscuro ? cs.surfaceContainerHigh : Colors.white,
              borderRadius: BorderRadius.circular(999),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                for (var i = 0; i < secciones.length; i++)
                  GestureDetector(
                    key: _claves[i],
                    onTap: () => onSelect(i),
                    behavior: HitTestBehavior.opaque,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: i == indice ? cs.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            secciones[i].icono,
                            size: 18,
                            color: i == indice
                                ? cs.onPrimary
                                : cs.onSurfaceVariant,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            secciones[i].etiqueta,
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(
                                  color: i == indice
                                      ? cs.onPrimary
                                      : cs.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
