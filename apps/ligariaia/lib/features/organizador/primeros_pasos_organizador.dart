import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/idioma.dart';
import '../../data/models.dart';
import '../escuela/primeros_pasos.dart';
import 'crear_liga_page.dart';
import 'liga_detalle_page.dart';
import 'organizador_providers.dart';

/// Una liga que ya salió del borrador y admite (o admitió) equipos.
bool _publicada(Liga l) => l.estado == 'publicada' || l.enCurso || l.finalizada;

/// Guía de arranque para quien organiza ligas (ayuntamiento, grupo o escuela como organizadora):
/// crear la liga, abrir la inscripción, reunir equipos y generar el calendario. Se deduce sola de
/// las ligas de la organización y cada paso abre la pantalla donde se completa.
class PrimerosPasosOrganizador extends ConsumerWidget {
  const PrimerosPasosOrganizador({
    super.key,
    required this.escuelaId,
    this.orgTipo,
  });
  final String escuelaId;
  final String? orgTipo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ligas = ref.watch(orgLigasProvider(escuelaId)).value;
    if (ligas == null) return const SizedBox.shrink();
    final publicadas = ligas.where(_publicada).toList();
    // Con la liga en marcha ya hay equipos; si no, se mira si alguno está aceptado.
    final conEquipos = publicadas.any(
      (l) =>
          l.enCurso ||
          l.finalizada ||
          (ref
                  .watch(orgInscripcionesProvider(l.id))
                  .value
                  ?.any((i) => i.estado == 'aceptada') ??
              false),
    );
    final conCalendario = ligas.any((l) => l.enCurso || l.finalizada);
    final l10n = context.l10n;

    void crear() => Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CrearLigaPage(escuelaId: escuelaId, orgTipo: orgTipo),
      ),
    );

    /// Abre la liga donde se completa el paso; sin ligas todavía, lo primero es crearla.
    void abrir(Liga? liga) {
      if (liga == null) return crear();
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => LigaDetallePage(liga: liga, escuelaId: escuelaId),
        ),
      );
    }

    return TarjetaPasos(
      preferencia: 'primeros_pasos_org_oculto_$escuelaId',
      pasos: [
        PasoGuia(
          clave: 'crear',
          hecho: ligas.isNotEmpty,
          titulo: l10n.pasosOrg1T,
          detalle: l10n.pasosOrg1D,
          alTocar: crear,
        ),
        PasoGuia(
          clave: 'publicar',
          hecho: publicadas.isNotEmpty,
          titulo: l10n.pasosOrg2T,
          detalle: l10n.pasosOrg2D,
          alTocar: () => abrir(
            ligas.where((l) => l.estado == 'borrador').firstOrNull ??
                ligas.firstOrNull,
          ),
        ),
        PasoGuia(
          clave: 'equipos',
          hecho: conEquipos,
          titulo: l10n.pasosOrg3T,
          detalle: l10n.pasosOrg3D,
          alTocar: () => abrir(publicadas.firstOrNull ?? ligas.firstOrNull),
        ),
        PasoGuia(
          clave: 'calendario',
          hecho: conCalendario,
          titulo: l10n.pasosOrg4T,
          detalle: l10n.pasosOrg4D,
          alTocar: () => abrir(
            publicadas.where((l) => !l.enCurso).firstOrNull ??
                publicadas.firstOrNull ??
                ligas.firstOrNull,
          ),
        ),
      ],
    );
  }
}
