import 'package:esfotalk_app/apis/notification_api.dart';
import 'package:esfotalk_app/core/enums/notification_type_enum.dart';
import 'package:esfotalk_app/models/notification_model.dart' as model;
import 'package:flutter_riverpod/flutter_riverpod.dart';

final notificationControllerProvider =
    StateNotifierProvider<NotificationController, bool>((ref) {
      return NotificationController(
        notificationAPI: ref.watch(NotificationAPIProvider),
      );
    });

final getLatestNotificationProvider = StreamProvider((ref) {
  final notificationAPI = ref.watch(NotificationAPIProvider);
  return notificationAPI.getLatestNotification();
});

final getNotificationProvider = FutureProvider.family((ref, String uid) async {
  final notificationController = ref.watch(
    notificationControllerProvider.notifier,
  );
  return notificationController.getNotification(uid);
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
    // ignore: avoid_print
    res.fold((l) => null, (r) => null);
  }

  Future<List<model.Notification>> getNotification(String uid) async {
    final notifications = await _notificationAPI.getNotification(uid);
    return notifications
        .map((e) => model.Notification.fromMap(e.data))
        .toList();
  }
}
