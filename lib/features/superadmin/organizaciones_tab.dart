import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/auth.dart';
import '../../core/formulario.dart';
import '../../core/widgets.dart';
import '../../data/liga_repository.dart';
import '../../data/models.dart';
import '../escuela/invitar_dialog.dart';
import 'superadmin_providers.dart';

/// Organizaciones de la plataforma: se crean y se les asigna su administrador por correo.
class OrganizacionesTab extends ConsumerWidget {
  const OrganizacionesTab({super.key});

  Future<void> _crear(BuildContext context, WidgetRef ref) async {
    final r = await mostrarFormulario<_NuevaOrg>(context, (_) => const _NuevaOrganizacionDialog());
    if (r == null) return;
    try {
      await ref.read(ligaRepositoryProvider).crearOrganizacion(r.nombre, r.tipo, ciudad: r.ciudad);
      ref.invalidate(saOrganizacionesProvider);
      if (context.mounted) avisar(context, 'Organización creada. Asígnale un administrador.');
    } catch (_) {
      if (context.mounted) avisar(context, 'No se pudo crear la organización.');
    }
  }

  /// Escuelas y grupos los administra ADMIN_ESCUELAS; un ayuntamiento lo gestiona un ORGANIZADOR_LIGAS.
  Rol _rolAdmin(OrganizacionAdmin o) => o.tipo == 'AYUNTAMIENTO' ? Rol.organizadorLiga : Rol.adminEscuela;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _crear(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Nueva organización'),
      ),
      body: AsyncView<List<OrganizacionAdmin>>(
        value: ref.watch(saOrganizacionesProvider),
        onRetry: () => ref.invalidate(saOrganizacionesProvider),
        builder: (lista) => lista.isEmpty
            ? const EstadoVacio(icono: Icons.apartment_outlined, texto: 'Todavía no hay organizaciones.')
            : RefreshIndicator(
                onRefresh: () => ref.refresh(saOrganizacionesProvider.future),
                child: ListView(
                  padding: const EdgeInsets.only(top: 8, bottom: 96),
                  children: [
                    for (final o in lista)
                      Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        child: ListTile(
                          leading: Icon(switch (o.tipo) {
                            'AYUNTAMIENTO' => Icons.account_balance_outlined,
                            'GRUPO_AMIGOS' => Icons.group_outlined,
                            _ => Icons.school_outlined,
                          }),
                          title: Text(o.nombre),
                          subtitle: Text('${etiquetaTipoOrg(o.tipo)}${o.ciudad == null ? '' : ' · ${o.ciudad}'}'
                              ' · ${o.administradores == 0 ? 'sin administrador' : '${o.administradores} admin.'}'),
                          trailing: IconButton(
                            key: Key('admin-${o.id}'),
                            tooltip: 'Asignar administrador',
                            icon: Icon(Icons.person_add_alt, color: o.administradores == 0 ? cs.primary : null),
                            onPressed: () async {
                              await mostrarInvitar(context, ref, o.id, rolFijo: _rolAdmin(o));
                              ref.invalidate(saOrganizacionesProvider);
                            },
                          ),
                        ),
                      ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _NuevaOrg {
  const _NuevaOrg(this.nombre, this.tipo, this.ciudad);
  final String nombre, tipo;
  final String? ciudad;
}

class _NuevaOrganizacionDialog extends StatefulWidget {
  const _NuevaOrganizacionDialog();
  @override
  State<_NuevaOrganizacionDialog> createState() => _NuevaOrganizacionDialogState();
}

class _NuevaOrganizacionDialogState extends State<_NuevaOrganizacionDialog> {
  final _nombre = TextEditingController();
  final _ciudad = TextEditingController();
  String _tipo = 'ESCUELA';
  String? _error;

  @override
  void dispose() {
    _nombre.dispose();
    _ciudad.dispose();
    super.dispose();
  }

  void _crear() {
    final n = _nombre.text.trim();
    if (n.isEmpty) {
      setState(() => _error = 'El nombre es obligatorio');
    } else {
      Navigator.of(context).pop(_NuevaOrg(n, _tipo, _ciudad.text.trim().isEmpty ? null : _ciudad.text.trim()));
    }
  }

  @override
  Widget build(BuildContext context) => HojaFormulario(
        icono: Icons.apartment_rounded,
        titulo: 'Nueva organización',
        subtitulo: 'Escuela, ayuntamiento o grupo de amigos.',
        etiquetaAccion: 'Crear',
        iconoAccion: Icons.check_rounded,
        onAccion: _crear,
        children: [
          DropdownButtonFormField<String>(
            key: const Key('org-tipo'),
            initialValue: _tipo,
            decoration: decoracionCampo('Tipo', Icons.category_outlined),
            items: [for (final t in const ['ESCUELA', 'AYUNTAMIENTO', 'GRUPO_AMIGOS']) DropdownMenuItem(value: t, child: Text(etiquetaTipoOrg(t)))],
            onChanged: (v) => setState(() => _tipo = v ?? 'ESCUELA'),
          ),
          espacioCampo,
          TextField(
            controller: _nombre,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            decoration: decoracionCampo('Nombre', Icons.badge_outlined).copyWith(errorText: _error),
          ),
          espacioCampo,
          TextField(
            controller: _ciudad,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _crear(),
            decoration: decoracionCampo('Ciudad (opcional)', Icons.location_city_outlined),
          ),
        ],
      );
}
