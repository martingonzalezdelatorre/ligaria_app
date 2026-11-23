import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ligaria_ui/ligaria_ui.dart';
import '../../../core/idioma.dart';
import '../ligas/ligas_repositorio.dart';
import 'social_repositorio.dart';

/// Conversación interna con otra persona. Se refresca sola cada pocos segundos.
class ChatPage extends StatefulWidget {
  const ChatPage({super.key, required this.conId, required this.nombre});
  final String conId, nombre;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _repo = SocialRepositorio.instancia;
  final _texto = TextEditingController();
  final _scroll = ScrollController();
  List<MensajeChat>? _mensajes;
  Timer? _timer;
  bool _enviando = false;

  @override
  void initState() {
    super.initState();
    _cargar();
    _timer = Timer.periodic(const Duration(seconds: 6), (_) => _cargar());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _texto.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _cargar() async {
    try {
      final lista = await _repo.mensajes(widget.conId);
      await _repo.marcarLeidos(widget.conId);
      if (!mounted) return;
      final cambio = lista.length != _mensajes?.length;
      setState(() => _mensajes = lista);
      if (cambio) _alFinal();
    } on LigasException catch (e) {
      if (mounted && _mensajes == null) {
        setState(() => _mensajes = const []);
        avisar(context, e.mensaje);
      }
    }
  }

  void _alFinal() => WidgetsBinding.instance.addPostFrameCallback((_) {
    if (_scroll.hasClients) {
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  });

  Future<void> _enviar() async {
    final t = _texto.text.trim();
    if (t.isEmpty || _enviando) return;
    setState(() => _enviando = true);
    try {
      await _repo.enviar(widget.conId, t);
      _texto.clear();
      await _cargar();
      _alFinal();
    } on LigasException catch (e) {
      if (mounted) avisar(context, e.mensaje);
    } catch (_) {
      if (mounted) avisar(context, context.l10n.errMensaje);
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final marca = Marca.de(context);
    final hora = DateFormat.Hm();
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            AvatarEquipo(widget.nombre, tam: 34),
            const SizedBox(width: 12),
            Expanded(
              child: Text(widget.nombre, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
      body: FondoBlobs(
        child: SafeArea(
          child: ContenidoCentrado(
            child: Column(
              children: [
                Expanded(
                  child: _mensajes == null
                      ? const Center(child: Cargando())
                      : _mensajes!.isEmpty
                      ? EstadoVacio(
                          icono: Icons.chat_bubble_outline,
                          texto: context.l10n.chatVacio,
                        )
                      : ListView.builder(
                          controller: _scroll,
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          itemCount: _mensajes!.length,
                          itemBuilder: (_, i) {
                            final m = _mensajes![i];
                            return Align(
                              alignment: m.mio
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.sizeOf(context).width * .75 >
                                          460
                                      ? 460
                                      : MediaQuery.sizeOf(context).width * .75,
                                ),
                                decoration: BoxDecoration(
                                  color: m.mio ? cs.primary : marca.superficie,
                                  borderRadius: BorderRadius.circular(18),
                                  border: m.mio
                                      ? null
                                      : Border.all(color: marca.borde),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      m.texto,
                                      style: t.bodyMedium?.copyWith(
                                        color: m.mio ? cs.onPrimary : null,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      hora.format(m.fecha),
                                      style: t.labelSmall?.copyWith(
                                        color: (m.mio
                                            ? cs.onPrimary
                                            : cs.onSurfaceVariant)
                                            .withValues(alpha: .7),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: CampoTexto(
                          controller: _texto,
                          minLines: 1,
                          maxLines: 4,
                          maxLength: 1000,
                          textCapitalization: TextCapitalization.sentences,
                          onSubmitted: (_) => _enviar(),
                          decoration: InputDecoration(
                            hintText: context.l10n.escribeMensaje,
                            counterText: '',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        onPressed: _enviando ? null : _enviar,
                        icon: const Icon(Icons.send_rounded),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Bandeja: todas tus conversaciones.
class ConversacionesPage extends StatefulWidget {
  const ConversacionesPage({super.key});
  @override
  State<ConversacionesPage> createState() => _ConversacionesPageState();
}

class _ConversacionesPageState extends State<ConversacionesPage> {
  late Future<List<Conversacion>> _lista = SocialRepositorio.instancia
      .conversaciones();

  Future<void> _abrir(Conversacion c) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChatPage(conId: c.conId, nombre: c.nombre),
      ),
    );
    if (mounted) {
      setState(() => _lista = SocialRepositorio.instancia.conversaciones());
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(context.l10n.mensajesTitulo)),
    body: FondoBlobs(
      child: SafeArea(
        child: ContenidoCentrado(
          child: FutureBuilder<List<Conversacion>>(
            future: _lista,
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const Center(child: Cargando());
              }
              final lista = snap.data ?? const <Conversacion>[];
              if (lista.isEmpty) {
                return EstadoVacio(
                  icono: Icons.chat_bubble_outline,
                  texto: context.l10n.sinMensajes,
                );
              }
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  for (final c in lista)
                    Card(
                      child: ListTile(
                        leading: AvatarEquipo(c.nombre, tam: 42),
                        title: Text(
                          c.nombre,
                          style: TextStyle(
                            fontWeight: c.sinLeer > 0
                                ? FontWeight.w900
                                : FontWeight.w700,
                          ),
                        ),
                        subtitle: Text(
                          c.ultimo,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: c.sinLeer > 0
                            ? Badge(label: Text('${c.sinLeer}'))
                            : null,
                        onTap: () => _abrir(c),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    ),
  );
}
