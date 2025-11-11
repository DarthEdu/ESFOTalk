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
      final payload = roar.toMap();
      print('🔵 [DEBUG] shareRoar - Payload a enviar: $payload');
      print(
        '🔵 [DEBUG] shareRoar - DB: ${AppwriteConstants.databaseId}, Collection: ${AppwriteConstants.roarTable}',
      );

      // ignore: deprecated_member_use
      final document = await _databases.createDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.roarTable,
        documentId: roar.id.isEmpty ? ID.unique() : roar.id,
        data: payload,
        // Establece permisos explícitos para asegurar visibilidad en el feed
        permissions: [
          Permission.read(Role.users()),
          Permission.write(Role.user(roar.uid)),
          Permission.update(Role.user(roar.uid)),
          Permission.delete(Role.user(roar.uid)),
        ],
      );

      print('✅ [DEBUG] shareRoar - Documento creado con ID: ${document.$id}');
      // Verificación inmediata de lectura para detectar problemas de permisos cuando no hay hashtags
      try {
        // ignore: deprecated_member_use
        final fetched = await _databases.getDocument(
          databaseId: AppwriteConstants.databaseId,
          collectionId: AppwriteConstants.roarTable,
          documentId: document.$id,
        );
        print('🔍 [DEBUG] shareRoar - Lectura inmediata OK (permiso READ)');
        if ((fetched.data['hashtags'] is List) &&
            (fetched.data['hashtags'] as List).isEmpty) {
          print(
            'ℹ️  [DEBUG] shareRoar - Documento sin hashtags leído correctamente.',
          );
        }
      } on AppwriteException catch (readErr) {
        print(
          '🚫 [DEBUG] shareRoar - No se pudo leer inmediatamente tras crear. Posible configuración de permisos dependiente de hashtags. Detalle: ${readErr.message}',
        );
      }
      return right(document);
    } on AppwriteException catch (e, st) {
      print(
        '❌ [DEBUG] shareRoar - AppwriteException: ${e.message}, Code: ${e.code}, Type: ${e.type}',
      );
      return left(Failure(e.message ?? 'Some unexpected error occurred', st));
    } catch (e, st) {
      print('❌ [DEBUG] shareRoar - Error genérico: $e');
      return left(Failure(e.toString(), st));
    }
  }

  @override
  Future<List<Document>> getRoars() async {
    // Forzamos el ordenamiento por atributo del sistema $createdAt para evitar depender del schema
    // Usamos cadena cruda para no interpolar accidentalmente $createdAt
    print('🔵 [DEBUG] getRoars - Listando por \$createdAt desc, limit 100');
    try {
      // ignore: deprecated_member_use
      final documents = await _databases.listDocuments(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.roarTable,
        queries: [Query.orderDesc(r'$createdAt'), Query.limit(100)],
      );
      print('✅ [DEBUG] getRoars - Total: ${documents.total}');
      if (documents.total == 0) {
        print(
          '⚠️  [DEBUG] getRoars - No hay documentos. ¿Se están creando correctamente? Revisa permisos y collectionId.',
        );
      } else {
        final sample = documents.documents.take(3).map((d) => d.$id).toList();
        print('📄 [DEBUG] getRoars - Primeros IDs: $sample');
      }
      return documents.documents;
    } on AppwriteException catch (e) {
      print('❌ [DEBUG] getRoars - AppwriteException: ${e.message} (${e.code})');
      return [];
    } catch (e) {
      print('❌ [DEBUG] getRoars - Error inesperado: $e');
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
    // ignore: deprecated_member_use
    return _databases.getDocument(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.roarTable,
      documentId: id,
    );
  }

  @override
  Future<List<Document>> getUserRoars(String uid) async {
    // ignore: deprecated_member_use
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
    // ignore: deprecated_member_use
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
