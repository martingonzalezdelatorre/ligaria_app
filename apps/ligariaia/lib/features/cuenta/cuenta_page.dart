import 'package:flutter/material.dart';
import 'package:ligaria_ui/ligaria_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/auth.dart';
import '../../core/idioma.dart';
import '../../data/cuenta_repository.dart';

final _perfilProvider = FutureProvider.autoDispose<PerfilCuenta>(
  (ref) => ref.watch(cuentaRepositoryProvider).perfil(),
);
final _orgProvider = FutureProvider.autoDispose
    .family<DatosOrganizacion, String>(
      (ref, id) => ref.watch(cuentaRepositoryProvider).organizacion(id),
    );

/// La organización que el usuario administra (escuela, ayuntamiento u organizador): la que se edita aquí.
Pertenencia? _orgAdministrada(List<Pertenencia> l) {
  for (final p in l) {
    if (p.escuelaId != null &&
        !p.coorganizador &&
        (p.rol == Rol.adminEscuela || p.rol == Rol.organizadorLiga))
      return p;
  }
  return null;
}

String _tipoOrg(String? t) => switch (t) {
  'ESCUELA' => 'escuela',
  'AYUNTAMIENTO' => 'ayuntamiento',
  _ => 'organización',
};

String _datosOrg(AppL10n l, String tipo) => switch (tipo) {
  'escuela' => l.datosOrgEscuela,
  'ayuntamiento' => l.datosOrgAyuntamiento,
  _ => l.datosOrgOrganizacion,
};

String _nombreOrg(AppL10n l, String tipo) => switch (tipo) {
  'escuela' => l.nombreEscuela,
  'ayuntamiento' => l.nombreAyuntamiento,
  _ => l.nombreOrganizacion,
};

class CuentaPage extends ConsumerStatefulWidget {
  const CuentaPage({super.key});
  @override
  ConsumerState<CuentaPage> createState() => _CuentaPageState();
}

class _CuentaPageState extends ConsumerState<CuentaPage> {
  final _form = GlobalKey<FormState>();
  final _nueva = TextEditingController();
  String? _mensaje;

  @override
  void dispose() {
    _nueva.dispose();
    super.dispose();
  }

  Future<void> _cambiar() async {
    if (!_form.currentState!.validate()) return;
    try {
      await ref.read(authRepositoryProvider).cambiarPassword(_nueva.text);
      _nueva.clear();
      setState(() => _mensaje = context.l10n.contrasenaActualizada);
    } catch (_) {
      setState(() => _mensaje = context.l10n.errCambiarPass);
    }
  }

