import 'package:esfotalk_app/apis/notification_api.dart';
import 'package:esfotalk_app/constants/appwrite_constants.dart';
import 'package:esfotalk_app/core/enums/notification_type_enum.dart';
import 'package:esfotalk_app/models/notification_model.dart' as model;
import 'package:flutter_riverpod/flutter_riverpod.dart';

final notificationControllerProvider =
    StateNotifierProvider<NotificationController, bool>((ref) {
  return NotificationController(
    notificationAPI: ref.watch(NotificationAPIProvider),
  );
});

// Proveedor de stream para las notificaciones de un usuario
final getNotificationProvider = StreamProvider.family<List<model.Notification>, String>((ref, uid) async* {
  final notificationController =
      ref.watch(notificationControllerProvider.notifier);
  // 1. Carga inicial de notificaciones
  final initialNotifications = await notificationController.getNotification(uid);
  yield initialNotifications;

  // 2. Escucha los cambios y vuelve a cargar si son para este usuario
  final stream = ref.watch(NotificationAPIProvider).getLatestNotification();
  await for (final event in stream) {
    if (event.events.contains(
      'databases.*.collections.${AppwriteConstants.notificationTable}.documents.*.create',
    )) {
      final notification = model.Notification.fromMap(event.payload);
      if (notification.uid == uid) {
        // Vuelve a cargar la lista completa para asegurar el orden y consistencia
        final updatedNotifications = await notificationController.getNotification(uid);
        yield updatedNotifications;
      }
    }
  }
});

class NotificationController extends StateNotifier<bool> {
  final NotificationAPI _notificationAPI;

  NotificationController({required NotificationAPI notificationAPI})
      : _notificationAPI = notificationAPI,
        super(false);

  void createNotification({
    required String text,
    required String postId,
    required String uid,
    required NotificationType notificationType,
  }) async {
    final notification = model.Notification(
      text: text,
      postId: postId,
      id: '',
      uid: uid,
      notificationType: notificationType,
    );
    final res = await _notificationAPI.createNotification(notification);
    res.fold((l) => null, (r) => null);
  }

  Future<List<model.Notification>> getNotification(String uid) async {
    final notifications = await _notificationAPI.getNotification(uid);
    return notifications
        .map((e) => model.Notification.fromMap(e.data))
        .toList();
  }
}
