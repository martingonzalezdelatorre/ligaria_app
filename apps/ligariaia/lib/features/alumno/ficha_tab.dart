import 'package:flutter/material.dart';
import 'package:ligaria_ui/ligaria_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/widgets.dart';
import '../../data/models.dart';
import 'alumno_providers.dart';

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
    return AsyncView<List<Ficha>>(
      value: ref.watch(misFichasProvider),
      onRetry: () => ref.invalidate(misFichasProvider),
      builder: (fichas) {
        if (fichas.isEmpty) {
          return const EstadoVacio(icono: Icons.badge_outlined, texto: 'No hay fichas asociadas a tu cuenta.');
        }
        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(misFichasProvider);
            await ref.read(misFichasProvider.future);
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              for (final f in fichas)
                ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person_outline)),
                  title: Text(f.nombreCompleto),
                  subtitle: Text('${f.escuela ?? 'Sin organización'} · ${f.relacion == 'tutor' ? 'Tutelado/a' : 'Mi ficha'}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => FichaDetallePage(jugadorId: f.jugadorId)),
                  ),
                ),
            ],
          ),
        );
      },
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
      appBar: AppBar(title: Text(f?.nombreCompleto ?? 'Ficha')),
      body: f == null
          ? AsyncView<List<Ficha>>(
              value: fichas,
              onRetry: () => ref.invalidate(misFichasProvider),
              builder: (_) => const EstadoVacio(icono: Icons.badge_outlined, texto: 'Ficha no disponible.'))
          : _contenido(context, ref, f),
    );
  }

  Widget _contenido(BuildContext context, WidgetRef ref, Ficha f) {
    final tema = Theme.of(context);
    final nac = f.fechaNacimiento;
    final equipos = ref.watch(misEquiposProvider).value ?? const <MiEquipo>[];
    final suyos = equipos.where((e) => e.rol != 'entrenador').map((e) => e.equipo).toSet();
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
        Text(f.escuela ?? 'Sin organización',
            style: tema.textTheme.bodyMedium?.copyWith(color: tema.colorScheme.onSurfaceVariant)),
        const SizedBox(height: 16),
        if (nac != null) dato(Icons.cake_outlined, 'Edad', '${edadDe(nac)} años · ${fechaLarga(nac)}'),
        dato(Icons.leaderboard_outlined, 'Nivel', f.nivel ?? '—'),
        dato(Icons.front_hand_outlined, 'Mano dominante', etiquetaMano(f.manoDominante)),
        dato(Icons.wc_outlined, 'Género', etiquetaGenero(f.genero)),
        if (suyos.isNotEmpty) dato(Icons.groups_outlined, 'Equipos', suyos.join(' · ')),
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Text(
              'Otras escuelas que compiten contra tu equipo solo ven tu nombre y la inicial del apellido junto a los resultados.',
              style: tema.textTheme.bodySmall?.copyWith(color: tema.colorScheme.onSurfaceVariant)),
        ),
      ],
    );
  }
}
