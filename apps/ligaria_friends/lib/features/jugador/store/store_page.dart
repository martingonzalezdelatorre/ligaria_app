import 'package:flutter/material.dart';
import 'package:ligaria_ui/ligaria_ui.dart';
import 'pedidos_page.dart';
import 'producto_page.dart';
import 'reserva_page.dart';
import 'store_repositorio.dart';
import '../../../core/idioma.dart';

/// Sección Store: tiendas de material y clubs con pistas para alquilar.
class StorePage extends StatefulWidget {
  const StorePage({super.key, this.repo});
  final StoreRepositorio? repo;
  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  late final StoreRepositorio _repo = widget.repo ?? StoreRepositorio.instancia;
  late Future<List<Comercio>> _comercios = _repo.comercios();
  TipoComercio _tipo = TipoComercio.tienda;

  Future<void> _abrir(Comercio c) => Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => ComercioPage(comercio: c, repo: _repo),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return FutureBuilder<List<Comercio>>(
      future: _comercios,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: Cargando());
        }
        if (snap.hasError) {
          return EstadoVacio(
            icono: Icons.error_outline,
            texto: '${snap.error}',
          );
        }
        final lista = [
          for (final c in snap.data!)
            if (c.tipo == _tipo) c,
        ];
        return RefreshIndicator(
          onRefresh: () async {
            setState(() => _comercios = _repo.comercios());
            await _comercios;
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 40),
            children: [
              Text(
                context.l10n.store,
                style: t.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                context.l10n.storeSub,
                style: t.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              _Atajos(repo: _repo),
              const SizedBox(height: 20),
              SegmentedButton<TipoComercio>(
                segments: [
                  for (final tipo in TipoComercio.values)
                    ButtonSegment(
                      value: tipo,
                      label: Text(tipo.plural),
                      icon: Icon(
                        tipo == TipoComercio.tienda
                            ? Icons.storefront_outlined
                            : Icons.sports_tennis,
                      ),
                    ),
                ],
                selected: {_tipo},
                onSelectionChanged: (s) => setState(() => _tipo = s.first),
              ),
              const SizedBox(height: 20),
              if (lista.isEmpty)
                EstadoVacio(
                  icono: Icons.storefront_outlined,
                  texto: _tipo == TipoComercio.tienda
                      ? context.l10n.aunNoTiendas
                      : context.l10n.aunNoClubs,
                )
              else
                for (var i = 0; i < lista.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Aparece(
                      retardo: 60 * i,
                      child: _TarjetaComercio(
                        comercio: lista[i],
                        onTap: () => _abrir(lista[i]),
                      ),
                    ),
                  ),
            ],
          ),
        );
      },
    );
  }
}

class _TarjetaComercio extends StatelessWidget {
  const _TarjetaComercio({required this.comercio, required this.onTap});
  final Comercio comercio;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final marca = Marca.de(context);
    return Pulsable(
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: marca.superficie,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: marca.borde),
          ),
          child: Row(
            children: [
              AvatarEquipo(comercio.nombre, tam: 48),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comercio.nombre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: t.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (comercio.descripcion != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        comercio.descripcion!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: t.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                    if (comercio.ciudad != null) ...[
                      const SizedBox(height: 8),
                      Insignia(comercio.ciudad!, icono: Icons.place_outlined),
                    ],
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

/// Detalle: productos de una tienda o pistas de un club.
class ComercioPage extends StatelessWidget {
  const ComercioPage({super.key, required this.comercio, required this.repo});
  final Comercio comercio;
  final StoreRepositorio repo;

  @override
  Widget build(BuildContext context) {
    final esClub = comercio.tipo == TipoComercio.club;
    return Scaffold(
      appBar: AppBar(title: Text(comercio.nombre)),
      body: FondoBlobs(
        child: SafeArea(
          child: ContenidoCentrado(
            child: esClub
                ? _Lista<Pista>(
                    futuro: repo.pistas(comercio.id),
                    vacio: context.l10n.clubSinPistas,
                    fila: (p) => _Fila(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => ReservaPage(pista: p, repo: repo),
                        ),
                      ),
                      icono: p.cubierta
                          ? Icons.roofing_outlined
                          : Icons.wb_sunny_outlined,
                      titulo: p.nombre,
                      subtitulo:
                          '${p.deporte}${p.cubierta ? ' · ${context.l10n.cubierta}' : ''}',
                      precio: '${euros(p.precioHora)}/h',
                    ),
                  )
                : _Cuadricula(
                    repo: repo,
                    futuro: repo.productos(comercio.id),
                    vacio: context.l10n.tiendaSinProductos,
                  ),
          ),
        ),
      ),
    );
  }
}

class _Lista<T> extends StatelessWidget {
  const _Lista({required this.futuro, required this.vacio, required this.fila});
  final Future<List<T>> futuro;
  final String vacio;
  final Widget Function(T) fila;

  @override
  Widget build(BuildContext context) => FutureBuilder<List<T>>(
    future: futuro,
    builder: (context, snap) {
      if (snap.connectionState != ConnectionState.done) {
        return const Center(child: Cargando());
      }
      if (snap.hasError) {
        return EstadoVacio(icono: Icons.error_outline, texto: '${snap.error}');
      }
      final items = snap.data!;
      if (items.isEmpty) {
        return EstadoVacio(icono: Icons.inventory_2_outlined, texto: vacio);
      }
      return ListView.separated(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (_, i) => fila(items[i]),
      );
    },
  );
}

class _Fila extends StatelessWidget {
  const _Fila({
    required this.icono,
    required this.titulo,
    required this.precio,
    this.subtitulo,
    this.onTap,
  });
  final IconData icono;
  final String titulo, precio;
  final String? subtitulo;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final marca = Marca.de(context);
    final tarjeta = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: marca.superficie,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: marca.borde),
      ),
      child: Row(
        children: [
          Icon(icono, color: cs.primary),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: t.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                if (subtitulo != null)
                  Text(
                    subtitulo!,
                    style: t.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
              ],
            ),
          ),
          Text(
            precio,
            style: t.titleSmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: cs.primary,
            ),
          ),
          if (onTap != null) ...[
            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant),
          ],
        ],
      ),
    );
    return onTap == null
        ? tarjeta
        : GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: tarjeta,
          );
  }
}

