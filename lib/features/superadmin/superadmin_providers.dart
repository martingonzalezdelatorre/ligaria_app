import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/liga_repository.dart';
import '../../data/models.dart';

final saEscuelasProvider =
    FutureProvider.autoDispose<List<EscuelaAdmin>>((ref) => ref.watch(ligaRepositoryProvider).escuelas());
final saTemporadasProvider =
    FutureProvider.autoDispose<List<Temporada>>((ref) => ref.watch(ligaRepositoryProvider).temporadas());
final saLigasProvider = FutureProvider.autoDispose<List<Liga>>((ref) => ref.watch(ligaRepositoryProvider).misLigas());
final saRegistroProvider = FutureProvider.autoDispose<List<RegistroCambio>>(
    (ref) => ref.watch(ligaRepositoryProvider).registroCambios(limite: 200));

/// «Escuela Ñandú Norte» → «escuela-nandu-norte»
String slugDe(String texto) {
  const de = 'áàäâéèëêíìïîóòöôúùüûñç';
  const a = 'aaaaeeeeiiiioooouuuunc';
  final sb = StringBuffer();
  for (final ch in texto.toLowerCase().split('')) {
    final i = de.indexOf(ch);
    sb.write(i >= 0 ? a[i] : ch);
  }
  return sb.toString().replaceAll(RegExp(r'[^a-z0-9]+'), '-').replaceAll(RegExp(r'^-+|-+$'), '');
}
