import 'package:flutter/material.dart';
import 'package:ligaria_ui/ligaria_ui.dart';
import '../../auth/auth_repositorio.dart';
import '../../auth/auth_widgets.dart' show validarPassword;
import '../ligas/ligas_repositorio.dart';
import 'ajustes_repositorio.dart';
import 'localidades_espana.dart';
import '../../../core/config.dart';
import '../../../core/enlaces_legales.dart';
import '../../../core/idioma.dart';

/// Ajustes de la cuenta: datos personales, contraseña, rankings y notificaciones.
class AjustesPage extends StatefulWidget {
  const AjustesPage({super.key, this.repo, this.auth});
  final AjustesRepositorio? repo;

  /// Necesario para cambiar la contraseña; sin él no se muestra esa opción.
  final AuthRepositorio? auth;
  @override
  State<AjustesPage> createState() => _AjustesPageState();
}

class _AjustesPageState extends State<AjustesPage> {
  late final AjustesRepositorio _repo =
      widget.repo ?? AjustesRepositorio.instancia;
  late final Future<PerfilUsuario> _carga = _repo.perfil();
  PerfilUsuario? _perfil;

  final _form = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _apellidos = TextEditingController();
  final _localidad = TextEditingController();
  String? _provincia;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _carga
        .then((p) {
          if (!mounted) return;
          setState(() {
            _perfil = p;
            _nombre.text = p.nombre;
            _apellidos.text = p.apellidos;
            _localidad.text = p.localidad;
            _provincia = p.tieneProvincia ? p.provincia : null;
          });
        })
        .catchError((_) {});
  }

  /// Al cambiar de provincia la localidad anterior deja de valer.
  void _elegirProvincia(String? v) => setState(() {
    _provincia = v;
    _localidad.clear();
  });

  @override
  void dispose() {
    _nombre.dispose();
    _apellidos.dispose();
    _localidad.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _guardando = true);
    try {
      await _repo.guardarDatos(
        nombre: _nombre.text,
        apellidos: _apellidos.text,
        localidad: _localidad.text,
        provincia: _provincia ?? '',
      );
      if (!mounted) return;
      setState(() {
        _perfil = _perfil!.copiaCon(
          nombre: _nombre.text.trim(),
          apellidos: _apellidos.text.trim(),
          localidad: _localidad.text.trim(),
          provincia: _provincia ?? '',
        );
      });
      avisar(context, context.l10n.datosGuardados);
    } on LigasException catch (e) {
      if (mounted) avisar(context, e.mensaje);
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  Future<void> _preferencia(Preferencia p, bool valor) async {
    final anterior = _perfil!;
    setState(() => _perfil = anterior.copiaCon(preferencia: p, valor: valor));
    try {
      await _repo.establecer(p, valor);
    } on LigasException catch (e) {
      if (!mounted) return;
      setState(() => _perfil = anterior); // se deshace si no se pudo guardar
      avisar(context, e.mensaje);
    }
  }

  Future<void> _cambiarPassword() async {
    final nueva = await showDialog<String>(
      context: context,
      builder: (_) => const _DialogoPassword(),
    );
    if (nueva == null || !mounted) return;
    try {
      await widget.auth!.cambiarPassword(nueva);
      if (mounted) avisar(context, context.l10n.contrasenaActualizada);
    } on AuthException catch (e) {
      if (mounted) avisar(context, e.mensaje);
    }
  }

  Widget _interruptor({
    required Preferencia pref,
    required IconData icono,
    required String titulo,
    required String detalle,
    bool habilitado = true,
  }) => SwitchListTile(
    value: _perfil!.valorDe(pref),
    onChanged: habilitado ? (v) => _preferencia(pref, v) : null,
    secondary: Icon(icono),
    title: Text(titulo),
    subtitle: Text(detalle),
  );

  /// Secciones de la cuenta: se muestran una debajo de otra en móvil y en pestañas en pantallas anchas.
  List<(String, List<Widget>)> _secciones(
    BuildContext context,
    PerfilUsuario p,
    List<String> provincias,
  ) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return [
      (
        context.l10n.tusDatos,
        [
          Text(context.l10n.tusDatos, style: t.titleLarge),
          const SizedBox(height: 12),
          Form(
            key: _form,
            child: Column(
              children: [
                TextFormField(
                  controller: _nombre,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: context.l10n.nombre,
                    prefixIcon: const Icon(Icons.person_outline),
                  ),
                  validator: (v) => (v ?? '').trim().isEmpty
                      ? context.l10n.introTuNombre
                      : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _apellidos,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: context.l10n.apellidos,
                    prefixIcon: const Icon(Icons.badge_outlined),
                  ),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  initialValue: p.email,
                  enabled: false,
                  decoration: InputDecoration(
                    labelText: context.l10n.emailUsuario,
                    prefixIcon: const Icon(Icons.alternate_email),
                    suffixIcon: const Icon(Icons.lock_outline),
                    helperText: context.l10n.noSePuedeModificar,
                  ),
                ),
                const SizedBox(height: 14),
                Autocomplete<String>(
                  key: ValueKey('provincia-${_perfil != null}'),
                  initialValue: TextEditingValue(text: _provincia ?? ''),
                  optionsBuilder: (v) {
                    final q = _sinTildes(v.text);
                    return provincias.where((pr) => _sinTildes(pr).contains(q));
                  },
                  onSelected: _elegirProvincia,
                  fieldViewBuilder: (context, c, foco, _) => TextFormField(
                    controller: c,
                    focusNode: foco,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      labelText: context.l10n.provincia,
                      hintText: context.l10n.escribeParaBuscar,
                      prefixIcon: const Icon(Icons.map_outlined),
                    ),
                    // Solo vale una provincia de la lista.
                    onChanged: (t) {
                      final exacta = provincias
                          .where((pr) => _sinTildes(pr) == _sinTildes(t.trim()))
                          .firstOrNull;
                      if (exacta != _provincia) {
                        _elegirProvincia(exacta);
                      }
                    },
                    validator: (t) =>
                        (t == null || t.trim().isEmpty || _provincia != null)
                        ? null
                        : context.l10n.eligeProvinciaLista,
                  ),
                ),
                const SizedBox(height: 14),
                // Sugerencias de la provincia elegida; también admite texto libre.
                Autocomplete<String>(
                  key: ValueKey('localidad-${_perfil != null}-$_provincia'),
                  initialValue: TextEditingValue(text: _localidad.text),
                  optionsBuilder: (v) {
                    final q = _sinTildes(v.text);
                    return (localidadesPorProvincia[_provincia] ??
                            const <String>[])
                        .where((l) => _sinTildes(l).contains(q));
                  },
                  onSelected: (v) => _localidad.text = v,
                  fieldViewBuilder: (context, c, foco, _) => TextFormField(
                    controller: c,
                    focusNode: foco,
                    enabled: _provincia != null,
                    textCapitalization: TextCapitalization.words,
                    onChanged: (t) => _localidad.text = t,
                    decoration: InputDecoration(
                      labelText: context.l10n.localidad,
                      hintText: _provincia == null
                          ? context.l10n.eligePrimeroProvincia
                          : context.l10n.escribeParaBuscar,
                      prefixIcon: const Icon(Icons.location_city_outlined),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _guardando ? null : _guardar,
                    icon: const Icon(Icons.save_outlined),
                    label: Text(context.l10n.guardarDatos),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      if (widget.auth != null)
        (
          context.l10n.seguridad,
          [
            Text(context.l10n.seguridad, style: t.titleLarge),
            const SizedBox(height: 12),
            Card(
              margin: EdgeInsets.zero,
              child: ListTile(
                leading: const Icon(Icons.lock_reset_outlined),
                title: Text(context.l10n.cambiarContrasena),
                subtitle: Text(context.l10n.eligeContrasenaNueva),
                trailing: const Icon(Icons.chevron_right),
                onTap: _cambiarPassword,
              ),
            ),
          ],
        ),
      (
        context.l10n.rankings,
        [
          Text(context.l10n.rankings, style: t.titleLarge),
          const SizedBox(height: 4),
          Text(
            context.l10n.rankingsAyuda,
            style: t.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          Card(
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                _interruptor(
                  pref: Preferencia.rankingGlobal,
                  icono: Icons.public,
                  titulo: context.l10n.rankingGlobal,
                  detalle: context.l10n.todaApp,
                ),
                _interruptor(
                  pref: Preferencia.rankingProvincia,
                  icono: Icons.map_outlined,
                  titulo: context.l10n.rankingMiProvincia,
                  detalle: p.tieneProvincia
                      ? context.l10n.jugadoresDe(p.provincia)
                      : context.l10n.indicaProvincia,
                  habilitado: p.tieneProvincia,
                ),
                _interruptor(
                  pref: Preferencia.rankingLocalidad,
                  icono: Icons.location_city_outlined,
                  titulo: context.l10n.rankingMiLocalidad,
                  detalle: p.tieneLocalidad
                      ? context.l10n.jugadoresDe(p.localidad)
                      : context.l10n.indicaLocalidad,
                  habilitado: p.tieneLocalidad,
                ),
              ],
            ),
          ),
        ],
      ),
      (
        context.l10n.notificaciones,
        [
          Text(context.l10n.notificaciones, style: t.titleLarge),
          const SizedBox(height: 12),
          Card(
            margin: EdgeInsets.zero,
            child: _interruptor(
              pref: Preferencia.notificaciones,
              icono: Icons.notifications_outlined,
              titulo: context.l10n.recibirNotificaciones,
              detalle: context.l10n.notificacionesDetalle,
            ),
          ),
        ],
      ),
      (
        context.l10n.idiomaApp,
        [
          Text(context.l10n.idiomaApp, style: t.titleLarge),
          const SizedBox(height: 12),
          Card(
            margin: EdgeInsets.zero,
            child: ListTile(
              leading: const Icon(Icons.language),
              title: Text(context.l10n.idioma),
              trailing: const SelectorIdioma(),
            ),
          ),
        ],
      ),
      (
        context.l10n.legal,
        [
          Text(context.l10n.legal, style: t.titleLarge),
          const SizedBox(height: 12),
          Card(
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: Text(context.l10n.politicaPrivacidad),
                  trailing: const Icon(Icons.open_in_new, size: 18),
                  onTap: () =>
                      abrirEnlaceLegal(context, AppConfig.urlPrivacidad),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: Text(context.l10n.terminosUso),
                  trailing: const Icon(Icons.open_in_new, size: 18),
                  onTap: () => abrirEnlaceLegal(context, AppConfig.urlTerminos),
                ),
              ],
            ),
          ),
        ],
      ),
    ];
  }

  /// Móvil: una sola columna con todas las secciones. Tablet, web y escritorio: pestañas.
  Widget _cuerpo(BuildContext context, List<(String, List<Widget>)> secs) {
    if (MediaQuery.sizeOf(context).width < 700) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
        children: [
          for (var i = 0; i < secs.length; i++) ...[
            if (i > 0) const SizedBox(height: 28),
            ...secs[i].$2,
          ],
        ],
      );
    }
    return DefaultTabController(
      key: ValueKey(secs.length),
      length: secs.length,
      child: Column(
        children: [
          TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [for (final (titulo, _) in secs) Tab(text: titulo)],
          ),
          Expanded(
            child: TabBarView(
              children: [
                for (final (_, hijos) in secs)
                  ListView(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
                    children: hijos,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final p = _perfil;
    final provincias = [
      ...provinciasEspana,
      if (_provincia != null && !provinciasEspana.contains(_provincia))
        _provincia!,
    ];
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: Text(context.l10n.ajustesCuenta)),
      body: FondoBlobs(
        child: SafeArea(
          child: ContenidoCentrado(
            maxAncho: 900,
            child: p == null
                ? FutureBuilder<PerfilUsuario>(
                    future: _carga,
                    builder: (context, snap) => Center(
                      child: snap.hasError
                          ? Text(
                              context.l10n.errCargarAjustes,
                              style: t.bodyMedium?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            )
                          : const CircularProgressIndicator(),
                    ),
                  )
                : _cuerpo(context, _secciones(context, p, provincias)),
          ),
        ),
      ),
    );
  }
}

class _DialogoPassword extends StatefulWidget {
  const _DialogoPassword();
  @override
  State<_DialogoPassword> createState() => _DialogoPasswordState();
}

class _DialogoPasswordState extends State<_DialogoPassword> {
  final _form = GlobalKey<FormState>();
  final _nueva = TextEditingController();
  final _repetir = TextEditingController();
  bool _ver = false;

  @override
  void dispose() {
    _nueva.dispose();
    _repetir.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(context.l10n.cambiarContrasena),
    content: SizedBox(
      width: 420,
      child: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nueva,
              obscureText: !_ver,
              autofocus: true,
              decoration: InputDecoration(
                labelText: context.l10n.contrasenaNueva,
                suffixIcon: IconButton(
                  icon: Icon(_ver ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _ver = !_ver),
                ),
              ),
              validator: validarPassword,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _repetir,
              obscureText: !_ver,
              decoration: InputDecoration(
                labelText: context.l10n.repiteContrasena,
              ),
              validator: (v) =>
                  v == _nueva.text ? null : context.l10n.contrasenasNoCoinciden,
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
        onPressed: () {
          if (_form.currentState!.validate()) {
            Navigator.pop(context, _nueva.text);
          }
        },
        child: Text(context.l10n.cambiar),
      ),
    ],
  );
}

String _sinTildes(String s) {
  const de = 'áàäâéèëêíìïîóòöôúùüûñÁÉÍÓÚÑ';
  const a = 'aaaaeeeeiiiioooouuuunAEIOUN';
  var r = s.toLowerCase();
  for (var i = 0; i < de.length; i++) {
    r = r.replaceAll(de[i].toLowerCase(), a[i].toLowerCase());
  }
  return r;
}
