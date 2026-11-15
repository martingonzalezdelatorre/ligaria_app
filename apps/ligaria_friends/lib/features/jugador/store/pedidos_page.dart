import 'package:flutter/material.dart';
import 'package:ligaria_ui/ligaria_ui.dart';
import 'store_repositorio.dart';

String _fecha(DateTime d) =>
    '${d.day}/${d.month.toString().padLeft(2, '0')}/${d.year} '
    '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

/// Diálogo para solicitar un producto a su tienda (cantidad y nota opcional).
Future<void> solicitarProducto(
  BuildContext context,
  StoreRepositorio repo,
  Producto producto,
) async {
  final nota = TextEditingController();
  var cantidad = 1;
  final ok = await showDialog<bool>(
    context: context,
    builder: (c) => StatefulBuilder(
      builder: (c, setState) => AlertDialog(
        title: const Text('Solicitar producto'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              producto.nombre,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Cantidad'),
                const Spacer(),
                IconButton(
                  onPressed: cantidad > 1
                      ? () => setState(() => cantidad--)
                      : null,
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Text('$cantidad'),
                IconButton(
                  onPressed: cantidad < 99
                      ? () => setState(() => cantidad++)
                      : null,
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
            TextField(
              controller: nota,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Nota para la tienda (opcional)',
              ),
            ),
            const SizedBox(height: 12),
            Text('Total: ${euros(producto.precio * cantidad)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Enviar solicitud'),
          ),
        ],
      ),
    ),
  );
  if (ok != true) return;
  try {
    await repo.solicitar(producto.id, cantidad, nota: nota.text);
    if (context.mounted) {
      avisar(context, 'Solicitud enviada a la tienda');
    }
  } on StoreException catch (e) {
    if (context.mounted) avisar(context, e.mensaje);
  }
}

/// Pedidos que el jugador ha solicitado a las tiendas (los recibe la tienda en su propio perfil).
class MisPedidosPage extends StatefulWidget {
  const MisPedidosPage({super.key, required this.repo});
  final StoreRepositorio repo;
  @override
  State<MisPedidosPage> createState() => _MisPedidosPageState();
}

class _MisPedidosPageState extends State<MisPedidosPage> {
  late Future<List<Pedido>> _pedidos = widget.repo.misPedidos();

  Future<void> _cancelar(Pedido p) async {
    try {
      await widget.repo.cancelarPedido(p.id);
    } on StoreException catch (e) {
      if (mounted) avisar(context, e.mensaje);
    }
    if (mounted) setState(() => _pedidos = widget.repo.misPedidos());
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Mis pedidos')),
    body: FondoBlobs(
      child: SafeArea(
        child: ContenidoCentrado(
          child: FutureBuilder<List<Pedido>>(
            future: _pedidos,
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snap.hasError) {
                return EstadoVacio(
                  icono: Icons.error_outline,
                  texto: '${snap.error}',
                );
              }
              final lista = snap.data!;
              if (lista.isEmpty) {
                return const EstadoVacio(
                  icono: Icons.inbox_outlined,
                  texto: 'Aún no has solicitado productos.',
                );
              }
              return RefreshIndicator(
                onRefresh: () async {
                  setState(() => _pedidos = widget.repo.misPedidos());
                  await _pedidos;
                },
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
                  itemCount: lista.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => _TarjetaPedido(
                    pedido: lista[i],
                    onCancelar: () => _cancelar(lista[i]),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    ),
  );
}

class _TarjetaPedido extends StatelessWidget {
  const _TarjetaPedido({required this.pedido, required this.onCancelar});
  final Pedido pedido;
  final VoidCallback onCancelar;

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
            p.comercio,
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
          if (p.estado == EstadoPedido.pendiente) ...[
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: onCancelar,
              child: const Text('Cancelar pedido'),
            ),
          ],
        ],
      ),
    );
  }
}
