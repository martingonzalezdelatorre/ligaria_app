import 'package:flutter/material.dart';
import 'package:ligaria_ui/ligaria_ui.dart';
import '../../auth/auth_repositorio.dart';
import '../../auth/auth_widgets.dart' show validarPassword;
import '../ligas/ligas_repositorio.dart';
import 'ajustes_repositorio.dart';
import 'localidades_espana.dart';

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
      avisar(context, 'Datos guardados');
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
      if (mounted) avisar(context, 'Contraseña actualizada');
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
      appBar: AppBar(title: const Text('Ajustes de cuenta')),
      body: FondoBlobs(
        child: SafeArea(
          child: ContenidoCentrado(
            maxAncho: 640,
            child: p == null
                ? FutureBuilder<PerfilUsuario>(
                    future: _carga,
                    builder: (context, snap) => Center(
                      child: snap.hasError
                          ? Text(
                              'No se pudieron cargar los ajustes.',
                              style: t.bodyMedium?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            )
                          : const CircularProgressIndicator(),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
                    children: [
                      Text('Tus datos', style: t.titleLarge),
                      const SizedBox(height: 12),
                      Form(
                        key: _form,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _nombre,
                              textCapitalization: TextCapitalization.words,
                              decoration: const InputDecoration(
                                labelText: 'Nombre',
                                prefixIcon: Icon(Icons.person_outline),
                              ),
                              validator: (v) => (v ?? '').trim().isEmpty
                                  ? 'Introduce tu nombre'
                                  : null,
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _apellidos,
                              textCapitalization: TextCapitalization.words,
                              decoration: const InputDecoration(
                                labelText: 'Apellidos',
                                prefixIcon: Icon(Icons.badge_outlined),
                              ),
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              initialValue: p.email,
                              enabled: false,
                              decoration: const InputDecoration(
                                labelText: 'Email (tu usuario)',
                                prefixIcon: Icon(Icons.alternate_email),
                                suffixIcon: Icon(Icons.lock_outline),
                                helperText: 'No se puede modificar.',
                              ),
                            ),
                            const SizedBox(height: 14),
                            Autocomplete<String>(
                              key: ValueKey('provincia-${_perfil != null}'),
                              initialValue: TextEditingValue(
                                text: _provincia ?? '',
                              ),
                              optionsBuilder: (v) {
                                final q = _sinTildes(v.text);
                                return provincias.where(
                                  (pr) => _sinTildes(pr).contains(q),
                                );
                              },
                              onSelected: _elegirProvincia,
                              fieldViewBuilder: (context, c, foco, _) =>
                                  TextFormField(
                                    controller: c,
                                    focusNode: foco,
                                    textCapitalization:
                                        TextCapitalization.words,
                                    decoration: const InputDecoration(
                                      labelText: 'Provincia',
                                      hintText: 'Escribe para buscar',
                                      prefixIcon: Icon(Icons.map_outlined),
                                    ),
                                    // Solo vale una provincia de la lista.
                                    onChanged: (t) {
                                      final exacta = provincias
                                          .where(
                                            (pr) =>
                                                _sinTildes(pr) ==
                                                _sinTildes(t.trim()),
                                          )
                                          .firstOrNull;
                                      if (exacta != _provincia) {
                                        _elegirProvincia(exacta);
                                      }
                                    },
                                    validator: (t) =>
                                        (t == null ||
                                            t.trim().isEmpty ||
                                            _provincia != null)
                                        ? null
                                        : 'Elige una provincia de la lista.',
                                  ),
                            ),
                            const SizedBox(height: 14),
                            // Sugerencias de la provincia elegida; también admite texto libre.
                            Autocomplete<String>(
                              key: ValueKey(
                                'localidad-${_perfil != null}-$_provincia',
                              ),
                              initialValue: TextEditingValue(
                                text: _localidad.text,
                              ),
                              optionsBuilder: (v) {
                                final q = _sinTildes(v.text);
                                return (localidadesPorProvincia[_provincia] ??
                                        const <String>[])
                                    .where((l) => _sinTildes(l).contains(q));
                              },
                              onSelected: (v) => _localidad.text = v,
                              fieldViewBuilder: (context, c, foco, _) =>
                                  TextFormField(
                                    controller: c,
                                    focusNode: foco,
                                    enabled: _provincia != null,
                                    textCapitalization:
                                        TextCapitalization.words,
                                    onChanged: (t) => _localidad.text = t,
                                    decoration: InputDecoration(
                                      labelText: 'Localidad',
                                      hintText: _provincia == null
                                          ? 'Elige primero la provincia'
                                          : 'Escribe para buscar',
                                      prefixIcon: const Icon(
                                        Icons.location_city_outlined,
                                      ),
                                    ),
                                  ),
                            ),
                            const SizedBox(height: 18),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                onPressed: _guardando ? null : _guardar,
                                icon: const Icon(Icons.save_outlined),
                                label: const Text('Guardar datos'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (widget.auth != null) ...[
                        const SizedBox(height: 28),
                        Text('Seguridad', style: t.titleLarge),
                        const SizedBox(height: 12),
                        Card(
                          margin: EdgeInsets.zero,
                          child: ListTile(
                            leading: const Icon(Icons.lock_reset_outlined),
                            title: const Text('Cambiar contraseña'),
                            subtitle: const Text(
                              'Elige una contraseña nueva para tu cuenta.',
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: _cambiarPassword,
                          ),
                        ),
                      ],
                      const SizedBox(height: 28),
                      Text('Rankings', style: t.titleLarge),
                      const SizedBox(height: 4),
                      Text(
                        'Elige en qué clasificaciones apareces con tu nombre. '
                        'En el ranking de tus grupos siempre te ven.',
                        style: t.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Card(
                        margin: EdgeInsets.zero,
                        child: Column(
                          children: [
                            _interruptor(
                              pref: Preferencia.rankingGlobal,
                              icono: Icons.public,
                              titulo: 'Ranking global',
                              detalle: 'Toda la app.',
                            ),
                            _interruptor(
                              pref: Preferencia.rankingProvincia,
                              icono: Icons.map_outlined,
                              titulo: 'Ranking de mi provincia',
                              detalle: p.tieneProvincia
                                  ? 'Jugadores de ${p.provincia}.'
                                  : 'Indica tu provincia y guarda los datos.',
                              habilitado: p.tieneProvincia,
                            ),
                            _interruptor(
                              pref: Preferencia.rankingLocalidad,
                              icono: Icons.location_city_outlined,
                              titulo: 'Ranking de mi localidad',
                              detalle: p.tieneLocalidad
                                  ? 'Jugadores de ${p.localidad}.'
                                  : 'Indica tu localidad y guarda los datos.',
                              habilitado: p.tieneLocalidad,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      Text('Notificaciones', style: t.titleLarge),
                      const SizedBox(height: 12),
                      Card(
                        margin: EdgeInsets.zero,
                        child: _interruptor(
                          pref: Preferencia.notificaciones,
                          icono: Icons.notifications_outlined,
                          titulo: 'Recibir notificaciones',
                          detalle:
                              'Avisos en la app y por email (resultados por confirmar, pedidos…).',
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
    title: const Text('Cambiar contraseña'),
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
                labelText: 'Contraseña nueva',
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
              decoration: const InputDecoration(
                labelText: 'Repite la contraseña',
              ),
              validator: (v) =>
                  v == _nueva.text ? null : 'Las contraseñas no coinciden',
            ),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancelar'),
      ),
      FilledButton(
        onPressed: () {
          if (_form.currentState!.validate()) {
            Navigator.pop(context, _nueva.text);
          }
        },
        child: const Text('Cambiar'),
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
