import 'package:esfotalk_app/apis/notification_api.dart';
import 'package:esfotalk_app/core/enums/notification_type_enum.dart';
import 'package:esfotalk_app/models/notification_model.dart' as model;
import 'package:flutter_riverpod/flutter_riverpod.dart';

final notificationControllerProvider =
    StateNotifierProvider<NotificationController, bool>((ref) {
      return NotificationController(
        notificationAPI: ref.watch(notificationAPIProvider),
      );
    });

// Proveedor de stream para las notificaciones de un usuario
final getNotificationProvider =
    StreamProvider.family<List<model.Notification>, String>((ref, uid) async* {
      final notificationAPI = ref.watch(notificationAPIProvider);

      // 1. Yield empty list immediately to avoid blocking UI
      List<model.Notification> currentNotifications = [];
      yield currentNotifications;

      // 2. Load initial notifications in background
      try {
        final documents = await notificationAPI.getNotifications(uid);
        currentNotifications = documents
            .map((e) => model.Notification.fromMap(e.data))
            .toList();
        yield currentNotifications;
      } catch (e) {
        // If initial load fails, continue with empty list
      }

      // 3. Listen to changes and update only new notifications
      final stream = notificationAPI.getLatestNotification();

      await for (final event in stream) {
        try {
          // Verify event has correct structure
          if (event.events.isEmpty || event.payload.isEmpty) continue;

          final eventType = event.events.first.split('.').last;

          if (eventType == 'create') {
            final notification = model.Notification.fromMap(event.payload);
            // Only add if it's for this user
            if (notification.uid == uid) {
              // Add to beginning (most recent first)
              currentNotifications = [notification, ...currentNotifications];
              yield currentNotifications;
            }
          }
        } catch (e) {
          // Ignore events that can't be parsed
          continue;
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
    final notifications = await _notificationAPI.getNotifications(uid);
    return notifications
        .map((e) => model.Notification.fromMap(e.data))
        .toList();
  }
}
