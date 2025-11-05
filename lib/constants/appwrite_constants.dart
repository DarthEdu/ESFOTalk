class AppwriteConstants {
  static const String databaseId = '68c8b85f002a0a29f7d0';
  static const String projectId = '68c8ae740021fc2a363b';
  static const String endPoint = 'https://sfo.cloud.appwrite.io/v1';

  static const String usersTable = '68e2f63000175d727185';
  static const String roarTable = '68f911d100207f0145c9';
  static const String notificationTable = '68f9175d00168d59b2d4';

  static const String imagesBucket = '6900f044000e9dfd367f';

  static String imageUrl(String imageId) =>
      '$endPoint/storage/buckets/$imagesBucket/files/$imageId/view?project=$projectId';
}
