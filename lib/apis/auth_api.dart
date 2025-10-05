import 'package:appwrite/models.dart';
import 'package:esfotalk_app/core/core.dart';
import 'package:appwrite/appwrite.dart';
import 'package:esfotalk_app/core/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

final authAPIProvider = Provider((ref) {
  final account = ref.watch(appwriteAcccountProvider);
  return AuthAPI(account: account);
});

abstract class IAuthApi {
  FutureEither<User> signUp({required String email, required String password});
}

class AuthAPI implements IAuthApi {
  final Account _account;

  AuthAPI({required Account account}) : _account = account;

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
}
