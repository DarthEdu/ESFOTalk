import 'dart:io';

import 'package:appwrite/appwrite.dart';
import 'package:esfotalk_app/constants/appwrite_constants.dart';
import 'package:esfotalk_app/core/providers.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

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
      // 1. Comprimir y redimensionar la imagen
      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        '${(await getTemporaryDirectory()).path}/${file.path.split('/').last}',
        minWidth: 1080,
        minHeight: 1080,
        quality: 85,
      );

      if (compressedFile == null) {
        continue; // Si la compresión falla, se omite el archivo
      }

      // 2. Subir el archivo comprimido
      final uploadedImage = await _storage.createFile(
        bucketId: AppwriteConstants.imagesBucket,
        fileId: ID.unique(),
        file: InputFile.fromBytes(
          bytes: await File(compressedFile.path).readAsBytes(),
          filename: compressedFile.path.split('/').last,
        ),
      );
      imageLinks.add(
        AppwriteConstants.imageUrl(uploadedImage.$id),
      );
    }
    return imageLinks;
  }
}
