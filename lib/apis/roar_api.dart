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
  return RoarAPI(
    databases: ref.watch(appwriteDatabaseProvider),
    realtime: ref.watch(appwriteRealtimeProvider),
  );
});

abstract class IRoarApi {
  FutureEither<Document> shareRoar(Roar roar);
  Future<List<Document>> getRoars();
  Stream<RealtimeMessage> getLatestRoars();
  FutureEither<Document> likeRoar(Roar roar);
  FutureEither<Document> updateReshareCount(Roar roar);
  FutureEither<Document> updateCommentIds(Roar roar);
  Future<List<Document>> getRepliesToRoar(String roarId);
  Future<Document> getRoarById(String id);
  Future<List<Document>> getUserRoars(String uid);
  Future<List<Document>> getRoarsByHashtag(String hashtag);
}

class RoarAPI implements IRoarApi {
  final Databases _databases;
  final Realtime _realtime;

  RoarAPI({required Databases databases, required Realtime realtime})
    : _databases = databases,
      _realtime = realtime;

  @override
  FutureEither<Document> shareRoar(Roar roar) async {
    try {
      final payload = roar.toMap();
      // TODO: Migrar a TablesDB.createRow (API nueva) cuando se actualice Appwrite SDK.
      final document = await _databases.createDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.roarTable,
        documentId: roar.id.isEmpty ? ID.unique() : roar.id,
        data: payload,
        permissions: [
          Permission.read(Role.users()),
          Permission.write(Role.user(roar.uid)),
          Permission.update(Role.user(roar.uid)),
          Permission.delete(Role.user(roar.uid)),
        ],
      );
      return right(document);
    } on AppwriteException catch (e, st) {
      return left(Failure(e.message ?? 'Some unexpected error occurred', st));
    } catch (e, st) {
      return left(Failure(e.toString(), st));
    }
  }

  @override
  Future<List<Document>> getRoars() async {
    try {
      final documents = await _databases.listDocuments(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.roarTable,
        queries: [Query.orderDesc(r'$createdAt'), Query.limit(100)],
      );
      return documents.documents;
    } on AppwriteException catch (e) {
      print(
        'AppwriteException al obtener roars: ${e.message} - Code: ${e.code}',
      );
      return [];
    } catch (e) {
      print('Error al obtener roars: $e');
      return [];
    }
  }

  @override
  Stream<RealtimeMessage> getLatestRoars() {
    return _realtime.subscribe([
      'databases.${AppwriteConstants.databaseId}.collections.${AppwriteConstants.roarTable}.documents',
    ]).stream;
  }

  @override
  FutureEither<Document> likeRoar(Roar roar) async {
    try {
      final document = await _databases.updateDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.roarTable,
        documentId: roar.id,
        data: {'likes': roar.likes},
      );
      return right(document);
    } on AppwriteException catch (e, st) {
      return left(Failure(e.message ?? 'Some unexpected error occurred', st));
    } catch (e, st) {
      return left(Failure(e.toString(), st));
    }
  }

  @override
  FutureEither<Document> updateReshareCount(Roar roar) async {
    try {
      final document = await _databases.updateDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.roarTable,
        documentId: roar.id,
        data: {'reshareCount': roar.reshareCount},
      );
      return right(document);
    } on AppwriteException catch (e, st) {
      return left(Failure(e.message ?? 'Some unexpected error occurred', st));
    } catch (e, st) {
      return left(Failure(e.toString(), st));
    }
  }

  @override
  FutureEither<Document> updateCommentIds(Roar roar) async {
    try {
      final document = await _databases.updateDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.roarTable,
        documentId: roar.id,
        data: {'commentIds': roar.commentIds},
      );
      return right(document);
    } on AppwriteException catch (e, st) {
      return left(Failure(e.message ?? 'Some unexpected error occurred', st));
    } catch (e, st) {
      return left(Failure(e.toString(), st));
    }
  }

  @override
  Future<List<Document>> getRepliesToRoar(String roarId) async {
    final document = await _databases.listDocuments(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.roarTable,
      queries: [
        Query.equal('repliedTo', roarId),
        Query.orderDesc(r'$createdAt'),
        Query.limit(100),
      ],
    );
    return document.documents;
  }

  @override
  Future<Document> getRoarById(String id) async {
    return _databases.getDocument(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.roarTable,
      documentId: id,
    );
  }

  @override
  Future<List<Document>> getUserRoars(String uid) async {
    final documents = await _databases.listDocuments(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.roarTable,
      queries: [
        Query.equal('uid', uid),
        Query.orderDesc(r'$createdAt'),
        Query.limit(100),
      ],
    );
    return documents.documents;
  }

  @override
  Future<List<Document>> getRoarsByHashtag(String hashtag) async {
    final documents = await _databases.listDocuments(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.roarTable,
      queries: [
        Query.search('hashtags', hashtag),
        Query.orderDesc(r'$createdAt'),
        Query.limit(100),
      ],
    );
    return documents.documents;
  }
}
