import 'package:flutter/material.dart';
import 'package:ligaria_ui/ligaria_ui.dart';
import 'tienda_repositorio.dart';
import '../../core/idioma.dart';

String _fecha(DateTime d) =>
    '${d.day}/${d.month.toString().padLeft(2, '0')}/${d.year} '
    '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

/// Bandeja de la tienda: pedidos que le han hecho los jugadores.
class PedidosRecibidosPage extends StatefulWidget {
  const PedidosRecibidosPage({super.key, required this.repo});
  final TiendaRepositorio repo;
  @override
  State<PedidosRecibidosPage> createState() => _PedidosRecibidosPageState();
}

class _PedidosRecibidosPageState extends State<PedidosRecibidosPage> {
  late Future<List<Pedido>> _pedidos = widget.repo.pedidosRecibidos();

  void _recargar() => setState(() => _pedidos = widget.repo.pedidosRecibidos());

  Future<void> _cambiar(Pedido p, EstadoPedido estado) async {
    try {
      await widget.repo.cambiarEstado(p.id, estado);
    } on StoreException catch (e) {
      if (mounted) avisar(context, e.mensaje);
    }
    if (mounted) _recargar();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<List<Pedido>>(
    future: _pedidos,
    builder: (context, snap) {
      if (snap.connectionState != ConnectionState.done) {
        return const Center(child: CircularProgressIndicator());
      }
      if (snap.hasError) {
        return EstadoVacio(icono: Icons.error_outline, texto: '${snap.error}');
      }
      final lista = snap.data!;
      if (lista.isEmpty) {
        return EstadoVacio(
          icono: Icons.inbox_outlined,
          texto: context.l10n.aunNoPedidosRecibidos,
        );
      }
      return RefreshIndicator(
        onRefresh: () async {
          _recargar();
          await _pedidos;
        },
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 40),
          itemCount: lista.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (_, i) => _TarjetaPedido(
            pedido: lista[i],
            onEstado: (e) => _cambiar(lista[i], e),
          ),
        ),
      );
    },
  );
}

class _TarjetaPedido extends StatelessWidget {
  const _TarjetaPedido({required this.pedido, required this.onEstado});
  final Pedido pedido;
  final void Function(EstadoPedido) onEstado;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final marca = Marca.de(context);
    final p = pedido;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: marca.superficie,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: marca.borde),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${p.cantidad} × ${p.producto}',
                  style: t.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              Insignia(
                p.estado.texto,
                color: p.estado == EstadoPedido.pendiente ? cs.primary : null,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${p.solicitante ?? context.l10n.jugador}'
            '${p.email == null ? '' : ' · ${p.email}'}',
            style: t.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
          Text(
            '${_fecha(p.creado)} · ${euros(p.total)}',
            style: t.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
          if (p.nota != null) ...[
            const SizedBox(height: 8),
            Text('“${p.nota}”', style: t.bodyMedium),
          ],
          if (!p.estado.cerrado) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                if (p.estado == EstadoPedido.pendiente) ...[
                  FilledButton(
                    onPressed: () => onEstado(EstadoPedido.confirmado),
                    child: Text(context.l10n.confirmar),
                  ),
                  OutlinedButton(
                    onPressed: () => onEstado(EstadoPedido.rechazado),
                    child: Text(context.l10n.rechazar),
                  ),
                ],
                if (p.estado == EstadoPedido.confirmado)
                  FilledButton(
                    onPressed: () => onEstado(EstadoPedido.entregado),
                    child: Text(context.l10n.marcarEntregado),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
