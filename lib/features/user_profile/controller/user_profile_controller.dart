import 'dart:io';

import 'package:esfotalk_app/apis/roar_api.dart';
import 'package:esfotalk_app/apis/storage_api.dart';
import 'package:esfotalk_app/apis/user_api.dart';
import 'package:esfotalk_app/core/utils.dart';
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
  UserProfileController({
    required RoarAPI roarAPI,
    required StorageAPI storageAPI,
    required UserAPI userAPI,
  }) : _roarAPI = roarAPI,
       _storageAPI = storageAPI,
       _userAPI = userAPI,
       super(false);

  Future<List<Roar>> getUserRoars(String uid) async {
    final roars = await _roarAPI.getUserRoars(uid);
    return roars.map((e) => Roar.fromMap(e.data)).toList();
  }

  void updateUserProfile({
    required UserModel userModel,
    required BuildContext context,
    required File? bannerImage,
    required File? profileImage,
  }) async {
    state = true;
    if (bannerImage != null) {
      final res = await _storageAPI.uploadImages([bannerImage]);
      final foldResult = res.fold(
        (l) {
          showSnackBar(context, l.message);
          return false; // Indica fallo
        },
        (r) {
          userModel = userModel.copyWith(bannerPic: r[0]);
          return true; // Indica éxito
        },
      );
      if (!foldResult) {
        state = false;
        return;
      }
    }

    if (profileImage != null) {
      final res = await _storageAPI.uploadImages([profileImage]);
      final foldResult = res.fold(
        (l) {
          showSnackBar(context, l.message);
          return false; // Indica fallo
        },
        (r) {
          userModel = userModel.copyWith(profilePic: r[0]);
          return true; // Indica éxito
        },
      );
      if (!foldResult) {
        state = false;
        return;
      }
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
    res.fold((l) => showSnackBar(context, l.message), (r) async{
      final res2 = await _userAPI.addToFollowing(currentUser);
      res2.fold((l) => showSnackBar(context, l.message), (r) => null);
    });
    }
}

