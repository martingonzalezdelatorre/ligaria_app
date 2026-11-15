import 'package:flutter/material.dart';
import 'package:ligaria_ui/ligaria_ui.dart';
import 'store_repositorio.dart';

const _horaApertura = 9, _horaCierre = 23; // última franja: 22:00-23:00
const _diasVisibles = 14;
const _diasSemana = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];

String _hora(DateTime d) => '${d.hour.toString().padLeft(2, '0')}:00';
String _dia(DateTime d) =>
    '${_diasSemana[d.weekday - 1]} ${d.day}/${d.month.toString().padLeft(2, '0')}';

/// Elegir día y hora para reservar una pista.
class ReservaPage extends StatefulWidget {
  const ReservaPage({super.key, required this.pista, required this.repo});
  final Pista pista;
  final StoreRepositorio repo;
  @override
  State<ReservaPage> createState() => _ReservaPageState();
}

class _ReservaPageState extends State<ReservaPage> {
  final _hoy = DateTime.now();
  late DateTime _dia0 = DateTime(_hoy.year, _hoy.month, _hoy.day);
  late Future<Set<DateTime>> _ocupadas = widget.repo.ocupadas(
    widget.pista.id,
    _dia0,
  );

  void _cargar() => _ocupadas = widget.repo.ocupadas(widget.pista.id, _dia0);

  Future<void> _reservar(DateTime inicio) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Confirmar reserva'),
        content: Text(
          '${widget.pista.nombre} · ${_dia(inicio)} de ${_hora(inicio)} a '
          '${_hora(inicio.add(const Duration(hours: 1)))}\n'
          'Precio: ${euros(widget.pista.precioHora)}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Reservar'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await widget.repo.reservar(widget.pista.id, inicio);
      if (!mounted) return;
      avisar(context, 'Reserva confirmada');
    } on StoreException catch (e) {
      if (!mounted) return;
      avisar(context, e.mensaje);
    }
    if (mounted) setState(_cargar);
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final dias = [
      for (var i = 0; i < _diasVisibles; i++)
        DateTime(_hoy.year, _hoy.month, _hoy.day + i),
    ];
    return Scaffold(
      appBar: AppBar(title: Text(widget.pista.nombre)),
      body: FondoBlobs(
        child: SafeArea(
          child: ContenidoCentrado(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
              children: [
                Text(
                  '${euros(widget.pista.precioHora)} por hora',
                  style: t.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 44,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      for (final d in dias)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(_dia(d)),
                            selected: d == _dia0,
                            onSelected: (_) => setState(() {
                              _dia0 = d;
                              _cargar();
                            }),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                FutureBuilder<Set<DateTime>>(
                  future: _ocupadas,
                  builder: (context, snap) {
                    if (snap.connectionState != ConnectionState.done) {
                      return const Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (snap.hasError) {
                      return EstadoVacio(
                        icono: Icons.error_outline,
                        texto: '${snap.error}',
                      );
                    }
                    final ocupadas = snap.data!;
                    return Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        for (var h = _horaApertura; h < _horaCierre; h++)
                          _Franja(
                            inicio: DateTime(
                              _dia0.year,
                              _dia0.month,
                              _dia0.day,
                              h,
                            ),
                            ocupada: ocupadas.contains(
                              DateTime(_dia0.year, _dia0.month, _dia0.day, h),
                            ),
                            onTap: _reservar,
                          ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  'Las horas en gris están ocupadas o ya han pasado.',
                  style: t.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Franja extends StatelessWidget {
  const _Franja({
    required this.inicio,
    required this.ocupada,
    required this.onTap,
  });
  final DateTime inicio;
  final bool ocupada;
  final void Function(DateTime) onTap;

  @override
  Widget build(BuildContext context) {
    final libre = !ocupada && inicio.isAfter(DateTime.now());
    return OutlinedButton(
      onPressed: libre ? () => onTap(inicio) : null,
      child: Text(_hora(inicio)),
    );
  }
}

/// Reservas del usuario, con opción de cancelar las futuras.
class MisReservasPage extends StatefulWidget {
  const MisReservasPage({super.key, required this.repo});
  final StoreRepositorio repo;
  @override
  State<MisReservasPage> createState() => _MisReservasPageState();
}

class _MisReservasPageState extends State<MisReservasPage> {
  late Future<List<Reserva>> _reservas = widget.repo.misReservas();

  Future<void> _cancelar(Reserva r) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Cancelar reserva'),
        content: Text(
          '${r.club} · ${r.pista} · ${_dia(r.inicio)} ${_hora(r.inicio)}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Mantener'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Cancelar reserva'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await widget.repo.cancelar(r.id);
    } on StoreException catch (e) {
      if (mounted) avisar(context, e.mensaje);
    }
    if (mounted) setState(() => _reservas = widget.repo.misReservas());
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final marca = Marca.de(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Mis reservas')),
      body: FondoBlobs(
        child: SafeArea(
          child: ContenidoCentrado(
            child: FutureBuilder<List<Reserva>>(
              future: _reservas,
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
                    icono: Icons.event_busy_outlined,
                    texto: 'Aún no tienes reservas.',
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
                  itemCount: lista.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    final r = lista[i];
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: marca.superficie,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: marca.borde),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.event_available_outlined,
                            color: r.futura ? cs.primary : cs.onSurfaceVariant,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${r.club} · ${r.pista}',
                                  style: t.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  '${_dia(r.inicio)} · ${_hora(r.inicio)} · ${euros(r.precio)}',
                                  style: t.bodySmall?.copyWith(
                                    color: cs.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (r.futura)
                            IconButton(
                              tooltip: 'Cancelar',
                              onPressed: () => _cancelar(r),
                              icon: const Icon(Icons.close_rounded),
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
