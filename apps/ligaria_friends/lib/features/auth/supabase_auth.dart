import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import 'package:supabase_flutter/supabase_flutter.dart'
    as sb
    show AuthException;
import 'auth_repositorio.dart';
import '../../core/idioma.dart';

/// Autenticación real con Supabase Auth (email + contraseña).
class SupabaseAuth implements AuthRepositorio {
  GoTrueClient get _a => Supabase.instance.client.auth;

  @override
  bool get haySesion => _a.currentSession != null;

  @override
  Stream<bool> get sesion async* {
    yield haySesion;
    yield* _a.onAuthStateChange.map((e) => e.session != null);
  }

  @override
  Future<void> iniciarSesion({
    required String email,
    required String password,
  }) => _traducir(
    () => _a.signInWithPassword(email: email.trim(), password: password),
  );

  @override
  Future<bool> registrar({
    required String nombre,
    required String email,
    required String password,
    String? nombreTienda,
  }) => _traducir(() async {
    final r = await _a.signUp(
      email: email.trim(),
      password: password,
      data: {
        'nombre': nombre,
        if (nombreTienda != null) ...{
          'tipo_cuenta': 'TIENDA',
          'nombre_tienda': nombreTienda,
        },
      },
      emailRedirectTo: kIsWeb ? Uri.base.origin : null,
    );
    // Con "Confirm email" activo, Supabase no devuelve sesión hasta confirmar.
    // Si el email ya existe, devuelve un usuario sin identidades (anti-enumeración).
    if (r.user != null && (r.user!.identities?.isEmpty ?? false)) {
      throw AuthException(l10nActual.errCuentaExiste);
    }
    return r.session != null;
  });

  @override
  Future<TipoCuenta> tipoCuenta() => _traducir(() async {
    final uid = _a.currentUser?.id;
    if (uid == null) return TipoCuenta.jugador;
    final fila = await Supabase.instance.client
        .from('perfil')
        .select('tipo_cuenta')
        .eq('id', uid)
        .maybeSingle();
    return fila?['tipo_cuenta'] == 'TIENDA'
        ? TipoCuenta.tienda
        : TipoCuenta.jugador;
  });

  @override
  Future<void> recuperarPassword({required String email}) => _traducir(
    () => _a.resetPasswordForEmail(
      email.trim(),
      redirectTo: kIsWeb ? Uri.base.origin : null,
    ),
  );

  @override
  Stream<void> get recuperacion => _a.onAuthStateChange.where(
    (e) => e.event == AuthChangeEvent.passwordRecovery,
  );

  @override
  Future<void> cambiarPassword(String nueva) =>
      _traducir(() => _a.updateUser(UserAttributes(password: nueva)));

  @override
  Future<void> cerrarSesion() => _a.signOut();

  Future<T> _traducir<T>(Future<T> Function() accion) async {
    try {
      return await accion();
    } on AuthException {
      rethrow;
    } on AuthApiException catch (e) {
      throw AuthException(_mensaje(e));
    } on sb.AuthException catch (e) {
      throw AuthException(e.message);
    } catch (_) {
      throw AuthException(l10nActual.errConexion);
    }
  }

  String _mensaje(AuthApiException e) => switch (e.code) {
    'invalid_credentials' => l10nActual.errCredenciales,
    'email_not_confirmed' => l10nActual.errEmailSinConfirmar,
    'user_already_exists' || 'email_exists' => l10nActual.errCuentaExiste,
    'weak_password' => l10nActual.errContrasenaDebil,
    'over_request_rate_limit' ||
    'over_email_send_rate_limit' => l10nActual.errDemasiadosIntentos,
    _ => l10nActual.errOperacionMsg(e.message),
  };
}