/// Productos de una tienda en rejilla, con su imagen.
class _Cuadricula extends StatelessWidget {
  const _Cuadricula({
    required this.repo,
    required this.futuro,
    required this.vacio,
  });
  final StoreRepositorio repo;
  final Future<List<Producto>> futuro;
  final String vacio;

  @override
  Widget build(BuildContext context) => FutureBuilder<List<Producto>>(
    future: futuro,
    builder: (context, snap) {
      if (snap.connectionState != ConnectionState.done) {
        return const Center(child: Cargando());
      }
      if (snap.hasError) {
        return EstadoVacio(icono: Icons.error_outline, texto: '${snap.error}');
      }
      final items = snap.data!;
      if (items.isEmpty) {
        return EstadoVacio(icono: Icons.inventory_2_outlined, texto: vacio);
      }
      return GridView.builder(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 240,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: .56,
        ),
        itemCount: items.length,
        itemBuilder: (_, i) => _TarjetaProducto(producto: items[i], repo: repo),
      );
    },
  );
}

class _TarjetaProducto extends StatelessWidget {
  const _TarjetaProducto({required this.producto, required this.repo});
  final Producto producto;
  final StoreRepositorio repo;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final marca = Marca.de(context);
    final vacia = Container(
      color: cs.primary.withValues(alpha: .08),
      alignment: Alignment.center,
      child: Icon(Icons.shopping_bag_outlined, size: 40, color: cs.primary),
    );
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: marca.superficie,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: marca.borde),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SizedBox.expand(
              child: producto.imagenUrl == null
                  ? vacia
                  : Image.network(
                      producto.imagenUrl!,
                      fit: BoxFit.cover,
                      loadingBuilder: (_, hijo, p) => p == null ? hijo : vacia,
                      errorBuilder: (_, _, _) => vacia,
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  producto.nombre,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: t.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                if (producto.categoria != null)
                  Text(
                    producto.categoria!,
                    style: t.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                const SizedBox(height: 6),
                Text(
                  euros(producto.precio),
                  style: t.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: cs.primary,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            ProductoPage(producto: producto, repo: repo),
                      ),
                    ),
                    icon: const Icon(Icons.info_outline, size: 18),
                    label: Text(context.l10n.detalle),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => solicitarProducto(context, repo, producto),
                    icon: const Icon(Icons.shopping_cart_outlined, size: 18),
                    label: Text(context.l10n.solicitar),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Accesos rápidos: mis reservas y mis pedidos.
class _Atajos extends StatelessWidget {
  const _Atajos({required this.repo});
  final StoreRepositorio repo;

  void _ir(BuildContext context, Widget pagina) => Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (_) => pagina));

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 12,
    runSpacing: 12,
    children: [
      OutlinedButton.icon(
        onPressed: () => _ir(context, MisReservasPage(repo: repo)),
        icon: const Icon(Icons.event_available_outlined),
        label: Text(context.l10n.misReservas),
      ),
      OutlinedButton.icon(
        onPressed: () => _ir(context, MisPedidosPage(repo: repo)),
        icon: const Icon(Icons.receipt_long_outlined),
        label: Text(context.l10n.misPedidos),
      ),
    ],
  );
}
