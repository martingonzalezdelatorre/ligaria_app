import 'dart:async';

import 'package:flutter/material.dart';

import 'notificacion.dart';
import 'servicio.dart';

/// Arranca el servicio mientras el widget está en pantalla y, donde no hay notificaciones del
/// sistema (web), enseña cada aviso nuevo como banner dentro de la app.
///
/// [servicio] puede ser `null` (sin sesión o modo demo) y cambiar con el tiempo: el host arranca
/// y detiene el servicio sin volver a crear [child], así que se puede colocar en el `builder` de
/// `MaterialApp` por encima del `Navigator`.
class NotificacionesHost extends StatefulWidget {
  const NotificacionesHost({
    super.key,
    required this.servicio,
    required this.child,
    this.alAbrir,
  });

  final NotificacionesServicio? servicio;
  final Widget child;

  /// Se llama al tocar una notificación (del sistema, banner o bandeja).
  final void Function(Notificacion n)? alAbrir;

  @override
  State<NotificacionesHost> createState() => _NotificacionesHostState();
}

class _NotificacionesHostState extends State<NotificacionesHost>
    with WidgetsBindingObserver {
  StreamSubscription<Notificacion>? _subRecibidas;
  StreamSubscription<Notificacion>? _subAperturas;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _conectar(widget.servicio);
  }

  void _conectar(NotificacionesServicio? s) {
    if (s == null) return;
    _subRecibidas = s.recibidas.listen(_banner);
    _subAperturas = s.aperturas.listen((n) => widget.alAbrir?.call(n));
    unawaited(s.iniciar());
  }

  void _desconectar(NotificacionesServicio? s) {
    _subRecibidas?.cancel();
    _subAperturas?.cancel();
    _subRecibidas = _subAperturas = null;
    if (s != null) unawaited(s.detener());
  }

  @override
  void didUpdateWidget(NotificacionesHost old) {
    super.didUpdateWidget(old);
    if (!identical(old.servicio, widget.servicio)) {
      _desconectar(old.servicio);
      _conectar(widget.servicio);
    }
  }

  void _banner(Notificacion n) {
    final s = widget.servicio;
    if (!mounted || s == null || s.avisos.nativo) return;
    final m = ScaffoldMessenger.maybeOf(context);
    m?.showSnackBar(
      SnackBar(
        content: Text(n.cuerpo.isEmpty ? n.titulo : '${n.titulo}\n${n.cuerpo}'),
        behavior: SnackBarBehavior.floating,
        action: widget.alAbrir == null
            ? null
            : SnackBarAction(
                label: 'Ver',
                onPressed: () => widget.alAbrir!(n),
              ),
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final s = widget.servicio;
      if (s != null) unawaited(s.refrescar());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _desconectar(widget.servicio);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// Icono de campana con insignia de no leídas; abre la bandeja.
class CampanaNotificaciones extends StatelessWidget {
  const CampanaNotificaciones({
    super.key,
    required this.servicio,
    this.alAbrir,
    this.tipos,
  });

  final NotificacionesServicio servicio;
  final void Function(Notificacion n)? alAbrir;

  /// Tipos y su etiqueta para la pantalla de preferencias (si se informa, se ofrece el acceso).
  final Map<String, String>? tipos;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<int>(
    valueListenable: servicio.noLeidas,
    builder: (context, n, _) => IconButton(
      tooltip: 'Notificaciones',
      icon: Badge(
        isLabelVisible: n > 0,
        label: Text(n > 99 ? '99+' : '$n'),
        child: const Icon(Icons.notifications_outlined),
      ),
      onPressed: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => BandejaNotificacionesPage(
            servicio: servicio,
            alAbrir: alAbrir,
            tipos: tipos,
          ),
        ),
      ),
    ),
  );
}

/// Lista de notificaciones; al tocar una se marca como leída y se llama a [alAbrir].
class BandejaNotificacionesPage extends StatefulWidget {
  const BandejaNotificacionesPage({
    super.key,
    required this.servicio,
    this.alAbrir,
    this.tipos,
  });

  final NotificacionesServicio servicio;
  final void Function(Notificacion n)? alAbrir;
  final Map<String, String>? tipos;

  @override
  State<BandejaNotificacionesPage> createState() =>
      _BandejaNotificacionesPageState();
}

class _BandejaNotificacionesPageState extends State<BandejaNotificacionesPage> {
  late Future<List<Notificacion>> _lista = widget.servicio.listar();

  void _recargar() => setState(() => _lista = widget.servicio.listar());

  Future<void> _tocar(Notificacion n) async {
    await widget.servicio.marcarLeida(n.id);
    widget.alAbrir?.call(n);
    if (mounted) _recargar();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Notificaciones'),
      actions: [
        IconButton(
          tooltip: 'Marcar todas como leídas',
          icon: const Icon(Icons.done_all),
          onPressed: () async {
            await widget.servicio.marcarTodasLeidas();
            if (mounted) _recargar();
          },
        ),
        if (widget.tipos != null)
          IconButton(
            tooltip: 'Preferencias',
            icon: const Icon(Icons.tune),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => PreferenciasNotificacionesPage(
                  servicio: widget.servicio,
                  tipos: widget.tipos!,
                ),
              ),
            ),
          ),
      ],
    ),
    body: FutureBuilder<List<Notificacion>>(
      future: _lista,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(
            child: TextButton(
              onPressed: _recargar,
              child: const Text('No se pudieron cargar. Reintentar'),
            ),
          );
        }
        final l = snap.data ?? const [];
        if (l.isEmpty) {
          return const Center(child: Text('No tienes notificaciones.'));
        }
        return RefreshIndicator(
          onRefresh: () async => _recargar(),
          child: ListView.separated(
            itemCount: l.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final n = l[i];
              return ListTile(
                leading: Icon(
                  n.leida ? Icons.notifications_none : Icons.notifications_active,
                  color: n.leida ? null : Theme.of(context).colorScheme.primary,
                ),
                title: Text(
                  n.titulo,
                  style: n.leida
                      ? null
                      : const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: n.cuerpo.isEmpty ? null : Text(n.cuerpo),
                trailing: Text(
                  _hace(n.creada),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                onTap: () => _tocar(n),
              );
            },
          ),
        );
      },
    ),
  );
}

