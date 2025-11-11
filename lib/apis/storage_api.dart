import 'dart:io';
import 'dart:typed_data';

import 'package:appwrite/appwrite.dart';
import 'package:esfotalk_app/constants/appwrite_constants.dart';
import 'package:esfotalk_app/core/providers.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

final storageAPIProvider = Provider((ref) {
  return StorageAPI(storage: ref.watch(appwriteStorageProvider));
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
      imageLinks.add(AppwriteConstants.imageUrl(uploadedImage.$id));
    }
    return imageLinks;
  }

  // Descarga bytes para mostrar imágenes autenticadas sin confiar en modo admin.
  Future<Uint8List?> getImageBytesFromUrl(String url) async {
    try {
      // Extraer fileId de la URL esperada .../files/<fileId>/view?
      final uri = Uri.parse(url);
      final segments = uri.pathSegments;
      final filesIndex = segments.indexOf('files');
      if (filesIndex == -1 || filesIndex + 1 >= segments.length) return null;
      final fileId = segments[filesIndex + 1];
      // ignore: deprecated_member_use
      final result = await _storage.getFileDownload(
        bucketId: AppwriteConstants.imagesBucket,
        fileId: fileId,
      );
      return result;
    } catch (_) {
      return null;
    }
  }
}
