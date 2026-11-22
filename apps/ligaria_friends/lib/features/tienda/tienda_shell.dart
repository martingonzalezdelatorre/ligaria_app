import 'package:flutter/material.dart';
import 'package:ligaria_notificaciones/ligaria_notificaciones.dart';
import 'package:ligaria_ui/ligaria_ui.dart';
import '../../core/notificaciones.dart';
import 'pedidos_recibidos_page.dart';
import 'productos_page.dart';
import 'tienda_repositorio.dart';
import '../../core/idioma.dart';

/// Pantalla principal del perfil Tienda: gestionar productos y ver los pedidos recibidos.
class TiendaShell extends StatefulWidget {
  const TiendaShell({
    super.key,
    required this.repo,
    this.onSalir,
    this.notificaciones,
  });
  final TiendaRepositorio repo;
  final VoidCallback? onSalir;

  /// Sin servicio (modo demo) no se muestra la campana.
  final NotificacionesServicio? notificaciones;
  @override
  State<TiendaShell> createState() => _TiendaShellState();
}

class _TiendaShellState extends State<TiendaShell> {
  int _seccion = 0;

  List<({IconData icono, IconData activo, String texto})> _destinos(
    AppL10n l,
  ) => [
    (
      icono: Icons.inventory_2_outlined,
      activo: Icons.inventory_2,
      texto: l.productos,
    ),
    (icono: Icons.inbox_outlined, activo: Icons.inbox, texto: l.pedidos),
  ];

  @override
  Widget build(BuildContext context) {
    final ancha = MediaQuery.sizeOf(context).width >= 720;
    final destinos = _destinos(context.l10n);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Row(
          children: [
            const LogoLigaria(tam: 34, icono: Icons.storefront),
            const SizedBox(width: 12),
            FutureBuilder<Comercio>(
              future: widget.repo.miTienda(),
              builder: (_, snap) =>
                  Text(snap.data?.nombre ?? context.l10n.miTienda),
            ),
          ],
        ),
        actions: [
          if (widget.notificaciones != null)
            CampanaNotificaciones(
              servicio: widget.notificaciones!,
              tipos: tiposNotificacion,
            ),
          const SelectorIdioma(),
          if (widget.onSalir != null)
            IconButton(
              tooltip: context.l10n.cerrarSesion,
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
                for (final d in destinos)
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
                    for (final d in destinos)
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
