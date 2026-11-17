import 'package:flutter/material.dart';
import 'package:ligaria_notificaciones/ligaria_notificaciones.dart';
import 'package:ligaria_ui/ligaria_ui.dart';
import '../../core/notificaciones.dart';
import 'amistosos/amistosos_repositorio.dart';
import 'grupos/grupos_page.dart';
import 'grupos/grupos_repositorio.dart';
import 'ligas/ligas_repositorio.dart';
import 'ranking/ranking_page.dart';
import 'store/store_page.dart';

/// Pantalla principal del perfil Jugador: grupos, ligas y partidos, y Store.
class JugadorShell extends StatefulWidget {
  const JugadorShell({
    super.key,
    required this.grupos,
    required this.ligas,
    required this.amistosos,
    this.onSalir,
    this.notificaciones,
  });
  final GruposRepositorio grupos;
  final LigasRepositorio ligas;
  final AmistososRepositorio amistosos;
  final VoidCallback? onSalir;

  /// Sin servicio (modo demo) no se muestra la campana.
  final NotificacionesServicio? notificaciones;

  @override
  State<JugadorShell> createState() => _JugadorShellState();
}

class _JugadorShellState extends State<JugadorShell> {
  int _seccion = 0;

  static const _destinos = [
    (icono: Icons.groups_outlined, activo: Icons.groups, texto: 'Grupos'),
    (
      icono: Icons.storefront_outlined,
      activo: Icons.storefront,
      texto: 'Store',
    ),
    (
      icono: Icons.emoji_events_outlined,
      activo: Icons.emoji_events,
      texto: 'Ranking',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final ancha = MediaQuery.sizeOf(context).width >= 720;
    final contenido = IndexedStack(
      index: _seccion,
      children: [
        GruposPage(
          repo: widget.grupos,
          ligas: widget.ligas,
          amistosos: widget.amistosos,
        ),
        const StorePage(),
        const RankingPage(),
      ],
    );
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Row(
          children: [
            LogoLigaria(tam: 34, icono: Icons.groups),
            SizedBox(width: 12),
            Text('Ligaria Friends'),
          ],
        ),
        actions: [
          if (widget.notificaciones != null)
            CampanaNotificaciones(
              servicio: widget.notificaciones!,
              tipos: tiposNotificacion,
            ),
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
              Expanded(child: ContenidoCentrado(child: contenido)),
            ],
          ),
        ),
      ),
    );
  }
}
