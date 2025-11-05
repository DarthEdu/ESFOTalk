import 'package:appwrite/models.dart';
import 'package:esfotalk_app/apis/auth_api.dart';
import 'package:esfotalk_app/apis/user_api.dart';
import 'package:esfotalk_app/core/utils.dart';
import 'package:esfotalk_app/features/auth/view/signup_view.dart';
import 'package:esfotalk_app/features/home/view/home_view.dart';
import 'package:esfotalk_app/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authControllerProvider = StateNotifierProvider<AuthController, bool>((ref) {
  return AuthController(
    authAPI: ref.watch(authAPIProvider),
    userAPI: ref.watch(userAPIProvider),
    ref: ref,
  );
});

final authStateChangeProvider = StreamProvider((ref) {
  final authAPI = ref.watch(authAPIProvider);
  return authAPI.getAccountEvents();
});

final currentUserAccountProvider = FutureProvider((ref) {
  ref.watch(authStateChangeProvider);
  final authController = ref.watch(authControllerProvider.notifier);
  return authController.currentUser();
});

// CORREGIDO: Ahora carga los datos iniciales y luego escucha los cambios.
final userDetailsProvider = StreamProvider.family((ref, String uid) async* {
  final userAPI = ref.watch(userAPIProvider);

  // 1. Carga y emite los datos iniciales del usuario.
  final document = await userAPI.getUserData(uid);
  yield UserModel.fromMap(document.data);

  // 2. Escucha y emite los cambios en tiempo real.
  final stream = userAPI.getUserDataStream(uid);
  await for (final realtimeEvent in stream) {
    yield UserModel.fromMap(realtimeEvent.payload);
  }
});

final currentUserDetailsProvider = FutureProvider((ref) async {
  final currentUserAccount = await ref.watch(currentUserAccountProvider.future);
  if (currentUserAccount == null) {
    return null;
  }
  final userDetails = await ref.watch(userDetailsProvider(currentUserAccount.$id).future);
  return userDetails;
});

class AuthController extends StateNotifier<bool> {
  final AuthAPI _authAPI;
  final UserAPI _userAPI;
  final Ref _ref;

  AuthController({
    required AuthAPI authAPI,
    required UserAPI userAPI,
    required Ref ref,
  })  : _authAPI = authAPI,
        _userAPI = userAPI,
        _ref = ref,
        super(false);

  Future<User?> currentUser() async {
    final res = await _authAPI.currentUserAccount();
    return res.fold(
      (l) => null,
      (r) => r,
    );
  }

  void signUp({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    state = true;
    final res = await _authAPI.signUp(email: email, password: password);
    state = false;
    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) async {
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
            res2.fold(
              (l) => showSnackBar(context, l.message),
              (r) async {
                await sendVerificationEmail(context);
                showSnackBar(context, 'Cuenta creada. Revisa tu email para verificar.');
                Navigator.pushReplacement(context, HomeView.route());
              },
            );
          },
        );
      },
    );
  }

  void login({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    state = true;
    final res = await _authAPI.login(email: email, password: password);
    state = false;
    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) => Navigator.pushAndRemoveUntil(
        context,
        HomeView.route(),
        (route) => false,
      ),
    );
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
