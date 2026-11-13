import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/liga_repository.dart';
import '../../data/models.dart';

final saOrganizacionesProvider = FutureProvider.autoDispose<List<OrganizacionAdmin>>(
    (ref) => ref.watch(ligaRepositoryProvider).organizaciones());
final saLigasProvider = FutureProvider.autoDispose<List<Liga>>((ref) => ref.watch(ligaRepositoryProvider).misLigas());
