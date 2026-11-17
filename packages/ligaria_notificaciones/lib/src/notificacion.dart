/// Una notificación de la bandeja (fila de `public.notificacion`).
class Notificacion {
  const Notificacion({
    required this.id,
    required this.tipo,
    required this.titulo,
    required this.cuerpo,
    required this.creada,
    this.datos = const {},
    this.leida = false,
  });

  final String id;
  final String tipo;
  final String titulo;
  final String cuerpo;
  final DateTime creada;
  final Map<String, dynamic> datos;
  final bool leida;

  /// Ruta lógica indicada por el backend (`datos.ruta`), p. ej. `amistoso` o `encuentro`.
  String? get ruta => datos['ruta'] as String?;

  Notificacion copiarLeida() => Notificacion(
    id: id,
    tipo: tipo,
    titulo: titulo,
    cuerpo: cuerpo,
    creada: creada,
    datos: datos,
    leida: true,
  );

  factory Notificacion.desdeMapa(Map<String, dynamic> m) => Notificacion(
    id: m['id'] as String,
    tipo: m['tipo'] as String,
    titulo: m['titulo'] as String,
    cuerpo: (m['cuerpo'] as String?) ?? '',
    creada: DateTime.parse(m['created_at'] as String),
    datos: Map<String, dynamic>.from((m['datos'] as Map?) ?? const {}),
    leida: m['leida_at'] != null,
  );
}

/// Preferencia de un tipo de aviso: en la app y/o por email.
class PreferenciaNotificacion {
  const PreferenciaNotificacion({this.app = true, this.email = true});
  final bool app;
  final bool email;

  PreferenciaNotificacion copiar({bool? app, bool? email}) =>
      PreferenciaNotificacion(app: app ?? this.app, email: email ?? this.email);
}
