import '../../core/idioma.dart';
import 'package:flutter/material.dart';
import 'package:ligaria_ui/ligaria_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/widgets.dart';
import '../../data/models.dart';
import '../../core/auth.dart';
import 'alumno_providers.dart';
import 'anadir_hijo.dart';

int edadDe(DateTime nac, [DateTime? hoy]) {
  final h = hoy ?? DateTime.now();
  var e = h.year - nac.year;
  if (h.month < nac.month || (h.month == nac.month && h.day < nac.day)) e--;
  return e;
}

/// Pestaña «Mi ficha»: la propia y la de los menores a mi cargo.
class FichaTab extends ConsumerWidget {
  const FichaTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orgs = orgsComoTutor(
      ref.watch(pertenenciasProvider).value ?? const [],
    );
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: orgs.isEmpty
          ? null
          : FloatingActionButton.extended(
              key: const Key('anadir-hijo'),
              onPressed: () => mostrarAnadirHijo(context, ref, orgs),
              icon: const Icon(Icons.add),
              label: Text(context.l10n.anadirHijoBtn),
            ),
      body: AsyncView<List<Ficha>>(
        value: ref.watch(misFichasProvider),
        onRetry: () => ref.invalidate(misFichasProvider),
        builder: (fichas) {
          if (fichas.isEmpty) {
            return EstadoVacio(
              icono: Icons.badge_outlined,
              texto: orgs.isEmpty
                  ? context.l10n.sinFichas
                  : context.l10n.sinHijos,
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(misFichasProvider);
              await ref.read(misFichasProvider.future);
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 88),
              children: [
                for (final f in fichas)
                  ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.person_outline),
                    ),
                    title: Text(f.nombreCompleto),
                    subtitle: Text(
                      '${f.escuela ?? context.l10n.sinOrganizacion} · ${f.relacion == 'tutor' ? context.l10n.tutelado : context.l10n.miFicha}',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            FichaDetallePage(jugadorId: f.jugadorId),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Ficha de un jugador: datos deportivos y de contacto con su organización.
class FichaDetallePage extends ConsumerWidget {
  const FichaDetallePage({super.key, required this.jugadorId});
  final String jugadorId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fichas = ref.watch(misFichasProvider);
    final f = fichas.value?.where((x) => x.jugadorId == jugadorId).firstOrNull;
    return Scaffold(
      appBar: AppBar(title: Text(f?.nombreCompleto ?? context.l10n.ficha)),
      body: f == null
          ? AsyncView<List<Ficha>>(
              value: fichas,
              onRetry: () => ref.invalidate(misFichasProvider),
              builder: (_) => EstadoVacio(
                icono: Icons.badge_outlined,
                texto: context.l10n.fichaNoDisp,
              ),
            )
          : _contenido(context, ref, f),
    );
  }

  Widget _contenido(BuildContext context, WidgetRef ref, Ficha f) {
    final tema = Theme.of(context);
    final nac = f.fechaNacimiento;
    final equipos = ref.watch(misEquiposProvider).value ?? const <MiEquipo>[];
    final suyos = equipos
        .where((e) => e.rol != 'entrenador')
        .map((e) => e.equipo)
        .toSet();
    Widget dato(IconData i, String etiqueta, String valor) => ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(i),
      title: Text(etiqueta, style: tema.textTheme.bodySmall),
      subtitle: Text(valor, style: tema.textTheme.bodyLarge),
    );
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(f.nombreCompleto, style: tema.textTheme.headlineSmall),
        Text(
          f.escuela ?? context.l10n.sinOrganizacion,
          style: tema.textTheme.bodyMedium?.copyWith(
            color: tema.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        if (nac != null)
          dato(
            Icons.cake_outlined,
            context.l10n.edad,
            context.l10n.edadYFecha(edadDe(nac), fechaLarga(nac)),
          ),
        dato(Icons.leaderboard_outlined, context.l10n.nivel, f.nivel ?? '—'),
        dato(
          Icons.front_hand_outlined,
          context.l10n.manoDominante,
          etiquetaMano(f.manoDominante),
        ),
        dato(Icons.wc_outlined, context.l10n.genero, etiquetaGenero(f.genero)),
        if (suyos.isNotEmpty)
          dato(Icons.groups_outlined, context.l10n.equipos, suyos.join(' · ')),
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Text(
            context.l10n.privacidadAjena,
            style: tema.textTheme.bodySmall?.copyWith(
              color: tema.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
