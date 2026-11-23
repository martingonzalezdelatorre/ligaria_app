import 'package:flutter/material.dart';
import 'package:ligaria_ui/ligaria_ui.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/idioma.dart';
import '../amistosos/amistosos_repositorio.dart';
import '../grupos/grupos_repositorio.dart';
import '../ligas/ligas_repositorio.dart';
import '../ligas/nuevo_partido.dart';
import 'chat_page.dart';
import 'social_repositorio.dart';

/// Acciones que se pueden hacer con otro jugador desde cualquier pantalla
/// (amigos, búsqueda de jugadores, ranking): WhatsApp, mensaje interno y retarle a un partido.
class AccionesJugador {
  const AccionesJugador({
    required this.grupos,
    required this.ligas,
    required this.amistosos,
    this.alCambiar,
  });
  final GruposRepositorio grupos;
  final LigasRepositorio ligas;
  final AmistososRepositorio amistosos;

  /// Se llama tras crear un partido o añadir un amigo, para refrescar la pantalla.
  final VoidCallback? alCambiar;

  SocialRepositorio get _social => SocialRepositorio.instancia;

  /// ¿Es una acción sobre uno mismo? (no se ofrece)
  bool esYo(String id) => id == grupos.yo;

  Future<void> whatsapp(BuildContext context, String id, String nombre) async {
    try {
      final tel = await _social.whatsapp(id);
      if (!context.mounted) return;
      if (tel == null || tel.trim().isEmpty) {
        avisar(context, context.l10n.sinWhatsapp(nombre));
        return;
      }
      var digitos = tel.replaceAll(RegExp(r'[^0-9]'), '');
      if (digitos.length == 9) digitos = '34$digitos'; // número español sin prefijo
      final ok = await launchUrl(
        Uri.parse('https://wa.me/$digitos'),
        mode: LaunchMode.externalApplication,
      );
      if (!ok && context.mounted) avisar(context, context.l10n.errWhatsapp);
    } on LigasException catch (e) {
      if (context.mounted) avisar(context, e.mensaje);
    } catch (_) {
      if (context.mounted) avisar(context, context.l10n.errWhatsapp);
    }
  }

  Future<void> mensaje(BuildContext context, String id, String nombre) =>
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ChatPage(conId: id, nombre: nombre),
        ),
      );

  Future<void> anadirAmigo(BuildContext context, String id) async {
    try {
      await _social.anadirAmigo(id);
      if (!context.mounted) return;
      avisar(context, context.l10n.amigoAnadido);
      alCambiar?.call();
    } on LigasException catch (e) {
      if (context.mounted) avisar(context, e.mensaje);
    }
  }

  /// Crea un partido individual contigo contra [id]; si aún no es amigo, lo añade antes.
  Future<void> retar(
    BuildContext context,
    String id, {
    bool esAmigo = true,
  }) async {
    try {
      if (!esAmigo) await _social.anadirAmigo(id);
      final mis = await grupos.misGrupos();
      if (!context.mounted) return;
      final creado = await mostrarNuevoPartido(
        context,
        grupos: mis,
        gruposRepo: grupos,
        ligas: ligas,
        amistosos: amistosos,
        rivalId: id,
      );
      if (creado == null || !context.mounted) return;
      avisar(context, context.l10n.partidoCreado);
      alCambiar?.call();
    } on LigasException catch (e) {
      if (context.mounted) avisar(context, e.mensaje);
    }
  }

  /// Hoja con todas las acciones disponibles para [id].
  Future<void> mostrar(
    BuildContext context, {
    required String id,
    required String nombre,
    bool esAmigo = true,
  }) {
    if (esYo(id)) return Future.value();
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      constraints: const BoxConstraints(maxWidth: 520),
      builder: (sheet) {
        final t = Theme.of(sheet).textTheme;
        void hacer(Future<void> Function() accion) {
          Navigator.pop(sheet);
          accion();
        }

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AvatarEquipo(nombre, tam: 44),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        nombre,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: t.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(Icons.chat_outlined),
                  title: Text(sheet.l10n.accWhatsapp),
                  onTap: () => hacer(() => whatsapp(context, id, nombre)),
                ),
                ListTile(
                  leading: const Icon(Icons.forum_outlined),
                  title: Text(sheet.l10n.accMensaje),
                  onTap: () => hacer(() => mensaje(context, id, nombre)),
                ),
                ListTile(
                  leading: const Icon(Icons.sports_tennis),
                  title: Text(sheet.l10n.accRetar),
                  onTap: () =>
                      hacer(() => retar(context, id, esAmigo: esAmigo)),
                ),
                if (!esAmigo)
                  ListTile(
                    leading: const Icon(Icons.person_add_alt_1_outlined),
                    title: Text(sheet.l10n.accAnadirAmigo),
                    onTap: () => hacer(() => anadirAmigo(context, id)),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Fila de botones rápidos (WhatsApp, mensaje, retar) para tarjetas de jugador.
class BotonesJugador extends StatelessWidget {
  const BotonesJugador({
    super.key,
    required this.acciones,
    required this.id,
    required this.nombre,
    this.esAmigo = true,
  });
  final AccionesJugador acciones;
  final String id, nombre;
  final bool esAmigo;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: l.accWhatsapp,
          onPressed: () => acciones.whatsapp(context, id, nombre),
          icon: const Icon(Icons.chat_outlined),
        ),
        IconButton(
          tooltip: l.accMensaje,
          onPressed: () => acciones.mensaje(context, id, nombre),
          icon: const Icon(Icons.forum_outlined),
        ),
        IconButton(
          tooltip: l.accRetar,
          onPressed: () => acciones.retar(context, id, esAmigo: esAmigo),
          icon: const Icon(Icons.sports_tennis),
        ),
      ],
    );
  }
}
