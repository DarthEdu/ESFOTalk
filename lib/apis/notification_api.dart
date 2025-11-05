import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:esfotalk_app/constants/appwrite_constants.dart';
import 'package:esfotalk_app/core/failure.dart';
import 'package:esfotalk_app/core/providers.dart';
import 'package:esfotalk_app/core/type_defs.dart';
import 'package:esfotalk_app/models/notification_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

// ignore: non_constant_identifier_names
final NotificationAPIProvider = Provider((ref) {
  return NotificationAPI(
    databases: ref.watch(appwriteDatabaseProvider),
    realtime: ref.watch(appwriteRealtimeProvider),
  );
});

abstract class INotificactionAPI {
  FutureEitherVoid createNotification(Notification notification);
  Future<List<Document>> getNotification(String uid);
  Stream<RealtimeMessage> getLatestNotification();
}

class NotificationAPI implements INotificactionAPI {
  final Databases _databases;
  final Realtime _realtime;

  NotificationAPI({required Databases databases, required Realtime realtime})
    : _realtime = realtime,
      _databases = databases;

  @override
  FutureEitherVoid createNotification(Notification notification) async {
    try {
      // ignore: deprecated_member_use
      await _databases.createDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.notificationTable,
        documentId: ID.unique(),
        data: notification.toMap(),
      );
      return right(null);
    } on AppwriteException catch (e, st) {
      return left(Failure(e.message ?? 'Some unexpected error occurred', st));
    } catch (e, st) {
      return left(Failure(e.toString(), st));
    }
  }

  @override
  Future<List<Document>> getNotification(String uid) async {
    // ignore: deprecated_member_use
    final documents = await _databases.listDocuments(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.notificationTable,
      queries: [Query.equal('uid', uid)],
    );
    return documents.documents;
  }

  @override
  Stream<RealtimeMessage> getLatestNotification() {
    return _realtime.subscribe([
      'databases.${AppwriteConstants.databaseId}.collections.${AppwriteConstants.notificationTable}.documents',
    ]).stream;
  }
}
