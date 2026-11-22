import 'package:flutter/material.dart';
import 'package:ligaria_ui/ligaria_ui.dart';
import 'pedidos_page.dart';
import 'store_repositorio.dart';
import '../../../core/idioma.dart';

/// Detalle de un producto: imagen grande, descripción, precio y botón para solicitarlo.
class ProductoPage extends StatelessWidget {
  const ProductoPage({super.key, required this.producto, required this.repo});
  final Producto producto;
  final StoreRepositorio repo;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final vacia = Container(
      color: cs.primary.withValues(alpha: .08),
      alignment: Alignment.center,
      child: Icon(Icons.shopping_bag_outlined, size: 72, color: cs.primary),
    );
    return Scaffold(
      appBar: AppBar(title: Text(producto.nombre)),
      body: FondoBlobs(
        child: SafeArea(
          child: ContenidoCentrado(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: AspectRatio(
                    aspectRatio: 1.2,
                    child: producto.imagenUrl == null
                        ? vacia
                        : Image.network(
                            producto.imagenUrl!,
                            fit: BoxFit.cover,
                            loadingBuilder: (_, hijo, p) =>
                                p == null ? hijo : vacia,
                            errorBuilder: (_, _, _) => vacia,
                          ),
                  ),
                ),
                const SizedBox(height: 20),
                if (producto.categoria != null) ...[
                  Insignia(producto.categoria!, icono: Icons.sell_outlined),
                  const SizedBox(height: 10),
                ],
                Text(
                  producto.nombre,
                  style: t.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                Text(
                  euros(producto.precio),
                  style: t.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: cs.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  producto.descripcion?.trim().isNotEmpty == true
                      ? producto.descripcion!
                      : context.l10n.sinDescripcion,
                  style: t.bodyLarge?.copyWith(color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 28),
                FilledButton.icon(
                  onPressed: () => solicitarProducto(context, repo, producto),
                  icon: const Icon(Icons.shopping_cart_outlined),
                  label: Text(context.l10n.solicitar),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
