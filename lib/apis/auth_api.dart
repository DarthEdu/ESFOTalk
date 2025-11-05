// API para autenticación con Appwrite
import 'package:esfotalk_app/core/core.dart';
import 'package:appwrite/appwrite.dart';
import 'package:esfotalk_app/core/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:appwrite/models.dart';

final authAPIProvider = Provider((ref) {
  final account = ref.watch(appwriteAccountProvider);
  return AuthAPI(account: account);
});

abstract class IAuthApi {
  /// Registro de usuario
  FutureEither<User> signUp({required String email, required String password});

  /// Inicio de sesión, retorna la sesión creada
  FutureEither<Session> login({
    required String email,
    required String password,
  });

  FutureEither<User> currentUserAccount();

  /// Enviar email de verificación
  FutureEitherVoid sendVerificationEmail();

  /// Enviar email de recuperación de contraseña
  FutureEitherVoid sendPasswordReset({required String email});

  FutureEitherVoid logout();
}

class AuthAPI implements IAuthApi {
  final Account _account;
  AuthAPI({required Account account}) : _account = account;

  @override
  FutureEither<User> currentUserAccount() async {
    try {
      final user = await _account.get();
      return right(user);
    } on AppwriteException catch (e, stackTrace) {
      return left(
        Failure(e.message ?? 'Some unexpected error occurred', stackTrace),
      );
    } catch (e, stackTrace) {
      return left(Failure(e.toString(), stackTrace));
    }
  }

  @override
  FutureEither<User> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _account.create(
        userId: ID.unique(),
        email: email,
        password: password,
      );
      return right(user);
    } on AppwriteException catch (e, stackTrace) {
      return left(
        Failure(e.message ?? 'Some unexpected error occurred', stackTrace),
      );
    } catch (e, stackTrace) {
      return left(Failure(e.toString(), stackTrace));
    }
  }

  /// Inicia sesión y retorna la sesión creada
  @override
  FutureEither<Session> login({
    required String email,
    required String password,
  }) async {
    try {
      final session = await _account.createEmailPasswordSession(
        email: email,
        password: password,
      );
      return right(session);
    } on AppwriteException catch (e, stackTrace) {
      return left(
        Failure(e.message ?? 'Some unexpected error occurred', stackTrace),
      );
    } catch (e, stackTrace) {
      return left(Failure(e.toString(), stackTrace));
    }
  }

  @override
  FutureEitherVoid sendVerificationEmail() async {
    try {
      await _account.createVerification(
        url:
            'https://darthedu.github.io/esfotalk_page_static?type=verification',
      );
      return right(null);
    } on AppwriteException catch (e, stackTrace) {
      return left(
        Failure(
          e.message ?? 'Error al enviar email de verificación',
          stackTrace,
        ),
      );
    } catch (e, stackTrace) {
      return left(Failure(e.toString(), stackTrace));
    }
  }

  @override
  FutureEitherVoid sendPasswordReset({required String email}) async {
    try {
      await _account.createRecovery(
        email: email,
        url: 'https://darthedu.github.io/esfotalk_page_static?type=recovery',
      );
      return right(null);
    } on AppwriteException catch (e, stackTrace) {
      return left(
        Failure(
          e.message ?? 'Error al enviar email de recuperación',
          stackTrace,
        ),
      );
    } catch (e, stackTrace) {
      return left(Failure(e.toString(), stackTrace));
    }
  }
  
  @override
  FutureEitherVoid logout() async{
    try {
        await _account.deleteSession(
        sessionId: 'current'
      );
      return right(null);
    } on AppwriteException catch (e, stackTrace) {
      return left(
        Failure(e.message ?? 'Some unexpected error occurred', stackTrace),
      );
    } catch (e, stackTrace) {
      return left(Failure(e.toString(), stackTrace));
    }
    
  }
}
