import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ligaria_ui/ligaria_ui.dart';
import '../../../core/invitacion.dart';
import '../amistosos/amistosos_repositorio.dart';
import '../amistosos/amistosos_seccion.dart';
import '../ligas/ligas_repositorio.dart';
import '../ligas/ligas_seccion.dart';
import 'grupos_repositorio.dart';
import '../../../core/idioma.dart';

/// Detalle de un grupo: código y mensaje de invitación, y lista de miembros.
class GrupoPage extends StatefulWidget {
  const GrupoPage({
    super.key,
    required this.grupo,
    required this.repo,
    required this.ligas,
    required this.amistosos,
  });
  final Grupo grupo;
  final GruposRepositorio repo;
  final LigasRepositorio ligas;
  final AmistososRepositorio amistosos;
  @override
  State<GrupoPage> createState() => _GrupoPageState();
}

class _GrupoPageState extends State<GrupoPage> {
  late String _codigo = widget.grupo.codigo;
  late Future<List<Miembro>> _miembros = widget.repo.miembros(widget.grupo.id);
  bool _regenerando = false;

  /// Pide el destinatario. Email: lo envía Supabase con su plantilla. WhatsApp: abre el chat con el mensaje.
  Future<void> _compartir({required bool porEmail}) async {
    final destino = await showDialog<String>(
      context: context,
      builder: (_) => _DialogoDestino(porEmail: porEmail),
    );
    if (destino == null || !mounted) return;
    final g = widget.grupo.nombre;
    if (porEmail) {
      try {
        await widget.repo.invitarPorEmail(
          grupoId: widget.grupo.id,
          email: destino,
          urlApp: Invitacion.base,
        );
        if (mounted) avisar(context, context.l10n.invitacionEnviadaA(destino));
      } on GruposException catch (e) {
        if (mounted) avisar(context, e.mensaje);
      }
      return;
    }
    final ok = await Invitacion.whatsapp(
      g,
      _codigo,
      destino,
      widget.repo.yo,
    ).catchError((_) => false);
    if (!ok && mounted) {
      _copiar(
        Invitacion.mensaje(g, _codigo, widget.repo.yo),
        context.l10n.noSePudoWhatsapp,
      );
    }
  }

  void _copiar(String texto, String aviso) {
    Clipboard.setData(ClipboardData(text: texto));
    avisar(context, aviso);
  }

  /// Añade a este grupo a un amigo invitado antes (que aún no esté en él).
  Future<void> _anadirAmigo() async {
    try {
      final enGrupo = {for (final m in await _miembros) m.id};
      final libres = (await widget.repo.contactos())
          .where((c) => !enGrupo.contains(c.id))
          .toList();
      if (!mounted) return;
      if (libres.isEmpty) {
        avisar(context, context.l10n.sinAmigosAnadir);
        return;
      }
      final elegido = await showDialog<Contacto>(
        context: context,
        builder: (c) => SimpleDialog(
          title: Text(c.l10n.anadirAmigoGrupo),
          children: [
            for (final a in libres)
              SimpleDialogOption(
                onPressed: () => Navigator.pop(c, a),
                child: Row(
                  children: [
                    AvatarEquipo(a.nombre, tam: 32),
                    const SizedBox(width: 12),
                    Text(a.nombre),
                  ],
                ),
              ),
          ],
        ),
      );
      if (elegido == null) return;
      await widget.repo.anadirContacto(widget.grupo.id, elegido.id);
      if (!mounted) return;
      setState(() => _miembros = widget.repo.miembros(widget.grupo.id));
      avisar(context, context.l10n.amigoAnadidoGrupo(elegido.nombre));
    } on GruposException catch (e) {
      if (mounted) avisar(context, e.mensaje);
    }
  }

  /// Nombra o quita a un miembro como administrador.
  Future<void> _cambiarAdmin(Miembro m) async {
    final hacer = !m.esAdmin;
    try {
      await widget.repo.cambiarAdmin(widget.grupo.id, m.id, hacer);
      if (!mounted) return;
      setState(() => _miembros = widget.repo.miembros(widget.grupo.id));
      avisar(
        context,
        hacer
            ? context.l10n.ahoraEsAdmin(m.nombre)
            : context.l10n.yaNoEsAdmin(m.nombre),
      );
    } on GruposException catch (e) {
      if (mounted) avisar(context, e.mensaje);
    }
  }

