import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import 'package:supabase_flutter/supabase_flutter.dart' as sb show AuthException;
import 'auth_repositorio.dart';

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
  Future<void> iniciarSesion({required String email, required String password}) =>
      _traducir(() => _a.signInWithPassword(email: email.trim(), password: password));

  @override
  Future<bool> registrar({required String nombre, required String email, required String password}) =>
      _traducir(() async {
        final r = await _a.signUp(
          email: email.trim(),
          password: password,
          data: {'nombre': nombre},
          emailRedirectTo: kIsWeb ? Uri.base.origin : null,
        );
        // Con "Confirm email" activo, Supabase no devuelve sesión hasta confirmar.
        // Si el email ya existe, devuelve un usuario sin identidades (anti-enumeración).
        if (r.user != null && (r.user!.identities?.isEmpty ?? false)) {
          throw const AuthException('Ya existe una cuenta con ese email.');
        }
        return r.session != null;
      });

  @override
  Future<void> recuperarPassword({required String email}) =>
      _traducir(() => _a.resetPasswordForEmail(email.trim(), redirectTo: kIsWeb ? Uri.base.origin : null));

  @override
  Stream<void> get recuperacion => _a.onAuthStateChange.where((e) => e.event == AuthChangeEvent.passwordRecovery);

  @override
  Future<void> cambiarPassword(String nueva) => _traducir(() => _a.updateUser(UserAttributes(password: nueva)));

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
      throw const AuthException('No se pudo conectar. Revisa tu conexión e inténtalo de nuevo.');
    }
  }

  String _mensaje(AuthApiException e) => switch (e.code) {
        'invalid_credentials' => 'Email o contraseña incorrectos.',
        'email_not_confirmed' => 'Confirma tu email antes de entrar (revisa tu correo).',
        'user_already_exists' || 'email_exists' => 'Ya existe una cuenta con ese email.',
        'weak_password' => 'La contraseña es demasiado débil.',
        'over_request_rate_limit' || 'over_email_send_rate_limit' => 'Demasiados intentos. Espera un momento.',
        _ => 'No se pudo completar la operación (${e.message}).',
      };
}
