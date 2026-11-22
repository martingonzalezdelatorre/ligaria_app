import 'package:flutter/material.dart';
import 'package:ligaria_ui/ligaria_ui.dart';
import '../grupos/grupos_repositorio.dart';
import 'liga_page.dart';
import 'ligas_repositorio.dart';
import '../../../core/idioma.dart';

/// Sección «Ligas» de un grupo: lista, creación (solo administradores) y acceso a cada liga.
class LigasSeccion extends StatefulWidget {
  const LigasSeccion({
    super.key,
    required this.grupo,
    required this.ligas,
    required this.grupos,
  });
  final Grupo grupo;
  final LigasRepositorio ligas;
  final GruposRepositorio grupos;
  @override
  State<LigasSeccion> createState() => _LigasSeccionState();
}

class _LigasSeccionState extends State<LigasSeccion> {
  late Future<List<Liga>> _lista = widget.ligas.ligas(widget.grupo.id);

  void _recargar() {
    final nueva = widget.ligas.ligas(widget.grupo.id);
    setState(() {
      _lista = nueva;
    });
  }

  Future<void> _crear() async {
    final r = await showDialog<_NuevaLiga>(
      context: context,
      builder: (_) => const _DialogoNuevaLiga(),
    );
    if (r == null) return;
    try {
      await widget.ligas.crearLiga(
        grupoId: widget.grupo.id,
        nombre: r.nombre,
        deporte: r.deporte,
        modalidad: r.modalidad,
        setsParaGanar: r.sets,
      );
      if (mounted) _recargar();
    } on LigasException catch (e) {
      if (mounted) avisar(context, e.mensaje);
    }
  }

  Future<void> _abrir(Liga l) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => LigaPage(
          liga: l,
          esAdmin: widget.ligas.puedeGestionar(l, widget.grupo),
          ligas: widget.ligas,
          grupos: widget.grupos,
        ),
      ),
    );
    if (mounted) _recargar();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(context.l10n.ligas, style: t.titleLarge)),
            if (widget.grupo.esAdmin)
              FilledButton.icon(
                onPressed: _crear,
                icon: const Icon(Icons.add),
                label: Text(context.l10n.nuevaLiga),
              ),
          ],
        ),
        const SizedBox(height: 12),
        FutureBuilder<List<Liga>>(
          future: _lista,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (snap.hasError) {
              return Text(
                context.l10n.errCargarLigas,
                style: t.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              );
            }
            final ligas = snap.data!;
            if (ligas.isEmpty) {
              return _Vacio(esAdmin: widget.grupo.esAdmin);
            }
            return Column(
              children: [
                for (final l in ligas)
                  _TarjetaLiga(liga: l, onTap: () => _abrir(l)),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _Vacio extends StatelessWidget {
  const _Vacio({required this.esAdmin});
  final bool esAdmin;
  @override
  Widget build(BuildContext context) {
    final marca = Marca.de(context);
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: marca.superficie,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: marca.borde),
      ),
      child: Row(
        children: [
          Icon(Icons.emoji_events_outlined, color: cs.primary, size: 32),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              esAdmin
                  ? context.l10n.aunNoLigasAdmin
                  : context.l10n.aunNoLigasMiembro,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}

class _TarjetaLiga extends StatelessWidget {
  const _TarjetaLiga({required this.liga, required this.onTap});
  final Liga liga;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final marca = Marca.de(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Pulsable(
        onTap: onTap,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: marca.superficie,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: marca.borde),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: .14),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.emoji_events_outlined, color: cs.primary),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        liga.nombre,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: t.titleMedium,
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          Insignia(liga.deporte.etiqueta),
                          Insignia(liga.modalidad.etiqueta),
                          Insignia(liga.estadoEtiqueta, color: cs.primary),
                          if (liga.partidos > 0)
                            Insignia(
                              context.l10n.jugadosDePartidos(
                                liga.jugados,
                                liga.partidos,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NuevaLiga {
  const _NuevaLiga(this.nombre, this.deporte, this.modalidad, this.sets);
  final String nombre;
  final Deporte deporte;
  final Modalidad modalidad;
  final int sets;
}

class _DialogoNuevaLiga extends StatefulWidget {
  const _DialogoNuevaLiga();
  @override
  State<_DialogoNuevaLiga> createState() => _DialogoNuevaLigaState();
}

class _DialogoNuevaLigaState extends State<_DialogoNuevaLiga> {
  final _nombre = TextEditingController();
  Deporte _deporte = Deporte.padel;
  Modalidad _modalidad = Modalidad.parejas;
  int _sets = 2;

  @override
  void dispose() {
    _nombre.dispose();
    super.dispose();
  }

  Widget _selector<T>(
    String titulo,
    List<T> valores,
    T actual,
    String Function(T) etiqueta,
    void Function(T) alElegir,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      Text(titulo, style: Theme.of(context).textTheme.labelLarge),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        children: [
          for (final v in valores)
            ChoiceChip(
              label: Text(etiqueta(v)),
              selected: v == actual,
              onSelected: (_) => setState(() => alElegir(v)),
            ),
        ],
      ),
    ],
  );

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(context.l10n.nuevaLiga),
    content: SizedBox(
      width: 380,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nombre,
              autofocus: true,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(labelText: context.l10n.nombreLigaEj),
            ),
            _selector<Deporte>(
              context.l10n.deporte,
              Deporte.values,
              _deporte,
              (d) => d.etiqueta,
              (d) => _deporte = d,
            ),
            _selector<Modalidad>(
              context.l10n.modalidad,
              Modalidad.values,
              _modalidad,
              (m) => m.etiqueta,
              (m) => _modalidad = m,
            ),
            _selector<int>(
              context.l10n.formatoPartido,
              const [1, 2, 3],
              _sets,
              (s) => context.l10n.alMejorDe(s * 2 - 1),
              (s) => _sets = s,
            ),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text(context.l10n.cancelar),
      ),
      FilledButton(
        onPressed: _nombre.text.trim().length < 2
            ? null
            : () => Navigator.pop(
                context,
                _NuevaLiga(_nombre.text, _deporte, _modalidad, _sets),
              ),
        child: Text(context.l10n.crear),
      ),
    ],
  );
}
