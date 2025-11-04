import 'package:esfotalk_app/apis/roar_api.dart';
import 'package:esfotalk_app/models/roar_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userProfileControllerProvider =
    StateNotifierProvider<UserProfileController, bool>((ref) {
      return UserProfileController(roarAPI: ref.watch(roarAPIProvider));
    });

final getUserRoarsProvider = FutureProvider.family<List<Roar>, String>((
  ref,
  uid,
) async {
  final userProfileController = ref.watch(
    userProfileControllerProvider.notifier,
  );
  return userProfileController.getUserRoars(uid);
});

class UserProfileController extends StateNotifier<bool> {
  final RoarAPI _roarAPI;
  UserProfileController({required RoarAPI roarAPI})
    : _roarAPI = roarAPI,
      super(false);

  Future<List<Roar>> getUserRoars(String uid) async {
    final roars = await _roarAPI.getUserRoars(uid);
    return roars.map((e) => Roar.fromMap(e.data)).toList();
  }
}
