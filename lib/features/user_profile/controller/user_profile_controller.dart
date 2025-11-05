import 'dart:io';

import 'package:esfotalk_app/apis/roar_api.dart';
import 'package:esfotalk_app/apis/storage_api.dart';
import 'package:esfotalk_app/apis/user_api.dart';
import 'package:esfotalk_app/core/enums/notification_type_enum.dart';
import 'package:esfotalk_app/core/utils.dart';
import 'package:esfotalk_app/features/notifications/controller/notification_controller.dart';
import 'package:esfotalk_app/models/roar_model.dart';
import 'package:esfotalk_app/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userProfileControllerProvider =
    StateNotifierProvider<UserProfileController, bool>((ref) {
      return UserProfileController(
        roarAPI: ref.watch(roarAPIProvider),
        storageAPI: ref.watch(
          storageAPIProvider,
        ), // Esta línea faltaba o era incorrecta
        userAPI: ref.watch(userAPIProvider),
        notificationController: ref.watch(
          notificationControllerProvider.notifier,
        ),
      );
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

final getLatestUserProfileDataProvider = StreamProvider((ref) {
  final userAPI = ref.watch(userAPIProvider);
  return userAPI.getLatestUserProfileData();
});

class UserProfileController extends StateNotifier<bool> {
  final RoarAPI _roarAPI;
  final StorageAPI _storageAPI;
  final UserAPI _userAPI;
  final NotificationController _notificationController;

  UserProfileController({
    required RoarAPI roarAPI,
    required StorageAPI storageAPI,
    required UserAPI userAPI,
    required NotificationController notificationController,
  }) : _roarAPI = roarAPI,
       _storageAPI = storageAPI,
       _userAPI = userAPI,
       _notificationController = notificationController,
       super(false);

  Future<List<Roar>> getUserRoars(String uid) async {
    final roars = await _roarAPI.getUserRoars(uid);
    return roars.map((e) => Roar.fromMap(e.data)).toList();
  }

  void updateUserProfile({
    required UserModel userModel,
    required BuildContext context,
    required File? bannerFile,
    required File? profileFile,
  }) async {
    state = true;
    if (bannerFile != null) {
      final bannerUrl = await _storageAPI.uploadImage([bannerFile]);
      userModel = userModel.copyWith(bannerPic: bannerUrl[0]);
    }

    if (profileFile != null) {
      final profileUrl = await _storageAPI.uploadImage([profileFile]);
      userModel = userModel.copyWith(profilePic: profileUrl[0]);
    }

    final res = await _userAPI.updateUserData(userModel: userModel);
    state = false;
    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) => Navigator.pop(context),
    );
  }

  void followUser({
    required UserModel user,
    required BuildContext context,
    required UserModel currentUser,
  }) async {
    if (currentUser.following.contains(user.uid)) {
      user.followers.remove(currentUser.uid);
      currentUser.following.remove(user.uid);
    } else {
      user.followers.add(currentUser.uid);
      currentUser.following.add(user.uid);
    }

    user = user.copyWith(followers: user.followers);
    currentUser = currentUser.copyWith(following: currentUser.following);

    final res = await _userAPI.followUser(user);
    res.fold((l) => showSnackBar(context, l.message), (r) async {
      final res2 = await _userAPI.addToFollowing(currentUser);
      res2.fold((l) => showSnackBar(context, l.message), (r) {
        _notificationController.createNotification(
          text: '¡${currentUser.name} ha empezado a seguirte!',
          postId: '',
          uid: user.uid,
          notificationType: NotificationType.follow,
        );
      });
    });
  }
}
