import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ligaria_ui/ligaria_ui.dart';
import '../../../core/idioma.dart';
import '../ajustes/ajustes_repositorio.dart' show provinciasEspana;
import '../ligas/ligas_repositorio.dart';
import 'acciones_jugador.dart';
import 'social_repositorio.dart';

/// Buscar otros jugadores por nombre, provincia o localidad.
class JugadoresTab extends StatefulWidget {
  const JugadoresTab({super.key, required this.acciones});
  final AccionesJugador acciones;

  @override
  State<JugadoresTab> createState() => _JugadoresTabState();
}

class _JugadoresTabState extends State<JugadoresTab> {
  final _nombre = TextEditingController();
  final _localidad = TextEditingController();
  String _provincia = '';
  Future<List<JugadorBuscado>>? _resultado;
  Timer? _espera;

  @override
  void initState() {
    super.initState();
    _resultado = SocialRepositorio.instancia.buscar(); // al entrar ya se ven los visibles
  }

  /// Busca al dejar de escribir un momento, sin pulsar nada.
  void _buscarPronto() {
    _espera?.cancel();
    _espera = Timer(const Duration(milliseconds: 450), _buscar);
  }

  @override
  void dispose() {
    _espera?.cancel();
    _nombre.dispose();
    _localidad.dispose();
    super.dispose();
  }

  void _buscar() => setState(
    () => _resultado = SocialRepositorio.instancia.buscar(
      texto: _nombre.text,
      provincia: _provincia,
      localidad: _localidad.text,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final marca = Marca.de(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, c) {
            final nombre = CampoTexto(
              controller: _nombre,
              onChanged: (_) => _buscarPronto(),
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _buscar(),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                labelText: l.buscarPorNombre,
              ),
            );
            final provincia = DropdownButtonFormField<String>(
              initialValue: _provincia,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: l.filtroProvincia,
                prefixIcon: const Icon(Icons.map_outlined),
              ),
              items: [
                DropdownMenuItem(
                  value: '',
                  child: Text(l.filtroTodasProvincias),
                ),
                for (final p in provinciasEspana)
                  DropdownMenuItem(value: p, child: Text(p)),
              ],
              onChanged: (v) {
                _provincia = v ?? '';
                _buscar();
              },
            );
            final localidad = CampoTexto(
              controller: _localidad,
              onChanged: (_) => _buscarPronto(),
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _buscar(),
              decoration: InputDecoration(
                labelText: l.filtroLocalidad,
                prefixIcon: const Icon(Icons.location_city_outlined),
              ),
            );
            if (c.maxWidth >= 720) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: nombre),
                  const SizedBox(width: 12),
                  Expanded(flex: 2, child: provincia),
                  const SizedBox(width: 12),
                  Expanded(flex: 2, child: localidad),
                ],
              );
            }
            return Column(
              children: [
                nombre,
                const SizedBox(height: 12),
                provincia,
                const SizedBox(height: 12),
                localidad,
              ],
            );
          },
        ),
        const SizedBox(height: 14),
        FilledButton.icon(
          onPressed: _buscar,
          icon: const Icon(Icons.search),
          label: Text(l.btnBuscar),
        ),
        const SizedBox(height: 20),
        if (_resultado == null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                l.buscaJugadoresHint,
                textAlign: TextAlign.center,
                style: t.bodyLarge?.copyWith(color: cs.onSurfaceVariant),
              ),
            ),
          )
        else
          FutureBuilder<List<JugadorBuscado>>(
            future: _resultado,
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: Cargando()),
                );
              }
              if (snap.hasError) {
                final e = snap.error;
                return EstadoVacio(
                  icono: Icons.error_outline,
                  texto: e is LigasException ? e.mensaje : '$e',
                );
              }
              final lista = snap.data!;
              if (lista.isEmpty) {
                return EstadoVacio(
                  icono: Icons.person_search_outlined,
                  texto: l.sinJugadoresZona,
                );
              }
              return Column(
                children: [
                  for (final j in lista)
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: marca.superficie,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: marca.borde),
                      ),
                      child: ListTile(
                        onTap: () => widget.acciones.mostrar(
                          context,
                          id: j.id,
                          nombre: j.nombre,
                          esAmigo: j.esAmigo,
                        ),
                        leading: AvatarEquipo(j.nombre, tam: 42),
                        title: Text(
                          j.nombre,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        subtitle: j.zona.isEmpty ? null : Text(j.zona),
                        trailing: const Icon(Icons.more_horiz),
                      ),
                    ),
                ],
              );
            },
          ),
      ],
    );
  }
}
