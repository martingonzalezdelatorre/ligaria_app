import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/auth.dart';
import '../../core/widgets.dart';
import '../../data/models.dart';
import 'escuela_providers.dart';
import 'invitar_dialog.dart';

class UsuariosTab extends ConsumerWidget {
  const UsuariosTab({super.key, required this.escuelaId});
  final String escuelaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final datos = ref.watch(usuariosEscuelaProvider(escuelaId));
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => mostrarInvitar(context, ref, escuelaId),
        icon: const Icon(Icons.person_add_alt),
        label: const Text('Invitar'),
      ),
      body: AsyncView<List<UsuarioEscuela>>(
        value: datos,
        onRetry: () => ref.invalidate(usuariosEscuelaProvider(escuelaId)),
        builder: (lista) => lista.isEmpty
            ? const EstadoVacio(icono: Icons.people_outline, texto: 'Aún no hay usuarios en esta escuela.')
            : RefreshIndicator(
                onRefresh: () async => ref.invalidate(usuariosEscuelaProvider(escuelaId)),
                child: ListView(padding: const EdgeInsets.only(bottom: 88), children: [
                  for (final u in lista)
                    ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.person_outline)),
                      title: Text(u.nombre?.isNotEmpty == true ? u.nombre! : u.email),
                      subtitle: Text('${u.email} · ${_rolLegible(u.rol)}'),
                    ),
                ]),
              ),
      ),
    );
  }

  String _rolLegible(String rolDb) {
    try {
      return etiquetaRol(rolDesdeDb(rolDb));
    } catch (_) {
      return rolDb;
    }
  }
}
