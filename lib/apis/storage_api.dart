import 'dart:io';

import 'package:appwrite/appwrite.dart';
import 'package:esfotalk_app/constants/appwrite_constants.dart';
import 'package:esfotalk_app/core/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


final storageAPIProvider = Provider((ref) {
  return StorageAPI(
    storage: ref.watch(appwriteStorageProvider),
  );
});

class StorageAPI {
  final Storage _storage;
  StorageAPI({required Storage storage}) : _storage = storage;

  Future<List<String>> uploadImage(List<File> files) async {
    List<String> imageLinks = [];
    for (final file in files) {
      final uploadedImage = await _storage.createFile(
        bucketId: AppwriteConstants.imagesBucket,
        fileId: ID.unique(),
        // CAMBIO: Se envían los bytes del archivo en lugar de solo la ruta
        // para evitar el error 'storage_file_empty'. Esto es más robusto.
        file: InputFile.fromBytes(
          bytes: await file.readAsBytes(),
          filename: file.path.split('/').last, // Obtenemos el nombre del archivo de la ruta
        ),
      );
      imageLinks.add(
        AppwriteConstants.imageUrl(uploadedImage.$id),
      );
    }
    return imageLinks;
  }
}
