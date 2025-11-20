import 'package:appwrite/appwrite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:esfotalk_app/constants/constants.dart';

final appwriteClientProvider = Provider((ref) {
  final client = Client()
      .setEndpoint(AppwriteConstants.endPoint)
      .setProject(AppwriteConstants.projectId);
  // Nota: setSelfSigned(status: true) solo se usa cuando tu instancia Appwrite
  // corre en local con un certificado autofirmado (self-signed). En Appwrite Cloud
  // el certificado es válido (CA pública), por lo que NO debe activarse.
  return client;
});

final appwriteAccountProvider = Provider((ref) {
  final client = ref.watch(appwriteClientProvider);
  return Account(client);
});

final appwriteDatabaseProvider = Provider((ref) {
  final client = ref.watch(appwriteClientProvider);
  return Databases(client);
});

final appwriteStorageProvider = Provider((ref) {
  final client = ref.watch(appwriteClientProvider);
  return Storage(client);
});

final appwriteRealtimeProvider = Provider((ref) {
  final client = ref.watch(appwriteClientProvider);
  return Realtime(client);
});