  Widget _seccion(
    BuildContext context,
    IconData icono,
    String titulo,
    Widget hijo,
  ) {
    final tema = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(icono, color: tema.colorScheme.primary, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(titulo, style: tema.textTheme.titleMedium),
                ),
              ],
            ),
            const SizedBox(height: 14),
            hijo,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(authRepositoryProvider);
    final tema = Theme.of(context);
    final cs = tema.colorScheme;
    final email = repo.email ?? '';
    final nombre = ref.watch(_perfilProvider).value?.nombre ?? '';
    final pert = _orgAdministrada(
      ref.watch(pertenenciasProvider).value ?? const [],
    );

    final cabecera = Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              acentoDe(context).withValues(alpha: .16),
              acentoSuaveDe(context).withValues(alpha: .04),
            ],
          ),
        ),
        child: Row(
          children: [
            AvatarEquipo(
              nombre.isNotEmpty ? nombre : (email.isEmpty ? '?' : email),
              tam: 56,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pert == null
                        ? context.l10n.tuCuenta
                        : '${etiquetaRol(pert.rol)} · ${pert.escuela ?? ''}',
                    style: tema.textTheme.labelMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    nombre.isNotEmpty ? nombre : email,
                    style: tema.textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (nombre.isNotEmpty)
                    Text(
                      email,
                      style: tema.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    final password = _seccion(
      context,
      Icons.lock_outline,
      context.l10n.cambiarContrasena,
      Form(
        key: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _nueva,
              obscureText: true,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _cambiar(),
              decoration: decoracionCampo(
                context.l10n.nuevaContrasena,
                Icons.password,
                ayuda: context.l10n.alMenos8,
              ),
              validator: (v) =>
                  (v == null || v.length < 8) ? context.l10n.min8 : null,
            ),
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: _cambiar,
                child: Text(context.l10n.actualizar),
              ),
            ),
            if (_mensaje != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(_mensaje!),
              ),
          ],
        ),
      ),
    );

    final salir = OutlinedButton.icon(
      onPressed: () => ref.read(authRepositoryProvider).cerrarSesion(),
      icon: const Icon(Icons.logout),
      label: Text(context.l10n.cerrarSesion),
    );

    final secciones = <(String, Widget)>[
      (
        context.l10n.datosAdministrador,
        _seccion(
          context,
          Icons.person_outline,
          context.l10n.datosAdministrador,
          ref
              .watch(_perfilProvider)
              .when(
                data: (p) => _FormPerfil(inicial: p, email: email),
                loading: () => const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: Cargando()),
                ),
                error: (_, _) => Text(context.l10n.errCargarDatosTuyos),
              ),
        ),
      ),
      if (pert != null)
        (
          _datosOrg(context.l10n, _tipoOrg(pert.orgTipo)),
          _seccion(
            context,
            Icons.business_outlined,
            _datosOrg(context.l10n, _tipoOrg(pert.orgTipo)),
            ref
                .watch(_orgProvider(pert.escuelaId!))
                .when(
                  data: (d) =>
                      _FormOrg(inicial: d, tipo: _tipoOrg(pert.orgTipo)),
                  loading: () => const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: Cargando()),
                  ),
                  error: (_, _) => Text(context.l10n.errCargarDatos),
                ),
          ),
        ),
      (
        context.l10n.idioma,
        _seccion(
          context,
          Icons.language,
          context.l10n.idioma,
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final (l, n) in idiomasApp)
                  ChoiceChip(
                    label: Text(n),
                    selected: ref.watch(idiomaProvider) == l,
                    onSelected: (_) => ref.read(idiomaProvider.notifier).set(l),
                  ),
              ],
            ),
          ),
        ),
      ),
      (context.l10n.cambiarContrasena, password),
    ];
    final ancho = MediaQuery.sizeOf(context).width >= 700;

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.miCuenta)),
      body: ContenidoCentrado(
        maxAncho: 760,
        child: ancho
            ? DefaultTabController(
                key: ValueKey(secciones.length),
                length: secciones.length,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                      child: cabecera,
                    ),
                    TabBar(
                      isScrollable: true,
                      tabAlignment: TabAlignment.start,
                      tabs: [for (final (t, _) in secciones) Tab(text: t)],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          for (final (_, w) in secciones)
                            _Mantener(
                              child: ListView(
                                padding: const EdgeInsets.fromLTRB(
                                  12,
                                  16,
                                  12,
                                  16,
                                ),
                                children: [w],
                              ),
                            ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                      child: SizedBox(width: double.infinity, child: salir),
                    ),
                  ],
                ),
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 32),
                children: [
                  cabecera,
                  for (final (_, w) in secciones) w,
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: salir,
                  ),
                ],
              ),
      ),
    );
  }
}

/// Mantiene vivo el estado de cada pestaña (lo escrito sin guardar no se pierde al cambiar).
class _Mantener extends StatefulWidget {
  const _Mantener({required this.child});
  final Widget child;
  @override
  State<_Mantener> createState() => _MantenerState();
}

class _MantenerState extends State<_Mantener>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}

String _errorGuardar(Object e) {
  final l = l10nActual;
  final t = e.toString().toLowerCase();
  if (t.contains('ya existe otra entidad')) return l.errEntidadExiste;
  if (t.contains('sin permiso')) return l.errPermisoEditar;
  return l.errGuardarCambios;
}

/// Nombre completo y teléfono del administrador (el correo no se edita aquí).
class _FormPerfil extends ConsumerStatefulWidget {
  const _FormPerfil({required this.inicial, required this.email});
  final PerfilCuenta inicial;
  final String email;
  @override
  ConsumerState<_FormPerfil> createState() => _FormPerfilState();
}

class _FormPerfilState extends ConsumerState<_FormPerfil> {
  final _form = GlobalKey<FormState>();
  late final _nombre = TextEditingController(text: widget.inicial.nombre);
  late final _telefono = TextEditingController(text: widget.inicial.telefono);
  bool _guardando = false;

  @override
  void dispose() {
    _nombre.dispose();
    _telefono.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _guardando = true);
    try {
      await ref
          .read(cuentaRepositoryProvider)
          .guardarPerfil(nombre: _nombre.text, telefono: _telefono.text);
      ref.invalidate(_perfilProvider);
      if (mounted) avisar(context, context.l10n.datosGuardados);
    } catch (e) {
      if (mounted) avisar(context, _errorGuardar(e));
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) => Form(
    key: _form,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          key: const Key('cuenta-nombre'),
          controller: _nombre,
          textCapitalization: TextCapitalization.words,
          autofillHints: const [AutofillHints.name],
          decoration: decoracionCampo(
            context.l10n.nombreCompleto,
            Icons.badge_outlined,
          ),
          validator: (v) => (v == null || v.trim().isEmpty)
              ? context.l10n.introduceTuNombre
              : null,
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _telefono,
          keyboardType: TextInputType.phone,
          autofillHints: const [AutofillHints.telephoneNumber],
          decoration: decoracionCampo(
            context.l10n.telefono,
            Icons.phone_outlined,
          ),
        ),
        const SizedBox(height: 14),
        TextFormField(
          initialValue: widget.email,
          enabled: false,
          decoration: decoracionCampo(
            context.l10n.correoElectronico,
            Icons.mail_outline_rounded,
            ayuda: context.l10n.esTuUsuario,
          ),
        ),
        const SizedBox(height: 14),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton(
            onPressed: _guardando ? null : _guardar,
            child: Text(context.l10n.guardar),
          ),
        ),
      ],
    ),
  );
}

