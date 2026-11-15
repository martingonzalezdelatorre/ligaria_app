import 'package:flutter/material.dart';
import 'package:ligaria_ui/ligaria_ui.dart';
import 'pedidos_recibidos_page.dart';
import 'productos_page.dart';
import 'tienda_repositorio.dart';

/// Pantalla principal del perfil Tienda: gestionar productos y ver los pedidos recibidos.
class TiendaShell extends StatefulWidget {
  const TiendaShell({super.key, required this.repo, this.onSalir});
  final TiendaRepositorio repo;
  final VoidCallback? onSalir;
  @override
  State<TiendaShell> createState() => _TiendaShellState();
}

class _TiendaShellState extends State<TiendaShell> {
  int _seccion = 0;

  static const _destinos = [
    (
      icono: Icons.inventory_2_outlined,
      activo: Icons.inventory_2,
      texto: 'Productos',
    ),
    (icono: Icons.inbox_outlined, activo: Icons.inbox, texto: 'Pedidos'),
  ];

  @override
  Widget build(BuildContext context) {
    final ancha = MediaQuery.sizeOf(context).width >= 720;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Row(
          children: [
            const LogoLigaria(tam: 34, icono: Icons.storefront),
            const SizedBox(width: 12),
            FutureBuilder<Comercio>(
              future: widget.repo.miTienda(),
              builder: (_, snap) => Text(snap.data?.nombre ?? 'Mi tienda'),
            ),
          ],
        ),
        actions: [
          if (widget.onSalir != null)
            IconButton(
              tooltip: 'Cerrar sesión',
              onPressed: widget.onSalir,
              icon: const Icon(Icons.logout_rounded),
            ),
        ],
      ),
      bottomNavigationBar: ancha
          ? null
          : NavigationBar(
              selectedIndex: _seccion,
              onDestinationSelected: (i) => setState(() => _seccion = i),
              destinations: [
                for (final d in _destinos)
                  NavigationDestination(
                    icon: Icon(d.icono),
                    selectedIcon: Icon(d.activo),
                    label: d.texto,
                  ),
              ],
            ),
      body: FondoBlobs(
        child: SafeArea(
          child: Row(
            children: [
              if (ancha)
                NavigationRail(
                  backgroundColor: Colors.transparent,
                  selectedIndex: _seccion,
                  onDestinationSelected: (i) => setState(() => _seccion = i),
                  labelType: NavigationRailLabelType.all,
                  destinations: [
                    for (final d in _destinos)
                      NavigationRailDestination(
                        icon: Icon(d.icono),
                        selectedIcon: Icon(d.activo),
                        label: Text(d.texto),
                      ),
                  ],
                ),
              Expanded(
                child: ContenidoCentrado(
                  child: IndexedStack(
                    index: _seccion,
                    children: [
                      ProductosPage(repo: widget.repo),
                      PedidosRecibidosPage(repo: widget.repo),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
