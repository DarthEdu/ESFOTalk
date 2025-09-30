import 'package:appwrite/appwrite.dart' as model;
import 'package:esfotalk_app/core/core.dart';
import 'package:appwrite/appwrite.dart';

abstract class IAuthApi {
  FutureEither<model.Account> signUp({
    required String email,
    required String password,
  });
}

class AuthAPI implements IAuthApi {
  final Account _account;
  @override
  FutureEither<model.Account> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _account.create(
        userId: ID.unique(),
        email: email,
        password: password,
      );
      return Right(user);
    } on AppwriteException catch (e, st) {
      return Left(Failure(e.message ?? 'Some unexpected error occurred', st));
    } catch (e, st) {
      return Left(Failure(e.toString(), st));
    }
  }
}
