import '../../core/idioma.dart';
import 'package:flutter/material.dart';
import 'package:ligaria_ui/ligaria_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ligaria_notificaciones/ligaria_notificaciones.dart';
import '../../core/auth.dart';
import '../../core/notificaciones.dart';
import '../../core/widgets.dart';
import '../alumno/alumno_home.dart';
import '../entrenador/entrenador_home.dart';
import '../escuela/escuela_home.dart';
import '../organizador/organizador_home.dart';
import '../superadmin/superadmin_home.dart';

/// Un «área» de trabajo según los roles del usuario.
class AreaApp {
  const AreaApp({
    required this.id,
    required this.titulo,
    this.subtitulo,
    required this.icono,
    required this.builder,
  });
  final String id, titulo;
  final String? subtitulo;
  final IconData icono;
  final Widget Function() builder;
}

/// Deriva las áreas de las pertenencias. Una persona con varios roles ve varias áreas.
List<AreaApp> areasDe(List<Pertenencia> perts) {
  final areas = <AreaApp>[];
  if (perts.any((p) => p.rol == Rol.alumno || p.rol == Rol.tutor)) {
    areas.add(
      AreaApp(
        id: 'familia',
        titulo: l10nActual.homeMiLiga,
        icono: Icons.sports_tennis,
        builder: () => const AlumnoHome(),
      ),
    );
  }
  if (perts.any((p) => p.rol == Rol.entrenador)) {
    areas.add(
      AreaApp(
        id: 'entrenador',
        titulo: l10nActual.homeEntrenador,
        icono: Icons.groups_outlined,
        builder: () => const EntrenadorHome(),
      ),
    );
  }
  for (final p in perts.where(
    (p) => p.rol == Rol.adminEscuela && p.escuelaId != null,
  )) {
    areas.add(
      AreaApp(
        id: 'escuela-${p.escuelaId}',
        titulo: l10nActual.homeEscuela,
        subtitulo: p.escuela,
        icono: Icons.school_outlined,
        builder: () => EscuelaHome(
          escuelaId: p.escuelaId!,
          escuelaNombre: p.escuela ?? '',
          orgTipo: p.orgTipo,
        ),
      ),
    );
  }
  for (final p in perts.where(
    (p) => p.rol == Rol.organizadorLiga && p.escuelaId != null,
  )) {
    areas.add(
      AreaApp(
        id: p.coorganizador ? 'coorg-${p.escuelaId}' : 'org-${p.escuelaId}',
        titulo: p.coorganizador
            ? l10nActual.homeCoorganizo
            : (p.esAyuntamiento
                  ? l10nActual.homeAyuntamiento
                  : l10nActual.homeOrganizacion),
        subtitulo: p.escuela,
        icono: p.esAyuntamiento
            ? Icons.account_balance_outlined
            : Icons.emoji_events_outlined,
        builder: () => OrganizadorHome(
          escuelaId: p.escuelaId!,
          escuelaNombre: p.escuela ?? '',
          orgTipo: p.orgTipo,
          coorganizador: p.coorganizador,
        ),
      ),
    );
  }
  if (perts.any((p) => p.rol == Rol.superadmin)) {
    areas.add(
      AreaApp(
        id: 'plataforma',
        titulo: l10nActual.homePlataforma,
        icono: Icons.admin_panel_settings_outlined,
        builder: () => const SuperadminHome(),
      ),
    );
  }
  return areas;
}

