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
      // ignore: deprecated_member_use
      final document = await _databases.createDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.roarTable,
        documentId: ID.unique(), // Appwrite generará un ID único
        data: roar.toMap(),
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
    // ignore: deprecated_member_use
    final documents = await _databases.listDocuments(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.roarTable,
      queries: [Query.orderDesc('\$createdAt')],
    );
    return documents.documents;
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
      // ignore: deprecated_member_use
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
      // ignore: deprecated_member_use
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
  Future<List<Document>> getRepliesToRoar(String roarId) async {
    // ignore: deprecated_member_use
    final document = await _databases.listDocuments(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.roarTable,
      queries: [Query.equal('repliedTo', roarId)],
    );
    return document.documents;
  }

  @override
  Future<Document> getRoarById(String id) async {
    // ignore: deprecated_member_use
    return _databases.getDocument(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.roarTable,
      documentId: id,
    );
  }
  
  @override
  Future<List<Document>> getUserRoars(String uid) async{
    // ignore: deprecated_member_use
    final documents = await _databases.listDocuments(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.roarTable,
      queries: [Query.equal('uid', uid)],
    );
    return documents.documents;
  }
  
  @override
  Future<List<Document>> getRoarsByHashtag(String hashtag) async{
    // ignore: deprecated_member_use
    final documents = await _databases.listDocuments(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.roarTable,
      queries: [Query.search('hashtags', hashtag)],
    );
    return documents.documents;
  }
}
