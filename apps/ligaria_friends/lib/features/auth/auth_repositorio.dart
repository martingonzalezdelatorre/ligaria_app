import 'dart:async';

/// Perfil de la cuenta: decide qué parte de la app se muestra al entrar.
enum TipoCuenta { jugador, tienda }

/// Contrato de autenticación de Friends. Las pantallas solo dependen de esto:
/// [SupabaseAuth] (producción) o [AuthDemo] (sin configuración / tests).
abstract class AuthRepositorio {
  /// Emite `true` cuando hay sesión y `false` cuando no (incluye el estado inicial).
  Stream<bool> get sesion;
  bool get haySesion;

  Future<void> iniciarSesion({required String email, required String password});

  /// Devuelve `true` si el usuario queda con sesión iniciada; `false` si debe
  /// confirmar antes su email.
  /// Si [nombreTienda] no es null, se crea una cuenta de perfil Tienda con ese comercio.
  Future<bool> registrar({
    required String nombre,
    required String email,
    required String password,
    String? nombreTienda,
  });

  /// Perfil de la sesión actual.
  Future<TipoCuenta> tipoCuenta();

  Future<void> recuperarPassword({required String email});

  /// Emite cuando el usuario llega desde el enlace del correo de recuperación.
  Stream<void> get recuperacion;

  /// Fija la contraseña nueva (requiere la sesión de recuperación).
  Future<void> cambiarPassword(String nueva);
  Future<void> cerrarSesion();
}

class AuthException implements Exception {
  const AuthException(this.mensaje);
  final String mensaje;
  @override
  String toString() => mensaje;
}

/// Implementación en memoria para desarrollo y pruebas.
class AuthDemo implements AuthRepositorio {
  final _usuarios = <String, String>{
    'demo@ligaria.es': 'demo1234',
    'tienda@ligaria.es': 'tienda1234',
  };
  final _tiendas = <String>{'tienda@ligaria.es'};
  String? _actual;
  bool _dentro = false;
  final _ctl = StreamController<bool>.broadcast();

  @override
  bool get haySesion => _dentro;

  @override
  Stream<bool> get sesion async* {
    yield _dentro;
    yield* _ctl.stream;
  }

  void _fijar(bool v) {
    _dentro = v;
    _ctl.add(v);
  }

  Future<void> _latencia() => Future.delayed(const Duration(milliseconds: 700));

  @override
  Future<void> iniciarSesion({
    required String email,
    required String password,
  }) async {
    await _latencia();
    if (_usuarios[email.trim().toLowerCase()] != password) {
      throw const AuthException('Email o contraseña incorrectos.');
    }
    _actual = email.trim().toLowerCase();
    _fijar(true);
  }

  @override
  Future<TipoCuenta> tipoCuenta() async =>
      _tiendas.contains(_actual) ? TipoCuenta.tienda : TipoCuenta.jugador;

  @override
  Future<bool> registrar({
    required String nombre,
    required String email,
    required String password,
    String? nombreTienda,
  }) async {
    await _latencia();
    final e = email.trim().toLowerCase();
    if (_usuarios.containsKey(e)) {
      throw const AuthException('Ya existe una cuenta con ese email.');
    }
    _usuarios[e] = password;
    if (nombreTienda != null) _tiendas.add(e);
    _actual = e;
    _fijar(true);
    return true;
  }

  @override
  Future<void> recuperarPassword({required String email}) => _latencia();

  @override
  Stream<void> get recuperacion => const Stream.empty();

  @override
  Future<void> cambiarPassword(String nueva) => _latencia();

  @override
  Future<void> cerrarSesion() async => _fijar(false);
}
