import '../../core/idioma.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ligaria_ui/ligaria_ui.dart';
import '../../core/auth.dart';
import '../../core/widgets.dart';
import '../../data/models.dart';
import '../escuela/invitar_dialog.dart';
import 'organizador_providers.dart';

/// Equipo de la organización: los organizadores de ligas, y la invitación de otros.
/// Un organizador solo puede invitar a otros organizadores (no concede más poder del que ya tiene).
class EquipoTab extends ConsumerWidget {
  const EquipoTab({super.key, required this.orgId});
  final String orgId;

  Future<void> _invitar(BuildContext context, WidgetRef ref) async {
    await mostrarInvitar(context, ref, orgId, rolFijo: Rol.organizadorLiga);
    ref.invalidate(orgEquipoProvider(orgId));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tema = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('invitar-organizador'),
        onPressed: () => _invitar(context, ref),
        icon: const Icon(Icons.person_add_alt),
        label: Text(context.l10n.invitarOrganizador),
      ),
      body: AsyncView<List<UsuarioEscuela>>(
        value: ref.watch(orgEquipoProvider(orgId)),
        onRetry: () => ref.invalidate(orgEquipoProvider(orgId)),
        builder: (lista) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(orgEquipoProvider(orgId)),
          child: ListView(
            padding: const EdgeInsets.only(bottom: 88),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Text(
                  context.l10n.organizadoresAyuda,
                  style: tema.textTheme.bodySmall?.copyWith(
                    color: tema.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              if (lista.isEmpty)
                EstadoVacio(
                  icono: Icons.groups_outlined,
                  texto: context.l10n.sinOrganizadores,
                ),
              for (final u in lista)
                ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.manage_accounts_outlined),
                  ),
                  title: Text(
                    u.nombre?.isNotEmpty == true ? u.nombre! : u.email,
                  ),
                  subtitle: Text(
                    u.nombre?.isNotEmpty == true
                        ? u.email
                        : etiquetaRol(Rol.organizadorLiga),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
