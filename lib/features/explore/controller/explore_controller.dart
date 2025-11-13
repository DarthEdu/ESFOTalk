import 'package:esfotalk_app/apis/user_api.dart';
import 'package:esfotalk_app/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Controlador ligero, no mantiene estado propio -> Provider simple.
final exploreControllerProvider = Provider<ExploreController>((ref) {
  final userAPI = ref.watch(userAPIProvider);
  return ExploreController(userAPI: userAPI);
});

final searchUserProvider = FutureProvider.family<List<UserModel>, String>(
  (ref, name) => ref.watch(exploreControllerProvider).searchUser(name),
);

class ExploreController {
  final UserAPI _userAPI;
  ExploreController({required UserAPI userAPI}) : _userAPI = userAPI;

  Future<List<UserModel>> searchUser(String name) async {
    final query = name.trim();
    if (query.isEmpty) return [];
    try {
      final users = await _userAPI.searchUserByName(query);
      return users.map((e) => UserModel.fromMap(e.data)).toList();
    } catch (_) {
      // En caso de error en la búsqueda, devolvemos lista vacía para no romper la UI.
      return [];
    }
  }
}
