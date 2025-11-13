import 'package:appwrite/models.dart';
import 'package:esfotalk_app/apis/auth_api.dart';
import 'package:esfotalk_app/apis/user_api.dart';
import 'package:esfotalk_app/core/utils.dart';
import 'package:esfotalk_app/features/auth/view/signup_view.dart';
import 'package:esfotalk_app/features/home/view/home_view.dart';
import 'package:esfotalk_app/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authControllerProvider = StateNotifierProvider<AuthController, bool>((
  ref,
) {
  return AuthController(
    authAPI: ref.watch(authAPIProvider),
    userAPI: ref.watch(userAPIProvider),
  );
});

final currentUserAccountProvider = FutureProvider((ref) {
  final authController = ref.watch(authControllerProvider.notifier);
  return authController.currentUser();
});

final userDetailsProvider = FutureProvider.family((ref, String uid) {
  final authController = ref.watch(authControllerProvider.notifier);
  return authController.getUserData(uid);
});

final currentUserDetailsProvider = FutureProvider((ref) {
  final currentUserId = ref.watch(currentUserAccountProvider).value?.$id;
  if (currentUserId == null) {
    return null;
  }
  final userDetails = ref.watch(userDetailsProvider(currentUserId));
  return userDetails.value;
});

class AuthController extends StateNotifier<bool> {
  final AuthAPI _authAPI;
  final UserAPI _userAPI;

  AuthController({required AuthAPI authAPI, required UserAPI userAPI})
    : _authAPI = authAPI,
      _userAPI = userAPI,
      super(false);

  Future<User?> currentUser() => _authAPI.currentUserAccount();

  void signUp({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    state = true;
    final res = await _authAPI.signUp(email: email, password: password);
    state = false;
    res.fold((l) => showSnackBar(context, l.message), (r) async {
      final loginRes = await _authAPI.login(email: email, password: password);
      loginRes.fold(
        (l) => showSnackBar(context, 'Error al iniciar sesión: ${l.message}'),
        (session) async {
          UserModel userModel = UserModel(
            name: getNameFromEmail(email),
            email: r.email,
            followers: const [],
            following: const [],
            profilePic: '',
            bannerPic: '',
            uid: r.$id,
            bio: '',
            isDragonred: false,
          );
          final res2 = await _userAPI.saveUserData(userModel: userModel);
          res2.fold((l) => showSnackBar(context, l.message), (r) async {
            await sendVerificationEmail(context);
            showSnackBar(
              context,
              'Cuenta creada. Revisa tu email para verificar.',
            );
            Navigator.pushReplacement(context, HomeView.route());
          });
        },
      );
    });
  }

  void login({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    state = true;
    final res = await _authAPI.login(email: email, password: password);
    state = false;
    res.fold((l) => showSnackBar(context, l.message), (r) {
      Navigator.push(context, HomeView.route());
    });
  }

  Future<void> sendVerificationEmail(BuildContext context) async {
    final res = await _authAPI.sendVerificationEmail();
    res.fold((l) => showSnackBar(context, l.message), (r) => null);
  }

  Future<void> sendPasswordReset({
    required String email,
    required BuildContext context,
  }) async {
    state = true;
    final res = await _authAPI.sendPasswordReset(email: email);
    state = false;
    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) => showSnackBar(context, 'Email de recuperación enviado.'),
    );
  }

  void logout(BuildContext context) async {
    final res = await _authAPI.logout();
    res.fold((l) => showSnackBar(context, l.message), (r) {
      Navigator.pushAndRemoveUntil(
        context,
        SignUpView.route(),
        (route) => false,
      );
    });
  }

  Future<UserModel> getUserData(String uid) async {
    final document = await _userAPI.getUserData(uid);
    return UserModel.fromMap(document.data);
  }
}
