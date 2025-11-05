import 'package:esfotalk_app/common/error_page.dart';
import 'package:esfotalk_app/common/loading_page.dart';
import 'package:esfotalk_app/features/auth/controller/auth_controller.dart';
import 'package:esfotalk_app/features/notifications/controller/notification_controller.dart';
import 'package:esfotalk_app/features/notifications/widgets/notification_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationView extends ConsumerWidget {
  const NotificationView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserDetailsProvider).value;
    return Scaffold(
      appBar: AppBar(title: const Text('Notificaciones'), centerTitle: true),
      body: currentUser == null
          ? const Loader()
          : ref.watch(getNotificationProvider(currentUser.uid)).when(
                data: (notifications) {
                  // La lista ya está siempre actualizada por el StreamProvider
                  return ListView.builder(
                    itemCount: notifications.length,
                    itemBuilder: (BuildContext context, index) {
                      final notification = notifications[index];
                      return NotificationTile(notification: notification);
                    },
                  );
                },
                error: (error, stackTrace) =>
                    ErrorText(error: error.toString()),
                loading: () => const Loader(),
              ),
    );
  }
}
