import 'package:speech_to_text/speech_to_text.dart';

/// Reconocimiento de voz del tanteador. Lo fija `main()` o los tests; por defecto, el del sistema.
abstract class EscuchaVoz {
  static EscuchaVoz instancia = EscuchaVozSistema();

  /// Pide permisos y prepara el reconocedor. `false` si no hay permiso o el dispositivo no lo soporta.
  Future<bool> preparar({
    required void Function() alTerminarEscucha,
    required void Function(String error) alFallar,
  });

  /// Empieza a escuchar; [alFrase] recibe cada frase **ya cerrada** (no los parciales).
  Future<void> escuchar({
    required String idioma,
    required void Function(String frase) alFrase,
  });

  Future<void> parar();
}

class EscuchaVozSistema implements EscuchaVoz {
  final _stt = SpeechToText();
  bool _listo = false;

  @override
  Future<bool> preparar({
    required void Function() alTerminarEscucha,
    required void Function(String error) alFallar,
  }) async {
    try {
      return _listo = await _stt.initialize(
        onStatus: (s) {
          // El reconocedor se corta solo tras unos segundos de silencio.
          if (s == SpeechToText.doneStatus ||
              s == SpeechToText.notListeningStatus) {
            alTerminarEscucha();
          }
        },
        onError: (e) => alFallar(e.errorMsg),
      );
    } catch (e) {
      return _listo = false;
    }
  }

  /// Id de idioma del dispositivo que empieza por [idioma] («es» → «es_ES»), o el del sistema.
  Future<String?> _localeId(String idioma) async {
    final todos = await _stt.locales();
    for (final l in todos) {
      if (l.localeId.toLowerCase().startsWith(idioma.toLowerCase())) {
        return l.localeId;
      }
    }
    return null;
  }

  @override
  Future<void> escuchar({
    required String idioma,
    required void Function(String frase) alFrase,
  }) async {
    if (!_listo || _stt.isListening) return;
    await _stt.listen(
      listenOptions: SpeechListenOptions(
        localeId: await _localeId(idioma),
        listenFor: const Duration(minutes: 1),
        pauseFor: const Duration(seconds: 4),
        partialResults: false,
        cancelOnError: false,
        listenMode: ListenMode.dictation,
      ),
      onResult: (r) {
        if (r.finalResult && r.recognizedWords.trim().isNotEmpty) {
          alFrase(r.recognizedWords);
        }
      },
    );
  }

  @override
  Future<void> parar() async {
    if (_listo) await _stt.stop();
  }
}