/// Datos de la escuela, ayuntamiento u organización: nombre, CIF, dirección y contacto.
class _FormOrg extends ConsumerStatefulWidget {
  const _FormOrg({required this.inicial, required this.tipo});
  final DatosOrganizacion inicial;
  final String tipo;
  @override
  ConsumerState<_FormOrg> createState() => _FormOrgState();
}

class _FormOrgState extends ConsumerState<_FormOrg> {
  final _form = GlobalKey<FormState>();
  late final _c = {
    'nombre': TextEditingController(text: widget.inicial.nombre),
    'cif': TextEditingController(text: widget.inicial.cif),
    'ciudad': TextEditingController(text: widget.inicial.ciudad),
    'direccion': TextEditingController(text: widget.inicial.direccion),
    'cp': TextEditingController(text: widget.inicial.codigoPostal),
    'provincia': TextEditingController(text: widget.inicial.provincia),
    'telefono': TextEditingController(text: widget.inicial.telefono),
    'email': TextEditingController(text: widget.inicial.emailContacto),
    'web': TextEditingController(text: widget.inicial.web),
  };
  bool _guardando = false;

  @override
  void dispose() {
    for (final c in _c.values) {
      c.dispose();
    }
    super.dispose();
  }

  String _v(String k) => _c[k]!.text.trim();

  Future<void> _guardar() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _guardando = true);
    try {
      await ref
          .read(cuentaRepositoryProvider)
          .guardarOrganizacion(
            DatosOrganizacion(
              id: widget.inicial.id,
              nombre: _v('nombre'),
              cif: _v('cif'),
              ciudad: _v('ciudad'),
              direccion: _v('direccion'),
              codigoPostal: _v('cp'),
              provincia: _v('provincia'),
              telefono: _v('telefono'),
              emailContacto: _v('email'),
              web: _v('web'),
            ),
          );
      ref.invalidate(_orgProvider(widget.inicial.id));
      ref.invalidate(
        pertenenciasProvider,
      ); // el nombre se muestra en el menú y la cabecera
      if (mounted) avisar(context, context.l10n.datosGuardados);
    } catch (e) {
      if (mounted) avisar(context, _errorGuardar(e));
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  Widget _campo(
    String k,
    String etiqueta,
    IconData icono, {
    TextInputType? teclado,
    TextCapitalization cap = TextCapitalization.none,
    String? Function(String?)? validar,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: TextFormField(
      key: Key('org-$k'),
      controller: _c[k],
      keyboardType: teclado,
      textCapitalization: cap,
      decoration: decoracionCampo(etiqueta, icono),
      validator: validar,
    ),
  );

  @override
  Widget build(BuildContext context) => Form(
    key: _form,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _campo(
          'nombre',
          _nombreOrg(context.l10n, widget.tipo),
          Icons.school_outlined,
          cap: TextCapitalization.words,
          validar: (v) => (v == null || v.trim().isEmpty)
              ? context.l10n.introduceNombre
              : null,
        ),
        _campo(
          'cif',
          context.l10n.cifNif,
          Icons.assignment_ind_outlined,
          cap: TextCapitalization.characters,
        ),
        _campo(
          'direccion',
          context.l10n.direccion,
          Icons.place_outlined,
          cap: TextCapitalization.words,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: _campo(
                'ciudad',
                context.l10n.ciudad,
                Icons.location_city_outlined,
                cap: TextCapitalization.words,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _campo(
                'cp',
                context.l10n.cpostal,
                Icons.markunread_mailbox_outlined,
                teclado: TextInputType.number,
              ),
            ),
          ],
        ),
        _campo(
          'provincia',
          context.l10n.provincia,
          Icons.map_outlined,
          cap: TextCapitalization.words,
        ),
        _campo(
          'telefono',
          context.l10n.telefonoContacto,
          Icons.phone_outlined,
          teclado: TextInputType.phone,
        ),
        _campo(
          'email',
          context.l10n.emailContacto,
          Icons.alternate_email_rounded,
          teclado: TextInputType.emailAddress,
          validar: (v) =>
              (v == null ||
                  v.trim().isEmpty ||
                  RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim()))
              ? null
              : context.l10n.emailValido,
        ),
        _campo(
          'web',
          context.l10n.web,
          Icons.language_rounded,
          teclado: TextInputType.url,
        ),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton(
            onPressed: _guardando ? null : _guardar,
            child: Text(context.l10n.guardar),
          ),
        ),
      ],
    ),
  );
}