/// Activar o desactivar cada tipo de aviso en la app y por email.
class PreferenciasNotificacionesPage extends StatefulWidget {
  const PreferenciasNotificacionesPage({
    super.key,
    required this.servicio,
    required this.tipos,
  });

  final NotificacionesServicio servicio;

  /// `tipo` (como lo emite el backend) → etiqueta para el usuario.
  final Map<String, String> tipos;

  @override
  State<PreferenciasNotificacionesPage> createState() =>
      _PreferenciasNotificacionesPageState();
}

class _PreferenciasNotificacionesPageState
    extends State<PreferenciasNotificacionesPage> {
  Map<String, PreferenciaNotificacion>? _prefs;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    widget.servicio.repo.preferencias().then(
      (p) {
        if (mounted) setState(() => _prefs = p);
      },
      onError: (_) {
        if (mounted) setState(() => _error = true);
      },
    );
  }

  Future<void> _cambiar(String tipo, PreferenciaNotificacion nueva) async {
    final antes = _prefs![tipo] ?? const PreferenciaNotificacion();
    setState(() => _prefs = {..._prefs!, tipo: nueva});
    try {
      await widget.servicio.repo.guardarPreferencia(tipo, nueva);
    } catch (_) {
      if (!mounted) return;
      setState(() => _prefs = {..._prefs!, tipo: antes});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo guardar el cambio.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Preferencias de avisos')),
    body: _error
        ? const Center(child: Text('No se pudieron cargar las preferencias.'))
        : _prefs == null
        ? const Center(child: CircularProgressIndicator())
        : ListView(
            children: [
              for (final e in widget.tipos.entries) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Text(
                    e.value,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                SwitchListTile(
                  title: const Text('En la app'),
                  value: (_prefs![e.key] ?? const PreferenciaNotificacion()).app,
                  onChanged: (v) => _cambiar(
                    e.key,
                    (_prefs![e.key] ?? const PreferenciaNotificacion()).copiar(
                      app: v,
                    ),
                  ),
                ),
                SwitchListTile(
                  title: const Text('Por email'),
                  value:
                      (_prefs![e.key] ?? const PreferenciaNotificacion()).email,
                  onChanged: (v) => _cambiar(
                    e.key,
                    (_prefs![e.key] ?? const PreferenciaNotificacion()).copiar(
                      email: v,
                    ),
                  ),
                ),
              ],
            ],
          ),
  );
}

String _hace(DateTime t) {
  final d = DateTime.now().difference(t);
  if (d.inMinutes < 1) return 'ahora';
  if (d.inMinutes < 60) return 'hace ${d.inMinutes} min';
  if (d.inHours < 24) return 'hace ${d.inHours} h';
  if (d.inDays < 7) return 'hace ${d.inDays} d';
  return '${t.day.toString().padLeft(2, '0')}/${t.month.toString().padLeft(2, '0')}';
}
