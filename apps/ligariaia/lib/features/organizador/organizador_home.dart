import 'package:flutter/material.dart';
import 'package:ligaria_ui/ligaria_ui.dart';
import 'equipo_tab.dart';
import 'ligas_tab.dart';
import 'primeros_pasos_organizador.dart';

/// Área organizador: crear ligas, abrir inscripción, generar calendario y registrar o corregir resultados.
/// Sirve para cualquier organización que pueda organizar competiciones (escuela, ayuntamiento, grupo).
/// Con la pestaña «Equipo» el organizador invita a otros organizadores de su organización.
/// Mientras no ha completado el arranque, arriba aparece la guía «Primeros pasos».
class OrganizadorHome extends StatelessWidget {
  const OrganizadorHome({
    super.key,
    required this.escuelaId,
    required this.escuelaNombre,
    this.orgTipo,
    this.coorganizador = false,
  });
  final String escuelaId;
  final String escuelaNombre;
  final String? orgTipo;

  /// Co-organizador: gestiona solo las ligas que le asignaron; no crea ligas ni invita a nadie.
  final bool coorganizador;

  @override
  Widget build(BuildContext context) {
    final ligas = LigasTab(
      escuelaId: escuelaId,
      orgTipo: orgTipo,
      coorganizador: coorganizador,
    );
    if (coorganizador) return ligas;
    return Column(
      children: [
        PrimerosPasosOrganizador(escuelaId: escuelaId, orgTipo: orgTipo),
        Expanded(
          child: DefaultTabController(
            length: 2,
            child: Column(
              children: [
                const PestanasPildora(
                  tabs: [
                    Tab(text: 'Ligas'),
                    Tab(text: 'Equipo'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      ligas,
                      EquipoTab(orgId: escuelaId),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
