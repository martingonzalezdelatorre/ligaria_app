import 'package:supabase_flutter/supabase_flutter.dart';
import '../ligas/ligas_repositorio.dart';

/// Jugador encontrado en la búsqueda (solo quienes activan su visibilidad en Ajustes).
class JugadorBuscado {
  const JugadorBuscado({
    required this.id,
    required this.nombre,
    this.provincia = '',
    this.localidad = '',
    this.esAmigo = false,
    this.tieneWhatsapp = false,
  });
  final String id, nombre, provincia, localidad;
  final bool esAmigo, tieneWhatsapp;

  /// «Localidad, Provincia» con lo que haya.
  String get zona => [localidad, provincia].where((s) => s.isNotEmpty).join(', ');
}

class MensajeChat {
  const MensajeChat({
    required this.id,
    required this.mio,
    required this.texto,
    required this.fecha,
  });
  final String id, texto;
  final bool mio;
  final DateTime fecha;
}

class Conversacion {
  const Conversacion({
    required this.conId,
    required this.nombre,
    required this.ultimo,
    required this.fecha,
    required this.sinLeer,
  });
  final String conId, nombre, ultimo;
  final DateTime fecha;
  final int sinLeer;
}

/// Búsqueda de jugadores, amigos, WhatsApp y mensajes internos.
/// [SocialSupabase] en modo real, [SocialDemo] en demo.
abstract class SocialRepositorio {
  /// Lo fija `main()`; por defecto, en memoria.
  static SocialRepositorio instancia = SocialDemo();

  Future<List<JugadorBuscado>> buscar({
    String texto = '',
    String provincia = '',
    String localidad = '',
  });

  /// Añade a alguien a tus amigos (contactos).
  Future<void> anadirAmigo(String usuarioId);

  /// Teléfono para WhatsApp, o `null` si la persona no lo comparte.
  Future<String?> whatsapp(String usuarioId);

  Future<List<MensajeChat>> mensajes(String conId);
  Future<void> enviar(String conId, String texto);
  Future<void> marcarLeidos(String conId);
  Future<List<Conversacion>> conversaciones();
}

class SocialSupabase implements SocialRepositorio {
  SupabaseClient get _c => Supabase.instance.client;

  Future<T> _traducir<T>(Future<T> Function() accion) async {
    try {
      return await accion();
    } on PostgrestException catch (e) {
      throw LigasException(e.message);
    }
  }

  @override
  Future<List<JugadorBuscado>> buscar({
    String texto = '',
    String provincia = '',
    String localidad = '',
  }) => _traducir(() async {
    final filas = await _c.rpc(
      'buscar_jugadores',
      params: {
        'p_texto': texto.trim(),
        'p_provincia': provincia.trim(),
        'p_localidad': localidad.trim(),
      },
    );
    return [
      for (final f in filas as List)
        JugadorBuscado(
          id: f['id'] as String,
          nombre: (f['nombre'] as String?) ?? '',
          provincia: (f['provincia'] as String?) ?? '',
          localidad: (f['localidad'] as String?) ?? '',
          esAmigo: (f['es_amigo'] as bool?) ?? false,
          tieneWhatsapp: (f['tiene_whatsapp'] as bool?) ?? false,
        ),
    ];
  });

  @override
  Future<void> anadirAmigo(String usuarioId) => _traducir(
    () => _c.rpc('anadir_amigo', params: {'p_usuario': usuarioId}),
  );

  @override
  Future<String?> whatsapp(String usuarioId) => _traducir(() async {
    final r = await _c.rpc('whatsapp_de', params: {'p_usuario': usuarioId});
    return r as String?;
  });

  @override
  Future<List<MensajeChat>> mensajes(String conId) => _traducir(() async {
    final yo = _c.auth.currentUser!.id;
    final filas = await _c
        .from('mensaje')
        .select('id, de, texto, created_at')
        .or('and(de.eq.$yo,para.eq.$conId),and(de.eq.$conId,para.eq.$yo)')
        .order('created_at');
    return [
      for (final f in filas)
        MensajeChat(
          id: f['id'] as String,
          mio: f['de'] == yo,
          texto: f['texto'] as String,
          fecha: DateTime.parse(f['created_at'] as String).toLocal(),
        ),
    ];
  });

