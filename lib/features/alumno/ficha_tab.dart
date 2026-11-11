import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/widgets.dart';
import '../../data/liga_repository.dart';
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
                  subtitle: Text('${f.escuela} · ${f.relacion == 'tutor' ? 'Tutelado/a' : 'Mi ficha'}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => FichaDetallePage(personaId: f.personaId)),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

String descripcionVisibilidad(Visibilidad v) => switch (v) {
      Visibilidad.nombreCompleto => 'Otras escuelas ven tu nombre y apellidos junto a los resultados.',
      Visibilidad.iniciales => 'Otras escuelas solo ven tus iniciales junto a los resultados.',
      Visibilidad.soloEscuela => 'Solo tu escuela ve tu nombre; el resto verá «Jugador/a».',
    };

class FichaDetallePage extends ConsumerStatefulWidget {
  const FichaDetallePage({super.key, required this.personaId});
  final String personaId;
  @override
  ConsumerState<FichaDetallePage> createState() => _FichaDetallePageState();
}

class _FichaDetallePageState extends ConsumerState<FichaDetallePage> {
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    // Registro de acceso a datos de menores (los fallos no bloquean la pantalla).
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final fichas = ref.read(misFichasProvider).value;
      final f = fichas?.where((x) => x.personaId == widget.personaId).firstOrNull;
      if (f == null || edadDe(f.fechaNacimiento) >= 18) return;
      try {
        await ref.read(ligaRepositoryProvider).registrarAccesoFicha(widget.personaId, contexto: 'ficha');
        ref.invalidate(accesosFichaProvider(widget.personaId));
      } catch (_) {}
    });
  }

  Future<void> _ejecutar(Future<void> Function() accion) async {
    setState(() => _guardando = true);
    try {
      await accion();
      ref.invalidate(misFichasProvider);
      await ref.read(misFichasProvider.future);
    } catch (_) {
      if (mounted) avisar(context, 'No se pudo guardar el cambio. Inténtalo de nuevo.');
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fichas = ref.watch(misFichasProvider);
    final f = fichas.value?.where((x) => x.personaId == widget.personaId).firstOrNull;
    return Scaffold(
      appBar: AppBar(title: Text(f?.nombreCompleto ?? 'Ficha')),
      body: f == null
          ? AsyncView<List<Ficha>>(
              value: fichas, onRetry: () => ref.invalidate(misFichasProvider), builder: (_) => const EstadoVacio(icono: Icons.badge_outlined, texto: 'Ficha no disponible.'))
          : _contenido(context, f),
    );
  }

  Widget _contenido(BuildContext context, Ficha f) {
    final tema = Theme.of(context);
    final repo = ref.read(ligaRepositoryProvider);
    final edad = edadDe(f.fechaNacimiento);
    final esTutor = f.relacion == 'tutor';
    final puedeEditar = esTutor || (f.relacion == 'propia' && edad >= 14);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(f.nombreCompleto, style: tema.textTheme.headlineSmall),
        Text('${f.escuela} · $edad años', style: tema.textTheme.bodyMedium?.copyWith(color: tema.colorScheme.outline)),
        const SizedBox(height: 24),
        Text('Privacidad de la ficha', style: tema.textTheme.titleSmall),
        const SizedBox(height: 8),
        SegmentedButton<Visibilidad>(
          showSelectedIcon: false,
          segments: const [
            ButtonSegment(value: Visibilidad.nombreCompleto, label: Text('Nombre completo')),
            ButtonSegment(value: Visibilidad.iniciales, label: Text('Iniciales')),
            ButtonSegment(value: Visibilidad.soloEscuela, label: Text('Solo mi escuela')),
          ],
          selected: {f.visibilidad},
          onSelectionChanged: (!puedeEditar || _guardando)
              ? null
              : (s) => _ejecutar(() => repo.actualizarPrivacidad(f.personaId, s.first, f.mostrarFoto)),
        ),
        const SizedBox(height: 8),
        Text(descripcionVisibilidad(f.visibilidad), style: tema.textTheme.bodySmall),
        if (!puedeEditar)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text('Solo el tutor (o la propia persona, si es mayor de 14 años) puede cambiar estos ajustes.',
                style: tema.textTheme.bodySmall?.copyWith(color: tema.colorScheme.outline)),
          ),
        const SizedBox(height: 8),
        SwitchListTile(
          key: const Key('switch_foto'),
          contentPadding: EdgeInsets.zero,
          title: const Text('Mostrar foto'),
          subtitle: const Text('Desactivado por defecto. Otras escuelas no ven fotos.'),
          value: f.mostrarFoto,
          onChanged: (!puedeEditar || _guardando)
              ? null
              : (v) => _ejecutar(() => repo.actualizarPrivacidad(f.personaId, f.visibilidad, v)),
        ),
        if (f.menor14) ...[
          const Divider(height: 32),
          Text('Consentimiento del tutor', style: tema.textTheme.titleSmall),
          const SizedBox(height: 4),
          Row(children: [
            Icon(f.consentimiento ? Icons.verified_outlined : Icons.warning_amber_outlined,
                color: f.consentimiento ? tema.colorScheme.primary : tema.colorScheme.error),
            const SizedBox(width: 8),
            Expanded(
              child: Text(f.consentimiento
                  ? 'Consentimiento otorgado.'
                  : 'Falta el consentimiento: sin él no puede participar en equipos.'),
            ),
          ]),
          if (esTutor)
            SwitchListTile(
              key: const Key('switch_consentimiento'),
              contentPadding: EdgeInsets.zero,
              title: const Text('Doy mi consentimiento'),
              value: f.consentimiento,
              onChanged: _guardando ? null : (v) => _ejecutar(() => repo.registrarConsentimiento(f.personaId, v)),
            ),
        ],
        if (edad < 18) _Accesos(personaId: f.personaId),
      ],
    );
  }
}

class _Accesos extends ConsumerWidget {
  const _Accesos({required this.personaId});
  final String personaId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accesos = ref.watch(accesosFichaProvider(personaId));
    return accesos.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (lista) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Divider(height: 32),
        Text('Accesos a la ficha', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 4),
        if (lista.isEmpty) const Text('Sin accesos registrados.'),
        for (final a in lista.take(10))
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.visibility_outlined, size: 20),
            title: Text(fechaLarga(a.fecha)),
            subtitle: a.contexto == null ? null : Text(a.contexto!),
          ),
      ]),
    );
  }
}
