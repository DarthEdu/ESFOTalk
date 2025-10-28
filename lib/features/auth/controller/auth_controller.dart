import 'dart:async';

import 'package:appwrite/models.dart';
import 'package:esfotalk_app/apis/auth_api.dart';
import 'package:esfotalk_app/apis/user_api.dart';
import 'package:esfotalk_app/core/core.dart';
import 'package:esfotalk_app/core/utils.dart';
import 'package:esfotalk_app/features/home/view/home_view.dart';
import 'package:esfotalk_app/models/user_model.dart';
import 'package:flutter/material.dart' hide CarouselController;
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authControllerProvider = StateNotifierProvider<AuthController, bool>((
  ref,
) {
  return AuthController(
    authAPI: ref.watch(authAPIProvider),
    userAPI: ref.watch(userAPIProvider),
  );
});

final currentUserAccountProvider = FutureProvider((ref) async {
  final authController = ref.watch(authControllerProvider.notifier);
  final userEither = await authController.currentUserAccount();
  // Devuelve el usuario si es exitoso, o null si hay un error.
  return userEither.fold((l) => null, (r) => r);
});

final currentUserDetailsProvider = FutureProvider((ref) async {
  final currentUserAccount = await ref.watch(currentUserAccountProvider.future);
  if (currentUserAccount == null) return null;
  final userDetails = await ref.watch(
    userDetailsProvider(currentUserAccount.$id).future,
  );
  return userDetails;
});

final userDetailsProvider = FutureProvider.family((ref, String uid) {
  final authController = ref.watch(authControllerProvider.notifier);
  return authController.getUserData(uid);
});

class AuthController extends StateNotifier<bool> {
  final AuthAPI _authAPI;
  final UserAPI _userAPI;
  AuthController({required AuthAPI authAPI, required UserAPI userAPI})
    : _authAPI = authAPI,
      _userAPI = userAPI,
      super(false);

  Future<void> signUp({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    state = true;
    final res = await _authAPI.signUp(email: email, password: password);
    state = false;
    await res.fold(
      (l) {
        if (context.mounted) {
          showSnackBar(context, l.message);
        }
      },
      (r) async {
        // Iniciar sesión automáticamente después del registro
        final loginRes = await _authAPI.login(email: email, password: password);

        await loginRes.fold(
          (l) {
            if (context.mounted) {
              showSnackBar(context, 'Error al iniciar sesión: ${l.message}');
            }
          },
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
              (l) {
                if (context.mounted) {
                  showSnackBar(context, l.message);
                }
              },
              (r) async {
                // Enviar email de verificación con sesión activa
                await sendVerificationEmail(context);
                if (context.mounted) {
                  showSnackBar(
                    context,
                    'Cuenta creada exitosamente. Revisa tu email para verificar tu cuenta.',
                  );
                  Navigator.push(context, HomeView.route());
                }
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
      (l) {
        if (context.mounted) {
          showSnackBar(context, l.message);
        }
      },
      (r) {
        if (context.mounted) {
          Navigator.push(context, HomeView.route());
        }
      },
    );
  }

  FutureEither<User> currentUserAccount() {
    return _authAPI.currentUserAccount();
  }

  Future<UserModel> getUserData(String uid) async {
    final document = await _userAPI.getUserData(uid);
    final updatedUser = UserModel.fromMap(document.data);
    return updatedUser;
  }

  Future<void> sendVerificationEmail(BuildContext context) async {
    state = true;
    final res = await _authAPI.sendVerificationEmail();
    state = false;
    res.fold(
      (l) {
        if (context.mounted) {
          showSnackBar(context, l.message);
        }
      },
      (r) {
        if (context.mounted) {
          showSnackBar(context, 'Email de verificación enviado');
        }
      },
    );
  }

  Future<void> sendPasswordReset({
    required String email,
    required BuildContext context,
  }) async {
    state = true;
    final res = await _authAPI.sendPasswordReset(email: email);
    state = false;
    res.fold(
      (l) {
        if (context.mounted) {
          showSnackBar(context, l.message);
        }
      },
      (r) {
        if (context.mounted) {
          showSnackBar(
            context,
            'Email de recuperación enviado. Revisa tu bandeja de entrada.',
          );
        }
      },
    );
  }
}