/// Pantalla de inicio: muestra el área activa; con varias áreas, un menú lateral para cambiar.
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});
  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  String? _areaId;

  @override
  Widget build(BuildContext context) {
    final perts = ref.watch(pertenenciasProvider);
    return perts.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        appBar: _barra(context, 'Ligaria'),
        body: AsyncView<void>(
          value: AsyncValue.error(e, StackTrace.empty),
          builder: (_) => const SizedBox(),
          onRetry: () => ref.invalidate(pertenenciasProvider),
        ),
      ),
      data: (lista) {
        final areas = areasDe(lista);
        if (areas.isEmpty) {
          return Scaffold(
            appBar: _barra(context, 'Ligaria'),
            body: EstadoVacio(
              icono: Icons.school_outlined,
              texto: context.l10n.homeSinOrg,
            ),
          );
        }
        final actual = areas.firstWhere(
          (a) => a.id == _areaId,
          orElse: () => areas.first,
        );
        final ancha = Pantalla.esAncha(context);
        final titulo = actual.subtitulo == null
            ? actual.titulo
            : '${actual.titulo} · ${actual.subtitulo}';
        void elegir(AreaApp a) => setState(() => _areaId = a.id);
        final cuerpo = FondoBlobs(
          child: KeyedSubtree(
            key: ValueKey(actual.id),
            child: Aparece(
              desplazamiento: 10,
              child: ContenidoCentrado(child: actual.builder()),
            ),
          ),
        );

        // Pantalla ancha (tablet / escritorio / web): barra lateral permanente.
        if (ancha && areas.length > 1) {
          final tema = Theme.of(context);
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  extended: MediaQuery.sizeOf(context).width >= 1200,
                  minExtendedWidth: 230,
                  selectedIndex: areas.indexOf(actual),
                  onDestinationSelected: (i) => elegir(areas[i]),
                  leading: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const LogoLigaria(tam: 40),
                        if (MediaQuery.sizeOf(context).width >= 1200) ...[
                          const SizedBox(width: 10),
                          Text('Ligaria', style: tema.textTheme.titleLarge),
                        ],
                      ],
                    ),
                  ),
                  trailing: Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _campana(),
                            IconButton(
                              tooltip: context.l10n.tutorial,
                              icon: const Icon(Icons.help_outline),
                              onPressed: () => context.push('/tutorial'),
                            ),
                            IconButton(
                              tooltip: context.l10n.miCuenta,
                              icon: const Icon(Icons.account_circle_outlined),
                              onPressed: () => context.push('/cuenta'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  destinations: [
                    for (final a in areas)
                      NavigationRailDestination(
                        icon: Icon(a.icono),
                        label: Text(
                          a.subtitulo == null
                              ? a.titulo
                              : '${a.titulo}\n${a.subtitulo}',
                          textAlign: TextAlign.center,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 4),
                      ),
                  ],
                ),
                Expanded(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            titulo,
                            style: tema.textTheme.headlineMedium,
                          ),
                        ),
                      ),
                      Expanded(child: cuerpo),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          appBar: _barra(context, titulo, mostrarLogo: true),
          drawer: areas.length > 1
              ? Drawer(
                  child: SafeArea(
                    child: ListView(
                      padding: const EdgeInsets.all(12),
                      children: [
                        const Padding(
                          padding: EdgeInsets.fromLTRB(8, 12, 8, 20),
                          child: Row(
                            children: [
                              LogoLigaria(tam: 44),
                              SizedBox(width: 12),
                              Text(
                                'Ligaria',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        for (final a in areas)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: ListTile(
                              leading: Icon(a.icono),
                              title: Text(a.titulo),
                              subtitle: a.subtitulo == null
                                  ? null
                                  : Text(a.subtitulo!),
                              selected: a.id == actual.id,
                              selectedTileColor: Theme.of(
                                context,
                              ).colorScheme.primaryContainer,
                              onTap: () {
                                elegir(a);
                                Navigator.of(context).pop();
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                )
              : null,
          body: cuerpo,
        );
      },
    );
  }

  /// Campana de notificaciones; no aparece sin sesión de Supabase (demo y tests).
  Widget _campana() {
    final servicio = ref.watch(notificacionesProvider).value;
    if (servicio == null) return const SizedBox.shrink();
    return CampanaNotificaciones(servicio: servicio, tipos: tiposNotificacion);
  }

  AppBar _barra(
    BuildContext context,
    String titulo, {
    bool mostrarLogo = false,
  }) {
    final cs = Theme.of(context).colorScheme;
    return AppBar(
      backgroundColor: Colors.transparent,
      scrolledUnderElevation: 0,
      titleSpacing: mostrarLogo ? 4 : null,
      title: Row(
        children: [
          const LogoLigaria(tam: 34),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              titulo,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: cs.onSurface,
                fontWeight: FontWeight.w800,
                fontSize: 19,
              ),
            ),
          ),
        ],
      ),
      actions: [
        _campana(),
        IconButton(
          tooltip: context.l10n.tutorial,
          icon: const Icon(Icons.help_outline),
          onPressed: () => context.push('/tutorial'),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: InkWell(
            onTap: () => context.push('/cuenta'),
            customBorder: const CircleBorder(),
            child: Tooltip(
              message: context.l10n.miCuenta,
              child: CircleAvatar(
                radius: 18,
                backgroundColor: cs.primaryContainer,
                child: Icon(Icons.person_rounded, color: cs.primary),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
