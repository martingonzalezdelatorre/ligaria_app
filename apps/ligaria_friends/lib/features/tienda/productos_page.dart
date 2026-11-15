import 'package:flutter/material.dart';
import 'package:ligaria_ui/ligaria_ui.dart';
import 'tienda_repositorio.dart';

/// Catálogo de la tienda: alta, edición y baja de productos.
class ProductosPage extends StatefulWidget {
  const ProductosPage({super.key, required this.repo});
  final TiendaRepositorio repo;
  @override
  State<ProductosPage> createState() => _ProductosPageState();
}

class _ProductosPageState extends State<ProductosPage> {
  late Future<List<Producto>> _productos = widget.repo.productos();

  void _recargar() => setState(() => _productos = widget.repo.productos());

  Future<void> _ejecutar(Future<void> Function() accion) async {
    try {
      await accion();
    } on StoreException catch (e) {
      if (mounted) avisar(context, e.mensaje);
    }
    if (mounted) _recargar();
  }

  Future<void> _editar([Producto? p]) async {
    final nombre = TextEditingController(text: p?.nombre);
    final precio = TextEditingController(
      text: p == null ? '' : p.precio.toStringAsFixed(2).replaceAll('.', ','),
    );
    final categoria = TextEditingController(text: p?.categoria);
    final descripcion = TextEditingController(text: p?.descripcion);
    final imagen = TextEditingController(text: p?.imagenUrl);
    final form = GlobalKey<FormState>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(p == null ? 'Nuevo producto' : 'Editar producto'),
        content: SingleChildScrollView(
          child: Form(
            key: form,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nombre,
                  autofocus: true,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Introduce el nombre'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: precio,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(labelText: 'Precio (€)'),
                  validator: (v) =>
                      _parsear(v) == null ? 'Precio no válido' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: categoria,
                  decoration: const InputDecoration(
                    labelText: 'Categoría (opcional)',
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: descripcion,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Descripción (opcional)',
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: imagen,
                  keyboardType: TextInputType.url,
                  decoration: const InputDecoration(
                    labelText: 'URL de la imagen (opcional)',
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              if (form.currentState!.validate()) Navigator.pop(c, true);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await _ejecutar(
      () => widget.repo.guardarProducto(
        id: p?.id,
        nombre: nombre.text,
        precio: _parsear(precio.text)!,
        categoria: categoria.text,
        descripcion: descripcion.text,
        imagenUrl: imagen.text,
      ),
    );
  }

  double? _parsear(String? v) {
    final n = double.tryParse((v ?? '').trim().replaceAll(',', '.'));
    return (n == null || n < 0) ? null : n;
  }

  Future<void> _eliminar(Producto p) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Eliminar producto'),
        content: Text('¿Eliminar "${p.nombre}" del catálogo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (ok == true) await _ejecutar(() => widget.repo.eliminarProducto(p.id));
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final marca = Marca.de(context);
    return FutureBuilder<List<Producto>>(
      future: _productos,
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
        return ListView(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 40),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Mis productos',
                    style: t.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: -.5,
                    ),
                  ),
                ),
                FilledButton.icon(
                  onPressed: _editar,
                  icon: const Icon(Icons.add),
                  label: const Text('Añadir'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (lista.isEmpty)
              const EstadoVacio(
                icono: Icons.inventory_2_outlined,
                texto: 'Aún no tienes productos. Añade el primero.',
              ),
            for (final p in lista)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: marca.superficie,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: marca.borde),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox.square(
                          dimension: 56,
                          child: p.imagenUrl == null
                              ? ColoredBox(
                                  color: cs.primary.withValues(alpha: .08),
                                  child: Icon(
                                    Icons.shopping_bag_outlined,
                                    color: cs.primary,
                                  ),
                                )
                              : Image.network(
                                  p.imagenUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => ColoredBox(
                                    color: cs.primary.withValues(alpha: .08),
                                    child: Icon(
                                      Icons.broken_image_outlined,
                                      color: cs.primary,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.nombre,
                              style: t.titleSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              [
                                if (p.categoria != null) p.categoria!,
                                euros(p.precio),
                              ].join(' · '),
                              style: t.bodySmall?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Editar',
                        onPressed: () => _editar(p),
                        icon: const Icon(Icons.edit_outlined),
                      ),
                      IconButton(
                        tooltip: 'Eliminar',
                        onPressed: () => _eliminar(p),
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
