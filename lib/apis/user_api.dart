import 'package:appwrite/appwrite.dart';
import 'package:esfotalk_app/constants/constants.dart';
import 'package:esfotalk_app/core/failure.dart';
import 'package:esfotalk_app/core/providers.dart';
import 'package:esfotalk_app/core/type_defs.dart';
import 'package:esfotalk_app/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

final userAPIProvider = Provider((ref) {
  return UserAPI(databases: ref.watch(appwriteDatabaseProvider));
});

abstract class IUserApi {
  /// Obtiene la cuenta del usuario actual
  FutureEitherVoid saveUserData({required UserModel userModel});
}

class UserAPI implements IUserApi {
  final Databases _databases;
  UserAPI({required Databases databases}) : _databases = databases;
  @override
  FutureEitherVoid saveUserData({required UserModel userModel}) async {
    try{
      // ignore: deprecated_member_use
      await _databases.createDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.usersTable,
        documentId: ID.unique(),
        data: userModel.toMap(),
      );
      return right(null);
    } on AppwriteException catch (e, st) {
      return left(Failure(e.message ?? 'Some unexpected error occurred', st));
    } catch (e, st) {
      return left(Failure(e.toString(), st));
    }
  }
}
