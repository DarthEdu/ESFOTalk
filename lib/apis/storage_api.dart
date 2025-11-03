import 'dart:io' as io;

import 'package:appwrite/appwrite.dart';
import 'package:esfotalk_app/constants/appwrite_constants.dart';
import 'package:esfotalk_app/core/failure.dart';
import 'package:esfotalk_app/core/providers.dart';
import 'package:esfotalk_app/core/type_defs.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

final storageAPIProvider = Provider((ref) {
  return StorageAPI(storage: ref.watch(appwriteStorageProvider));
});

class StorageAPI {
  final Storage _storage;
  StorageAPI({required Storage storage}) : _storage = storage;

  FutureEither<List<String>> uploadImages(List<io.File> files) async {
    List<String> imageLinks = [];
    try {
      for (final file in files) {
        final uploadedFile = await _storage.createFile(
          bucketId: AppwriteConstants.imagesBucket,
          fileId: ID.unique(),
          file: InputFile.fromPath(
            path: file.path,
            filename: file.path.split('/').last,
          ),
        );
        imageLinks.add(AppwriteConstants.imageUrl(uploadedFile.$id));
      }
      return right(imageLinks);
    } on AppwriteException catch (e, st) {
      return left(Failure(e.message ?? 'Error inesperado al subir imagen', st));
    } catch (e, st) {
      return left(Failure(e.toString(), st));
    }
  }
}
