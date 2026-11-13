import 'package:flutter/material.dart';
import 'ligas_tab.dart';

/// Área organizador: crear ligas, abrir inscripción, generar calendario y registrar o corregir resultados.
/// Sirve para cualquier organización que pueda organizar competiciones (escuela, ayuntamiento, grupo).
class OrganizadorHome extends StatelessWidget {
  const OrganizadorHome({super.key, required this.escuelaId, required this.escuelaNombre, this.orgTipo});
  final String escuelaId;
  final String escuelaNombre;
  final String? orgTipo;

  @override
  Widget build(BuildContext context) => LigasTab(escuelaId: escuelaId, orgTipo: orgTipo);
}
