import 'package:flutter/material.dart';
import 'theme.dart';

/// Una sección de un área (icono + etiqueta + contenido).
class SeccionArea {
  const SeccionArea(this.icono, this.etiqueta, this.contenido, {this.iconoActivo});
  final IconData icono;
  final IconData? iconoActivo;
  final String etiqueta;
  final Widget contenido;
}

/// Navegación de secciones adaptable: barra inferior flotante en móvil y píldoras arriba en pantallas anchas.
class AreaTabs extends StatefulWidget {
  const AreaTabs({super.key, required this.secciones});
  final List<SeccionArea> secciones;
  @override
  State<AreaTabs> createState() => _AreaTabsState();
}

class _AreaTabsState extends State<AreaTabs> {
  int _i = 0;

  @override
  Widget build(BuildContext context) {
    final s = widget.secciones;
    final ancha = MediaQuery.sizeOf(context).width >= Pantalla.compacta + 120;
    final cuerpo = AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      child: KeyedSubtree(key: ValueKey(_i), child: s[_i].contenido),
    );
    if (ancha) {
      return Column(children: [
        _Pildoras(secciones: s, indice: _i, onSelect: (i) => setState(() => _i = i)),
        Expanded(child: cuerpo),
      ]);
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
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .4), blurRadius: 24, offset: const Offset(0, 8))],
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
              onDestinationSelected: (i) => setState(() => _i = i),
              destinations: [
                for (final x in s)
                  NavigationDestination(
                      icon: Icon(x.icono), selectedIcon: Icon(x.iconoActivo ?? x.icono, color: cs.primary), label: x.etiqueta),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Pildoras extends StatelessWidget {
  const _Pildoras({required this.secciones, required this.indice, required this.onSelect});
  final List<SeccionArea> secciones;
  final int indice;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
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
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .3), blurRadius: 16, offset: const Offset(0, 6))],
            ),
            child: Row(children: [
              for (var i = 0; i < secciones.length; i++)
                GestureDetector(
                  onTap: () => onSelect(i),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      color: i == indice ? cs.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(secciones[i].icono, size: 18, color: i == indice ? cs.onPrimary : cs.onSurfaceVariant),
                      const SizedBox(width: 8),
                      Text(secciones[i].etiqueta,
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.copyWith(color: i == indice ? cs.onPrimary : cs.onSurfaceVariant)),
                    ]),
                  ),
                ),
            ]),
          ),
        ),
      ),
    );
  }
}
