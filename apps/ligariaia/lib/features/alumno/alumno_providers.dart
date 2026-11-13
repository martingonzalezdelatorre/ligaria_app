import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/liga_repository.dart';
import '../../data/models.dart';

final misLigasProvider = FutureProvider<List<Liga>>((ref) => ref.watch(ligaRepositoryProvider).misLigas());
final misEquiposProvider = FutureProvider<List<MiEquipo>>((ref) => ref.watch(ligaRepositoryProvider).misEquipos());
final misFichasProvider = FutureProvider<List<Ficha>>((ref) => ref.watch(ligaRepositoryProvider).misFichas());

final encuentrosProvider =
    FutureProvider.family<List<EncuentroVista>, String>((ref, ligaId) => ref.watch(ligaRepositoryProvider).encuentros(ligaId));
final descansosProvider =
    FutureProvider.family<List<Descanso>, String>((ref, ligaId) => ref.watch(ligaRepositoryProvider).descansos(ligaId));
final clasificacionProvider = FutureProvider.family<List<FilaClasificacion>, String>(
    (ref, ligaId) => ref.watch(ligaRepositoryProvider).clasificacion(ligaId));
