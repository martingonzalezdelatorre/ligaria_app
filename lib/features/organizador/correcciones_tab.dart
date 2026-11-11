import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/widgets.dart';
import '../../data/models.dart';
import 'organizador_providers.dart';
import 'resultado_page.dart';

/// Elige una liga y abre cualquiera de sus encuentros con resultado para corregirlo.
class CorreccionesTab extends ConsumerStatefulWidget {
  const CorreccionesTab({super.key, required this.escuelaId});
  final String escuelaId;
  @override
  ConsumerState<CorreccionesTab> createState() => _CorreccionesTabState();
}

class _CorreccionesTabState extends ConsumerState<CorreccionesTab> {
  String? _ligaId;

  @override
  Widget build(BuildContext context) {
    return AsyncView<List<Liga>>(
      value: ref.watch(orgLigasProvider(widget.escuelaId)),
      onRetry: () => ref.invalidate(orgLigasProvider(widget.escuelaId)),
      builder: (ligas) {
        if (ligas.isEmpty) {
          return const EstadoVacio(icono: Icons.emoji_events_outlined, texto: 'Aún no has creado ninguna liga.');
        }
        final id = ligas.any((l) => l.id == _ligaId) ? _ligaId! : ligas.first.id;
        return Column(children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: DropdownButtonFormField<String>(
              key: ValueKey(id),
              initialValue: id,
              decoration: const InputDecoration(labelText: 'Liga', border: OutlineInputBorder()),
              items: [for (final l in ligas) DropdownMenuItem(value: l.id, child: Text(l.nombre))],
              onChanged: (v) => setState(() => _ligaId = v),
            ),
          ),
          Expanded(
            child: AsyncView<List<EncuentroVista>>(
              value: ref.watch(orgEncuentrosProvider(id)),
              onRetry: () => ref.invalidate(orgEncuentrosProvider(id)),
              builder: (encs) {
                final con = encs.where((e) => e.estado != 'programado').toList();
                if (con.isEmpty) {
                  return const EstadoVacio(icono: Icons.edit_off_outlined, texto: 'Todavía no hay resultados que corregir en esta liga.');
                }
                return ListView(
                  padding: const EdgeInsets.only(bottom: 24),
                  children: [
                    for (final e in con)
                      TarjetaEncuentro(
                        encuentro: e,
                        onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => ResultadoPage(escuelaId: widget.escuelaId, encuentro: e))),
                      ),
                  ],
                );
              },
            ),
          ),
        ]);
      },
    );
  }
}
