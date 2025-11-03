import 'package:esfotalk_app/apis/user_api.dart';
import 'package:esfotalk_app/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final exploreControllerProvider =
    StateNotifierProvider<ExploreController, bool>((ref) {
  final userAPI = ref.watch(userAPIProvider);
  return ExploreController(userAPI: userAPI);
});

final searchUserProvider = FutureProvider.family<List<UserModel>, String>(
  (ref, name) {
    final exploreController = ref.watch(exploreControllerProvider.notifier);
    return exploreController.searchUser(name);
  },
);


class ExploreController extends StateNotifier<bool> {
  final UserAPI _userAPI;
  ExploreController({required UserAPI userAPI})
    : _userAPI = userAPI,
      super(false);

  Future<List<UserModel>> searchUser(String name) async {
    final users = await _userAPI.searchUserByName(name);
    return users.map((e) => UserModel.fromMap(e.data)).toList();
  }
}
