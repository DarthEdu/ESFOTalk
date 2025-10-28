import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:esfotalk_app/constants/appwrite_constants.dart';
import 'package:esfotalk_app/core/failure.dart';
import 'package:esfotalk_app/core/providers.dart';
import 'package:esfotalk_app/core/type_defs.dart';
import 'package:esfotalk_app/models/roar_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

final roarAPIProvider = Provider((ref) {
  return RoarAPI(databases: ref.watch(appwriteDatabaseProvider));
});

abstract class IRoarApi {
  FutureEitherVoid shareRoar(Roar roar);
  Future<List<Document>> getRoars();
}

class RoarAPI implements IRoarApi {
  final Databases _databases;
  RoarAPI({required Databases databases}) : _databases = databases;

  @override
  FutureEitherVoid shareRoar(Roar roar) async {
    try {
      // ignore: deprecated_member_use
      await _databases.createDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.roarTable,
        documentId: ID.unique(),
        data: roar.toMap(),
      );
      return right(null);
    } on AppwriteException catch (e, st) {
      return left(Failure(e.message ?? 'Some unexpected error occurred', st));
    } catch (e, st) {
      return left(Failure(e.toString(), st));
    }
  }

  @override
  Future<List<Document>> getRoars() async {
    final documents = await _databases.listDocuments(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.roarTable,
      queries: [
        Query.orderDesc('\$createdAt'),
      ],
    );
    return documents.documents;
  }
}
