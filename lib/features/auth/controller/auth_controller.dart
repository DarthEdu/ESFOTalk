import 'package:appwrite/models.dart';
import 'package:esfotalk_app/apis/auth_api.dart';
import 'package:esfotalk_app/apis/user_api.dart';
import 'package:esfotalk_app/core/utils.dart';
import 'package:esfotalk_app/features/auth/view/login_view.dart';
import 'package:esfotalk_app/features/auth/view/signup_view.dart';
import 'package:esfotalk_app/features/home/view/home_view.dart';
import 'package:esfotalk_app/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authControllerProvider = StateNotifierProvider<AuthController, bool>((
  ref,
) {
  return AuthController(
    ref: ref,
    authAPI: ref.watch(authAPIProvider),
    userAPI: ref.watch(userAPIProvider),
  );
});

// Provider directo para la cuenta actual de Appwrite (sin depender del controller)
final currentUserAccountProvider = FutureProvider((ref) async {
  final authAPI = ref.watch(authAPIProvider);
  return authAPI.currentUserAccount();
});

final userDetailsProvider = FutureProvider.family((ref, String uid) async {
  final userAPI = ref.watch(userAPIProvider);
  final document = await userAPI.getUserData(uid);
  return UserModel.fromMap(document.data);
});

// Provider para obtener el usuario actual usando FutureProvider
// Este provider se usa cuando necesitas obtener el usuario una vez
final currentUserDetailsProvider = FutureProvider((ref) async {
  try {
    // Observar cambios en la cuenta actual
    final currentUserAccount = await ref.watch(
      currentUserAccountProvider.future,
    );

    if (currentUserAccount == null) {
      return null;
    }

    final currentUserId = currentUserAccount.$id;
    final userAPI = ref.watch(userAPIProvider);

    // Obtener los datos del usuario
    try {
      final userDoc = await userAPI.getUserData(currentUserId);
      return UserModel.fromMap(userDoc.data);
    } catch (e) {
      return null;
    }
  } catch (e) {
    return null;
  }
});

// Provider reactivo para el usuario actual con actualizaciones en tiempo real
// Se invalida automáticamente cuando cambia currentUserAccountProvider
final currentUserDetailsStreamProvider = StreamProvider((ref) async* {
  try {
    // Observar cambios en la cuenta actual - se reinicia si cambia
    final currentUserAccount = await ref.watch(
      currentUserAccountProvider.future,
    );

    if (currentUserAccount == null) {
      yield null;
      return;
    }

    final currentUserId = currentUserAccount.$id;
    final userAPI = ref.watch(userAPIProvider);

    // Primero, obtener los datos iniciales
    try {
      final initialDoc = await userAPI.getUserData(currentUserId);
      yield UserModel.fromMap(initialDoc.data);
    } catch (e) {
      // Si no existe el documento o hay error de permisos, yield null
      yield null;
      return; // No continuar con el stream si no hay acceso
    }

    // Luego, escuchar cambios en tiempo real
    await for (final event in userAPI.getUserDataStream(currentUserId)) {
      try {
        yield UserModel.fromMap(event.payload);
      } catch (e) {
        // Ignorar errores de parsing
        continue;
      }
    }
  } catch (e) {
    yield null;
  }
});

class AuthController extends StateNotifier<bool> {
  final Ref _ref;
  final AuthAPI _authAPI;
  final UserAPI _userAPI;

  AuthController({
    required Ref ref,
    required AuthAPI authAPI,
    required UserAPI userAPI,
  }) : _ref = ref,
       _authAPI = authAPI,
       _userAPI = userAPI,
       super(false);

  Future<User?> currentUser() => _authAPI.currentUserAccount();

  // Método para limpiar toda la caché de la aplicación
  void _clearAllCache() {
    // Invalidar providers de autenticación
    _ref.invalidate(currentUserAccountProvider);
    _ref.invalidate(currentUserDetailsProvider);
    _ref.invalidate(currentUserDetailsStreamProvider);
  }

  void signUp({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    state = true;
    final res = await _authAPI.signUp(email: email, password: password);

    await res.fold(
      (l) async {
        state = false;
        showSnackBar(context, l.message, type: SnackBarType.error);
      },
      (r) async {
        // Iniciar sesión inmediatamente después de crear la cuenta
        // Esto es necesario para que Appwrite valide los permisos al guardar el documento
        final loginRes = await _authAPI.login(email: email, password: password);

        await loginRes.fold(
          (l) async {
            state = false;
            showSnackBar(
              context,
              'Error al iniciar sesión: ${l.message}',
              type: SnackBarType.error,
            );
          },
          (session) async {
            // Ahora que hay sesión activa, guardar el usuario en la BD
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
            state = false;

            res2.fold(
              (l) => showSnackBar(context, l.message, type: SnackBarType.error),
              (r) {
                // Cerrar sesión para que el usuario inicie sesión manualmente
                _authAPI.logout();

                // Cuenta creada exitosamente, redirigir al login
                showSnackBar(
                  context,
                  'Cuenta creada exitosamente. Por favor, inicia sesión.',
                  type: SnackBarType.success,
                );
                Navigator.pushReplacement(context, LoginView.route());
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
    res.fold((l) => showSnackBar(context, l.message), (r) {
      // Limpiar toda la caché antes de navegar
      _clearAllCache();
      // Usar pushAndRemoveUntil para eliminar completamente la pantalla de login y evitar flecha de retroceso
      Future.delayed(const Duration(milliseconds: 80), () {
        Navigator.pushAndRemoveUntil(
          context,
          HomeView.route(),
          (route) => false,
        );
      });
    });
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
    // Limpiar caché ANTES de cerrar sesión
    _clearAllCache();

    final res = await _authAPI.logout();
    res.fold((l) => showSnackBar(context, l.message), (r) {
      // Pequeño delay para asegurar que la invalidación se complete
      Future.delayed(const Duration(milliseconds: 100), () {
        Navigator.pushAndRemoveUntil(
          context,
          SignUpView.route(),
          (route) => false,
        );
      });
    });
  }

  Future<UserModel> getUserData(String uid) async {
    final document = await _userAPI.getUserData(uid);
    return UserModel.fromMap(document.data);
  }
}