  Future<void> _regenerar() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(c.l10n.generarCodigoNuevo),
        content: Text(c.l10n.codigoActualDejara),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: Text(c.l10n.cancelar),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: Text(c.l10n.generar),
          ),
        ],
      ),
    );
    if (ok != true) return;
    setState(() => _regenerando = true);
    try {
      final nuevo = await widget.repo.regenerarCodigo(widget.grupo.id);
      if (mounted) setState(() => _codigo = nuevo);
    } on GruposException catch (e) {
      if (mounted) avisar(context, e.mensaje);
    } finally {
      if (mounted) setState(() => _regenerando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final g = widget.grupo;
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: Text(g.nombre, overflow: TextOverflow.ellipsis)),
      body: FondoBlobs(
        child: SafeArea(
          child: ContenidoCentrado(
            maxAncho: 760,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
              children: [
                Aparece(
                  child: Row(
                    children: [
                      AvatarEquipo(g.nombre, tam: 64),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              g.nombre,
                              style: t.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            if (g.descripcion != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                g.descripcion!,
                                style: t.bodyMedium?.copyWith(
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                LigasSeccion(
                  grupo: g,
                  ligas: widget.ligas,
                  grupos: widget.repo,
                ),
                AmistososSeccion(grupo: g, repo: widget.amistosos),
                const SizedBox(height: 24),
                Aparece(
                  retardo: 80,
                  child: _TarjetaInvitar(
                    codigo: _codigo,
                    esAdmin: g.esAdmin,
                    regenerando: _regenerando,
                    onCopiarCodigo: () =>
                        _copiar(_codigo, context.l10n.codigoCopiado),
                    onWhatsapp: () => _compartir(porEmail: false),
                    onEmail: () => _compartir(porEmail: true),
                    onCopiarMensaje: () => _copiar(
                      Invitacion.enlace(_codigo, widget.repo.yo),
                      context.l10n.enlaceCopiado,
                    ),
                    onRegenerar: _regenerar,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Text(context.l10n.miembros, style: t.titleLarge),
                    ),
                    if (g.esAdmin)
                      TextButton.icon(
                        onPressed: _anadirAmigo,
                        icon: const Icon(Icons.group_add_outlined),
                        label: Text(context.l10n.anadirAmigo),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                FutureBuilder<List<Miembro>>(
                  future: _miembros,
                  builder: (context, snap) {
                    if (snap.connectionState != ConnectionState.done) {
                      return const Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(child: Cargando()),
                      );
                    }
                    if (snap.hasError) {
                      return Text(
                        context.l10n.errCargarMiembros,
                        style: t.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      );
                    }
                    return Column(
                      children: [
                        for (final m in snap.data!)
                          _FilaMiembro(
                            m,
                            onCambiarAdmin: g.esAdmin && !m.esYo && !m.esCreador
                                ? () => _cambiarAdmin(m)
                                : null,
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TarjetaInvitar extends StatelessWidget {
  const _TarjetaInvitar({
    required this.codigo,
    required this.esAdmin,
    required this.regenerando,
    required this.onCopiarCodigo,
    required this.onCopiarMensaje,
    required this.onWhatsapp,
    required this.onEmail,
    required this.onRegenerar,
  });
  final String codigo;
  final bool esAdmin, regenerando;
  final VoidCallback onCopiarCodigo,
      onCopiarMensaje,
      onRegenerar,
      onWhatsapp,
      onEmail;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final marca = Marca.de(context);
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: marca.superficie,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: marca.borde),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person_add_alt_1_outlined, color: cs.primary),
              const SizedBox(width: 10),
              Text(context.l10n.pasoInvita, style: t.titleMedium),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            context.l10n.invitaTexto,
            style: t.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 18),
          InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onCopiarCodigo,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: cs.primary.withValues(alpha: .6),
                  width: 1.4,
                ),
                color: cs.primary.withValues(alpha: .08),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: SelectableText(
                      codigo,
                      style: t.headlineMedium?.copyWith(
                        letterSpacing: 4,
                        fontWeight: FontWeight.w900,
                        color: cs.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.copy_rounded, color: cs.primary),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              FilledButton.icon(
                onPressed: onWhatsapp,
                icon: const Icon(Icons.chat_rounded),
                label: Text(context.l10n.whatsapp),
              ),
              FilledButton.tonalIcon(
                onPressed: onEmail,
                icon: const Icon(Icons.mail_outline_rounded),
                label: Text(context.l10n.email),
              ),
              OutlinedButton.icon(
                onPressed: onCopiarMensaje,
                icon: const Icon(Icons.link_rounded),
                label: Text(context.l10n.copiarEnlace),
              ),
              if (esAdmin)
                OutlinedButton.icon(
                  onPressed: regenerando ? null : onRegenerar,
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(context.l10n.codigoNuevo),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilaMiembro extends StatelessWidget {
  const _FilaMiembro(this.m, {this.onCambiarAdmin});
  final Miembro m;

  /// Solo para administradores sobre otros miembros: nombrar o quitar administrador.
  final VoidCallback? onCambiarAdmin;

  @override
  Widget build(BuildContext context) {
    final marca = Marca.de(context);
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: marca.superficie,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: marca.borde),
      ),
      child: Row(
        children: [
          AvatarEquipo(m.nombre, tam: 36),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              m.esYo ? '${m.nombre} ${context.l10n.tu}' : m.nombre,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          if (m.esAdmin)
            Insignia(
              context.l10n.admin,
              color: cs.primary,
              icono: Icons.shield_outlined,
            ),
          if (onCambiarAdmin != null)
            PopupMenuButton<void>(
              tooltip: context.l10n.opciones,
              icon: const Icon(Icons.more_vert),
              itemBuilder: (_) => [
                PopupMenuItem(
                  onTap: onCambiarAdmin,
                  child: Text(
                    m.esAdmin
                        ? context.l10n.quitarAdmin
                        : context.l10n.hacerAdmin,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _DialogoDestino extends StatefulWidget {
  const _DialogoDestino({required this.porEmail});
  final bool porEmail;
  @override
  State<_DialogoDestino> createState() => _DialogoDestinoState();
}

class _DialogoDestinoState extends State<_DialogoDestino> {
  final _form = GlobalKey<FormState>();
  final _ctl = TextEditingController();

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  String? _validar(String? v) {
    final t = (v ?? '').trim();
    if (widget.porEmail) {
      return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(t)
          ? null
          : context.l10n.emailValido;
    }
    return Invitacion.telefono(t).length >= 9
        ? null
        : context.l10n.telefonoValido;
  }

  void _enviar() {
    if (_form.currentState!.validate()) {
      Navigator.pop(context, _ctl.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(
      widget.porEmail
          ? context.l10n.invitarPorEmail
          : context.l10n.invitarPorWhatsapp,
    ),
    actionsPadding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
    contentPadding: const EdgeInsets.fromLTRB(28, 20, 28, 12),
    content: SizedBox(
      width: 520,
      child: Form(
        key: _form,
        child: CampoTextoForm(
          controller: _ctl,
          autofocus: true,
          keyboardType: widget.porEmail
              ? TextInputType.emailAddress
              : TextInputType.phone,
          validator: _validar,
          onFieldSubmitted: (_) => _enviar(),
          decoration: InputDecoration(
            labelText: widget.porEmail
                ? context.l10n.email
                : context.l10n.telefono,
            prefixIcon: Icon(
              widget.porEmail
                  ? Icons.mail_outline_rounded
                  : Icons.phone_outlined,
            ),
            helperText: widget.porEmail ? null : context.l10n.conPrefijo,
          ),
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text(context.l10n.cancelar),
      ),
      FilledButton(onPressed: _enviar, child: Text(context.l10n.continuar)),
    ],
  );
}