  @override
  Future<void> enviar(String conId, String texto) => _traducir(
    () => _c.rpc('enviar_mensaje', params: {'p_para': conId, 'p_texto': texto}),
  );

  @override
  Future<void> marcarLeidos(String conId) =>
      _traducir(() => _c.rpc('marcar_leidos', params: {'p_con': conId}));

  @override
  Future<List<Conversacion>> conversaciones() => _traducir(() async {
    final filas = await _c.rpc('mis_conversaciones');
    final lista = [
      for (final f in filas as List)
        Conversacion(
          conId: f['con_id'] as String,
          nombre: (f['nombre'] as String?) ?? '',
          ultimo: (f['ultimo'] as String?) ?? '',
          fecha: DateTime.parse(f['fecha'] as String).toLocal(),
          sinLeer: (f['sin_leer'] as num).toInt(),
        ),
    ];
    lista.sort((a, b) => b.fecha.compareTo(a.fecha));
    return lista;
  });
}

class SocialDemo implements SocialRepositorio {
  static const _jugadores = [
    JugadorBuscado(
      id: 'u1',
      nombre: 'Lucía Pérez',
      provincia: 'Madrid',
      localidad: 'Getafe',
      esAmigo: true,
      tieneWhatsapp: true,
    ),
    JugadorBuscado(
      id: 'u2',
      nombre: 'Carlos Ruiz',
      provincia: 'Madrid',
      localidad: 'Leganés',
      tieneWhatsapp: true,
    ),
    JugadorBuscado(
      id: 'u3',
      nombre: 'Marta Gil',
      provincia: 'Valencia',
      localidad: 'Gandía',
    ),
    JugadorBuscado(
      id: 'u5',
      nombre: 'Íñigo Etxeberria',
      provincia: 'Bizkaia',
      localidad: 'Bilbao',
    ),
  ];

  final _amigos = <String>{'u1'};
  final _msgs = <({String con, bool mio, String texto, DateTime fecha})>[];

  @override
  Future<List<JugadorBuscado>> buscar({
    String texto = '',
    String provincia = '',
    String localidad = '',
  }) async {
    final t = texto.trim().toLowerCase();
    final loc = localidad.trim().toLowerCase();
    return [
      for (final j in _jugadores)
        if ((t.isEmpty || j.nombre.toLowerCase().contains(t)) &&
            (provincia.isEmpty || j.provincia == provincia) &&
            (loc.isEmpty || j.localidad.toLowerCase().contains(loc)))
          JugadorBuscado(
            id: j.id,
            nombre: j.nombre,
            provincia: j.provincia,
            localidad: j.localidad,
            esAmigo: _amigos.contains(j.id),
            tieneWhatsapp: j.tieneWhatsapp,
          ),
    ];
  }

  @override
  Future<void> anadirAmigo(String usuarioId) async => _amigos.add(usuarioId);

  @override
  Future<String?> whatsapp(String usuarioId) async =>
      _jugadores.any((j) => j.id == usuarioId && j.tieneWhatsapp)
      ? '600123123'
      : null;

  @override
  Future<List<MensajeChat>> mensajes(String conId) async => [
    for (final (i, m) in _msgs.indexed)
      if (m.con == conId)
        MensajeChat(id: '$i', mio: m.mio, texto: m.texto, fecha: m.fecha),
  ];

  @override
  Future<void> enviar(String conId, String texto) async => _msgs.add((
    con: conId,
    mio: true,
    texto: texto.trim(),
    fecha: DateTime.now(),
  ));

  @override
  Future<void> marcarLeidos(String conId) async {}

  @override
  Future<List<Conversacion>> conversaciones() async {
    final porCon = <String, Conversacion>{};
    for (final m in _msgs) {
      final nombre = _jugadores
          .firstWhere(
            (j) => j.id == m.con,
            orElse: () => JugadorBuscado(id: m.con, nombre: 'Amigo'),
          )
          .nombre;
      porCon[m.con] = Conversacion(
        conId: m.con,
        nombre: nombre,
        ultimo: m.texto,
        fecha: m.fecha,
        sinLeer: 0,
      );
    }
    return porCon.values.toList().reversed.toList();
  }
}
