import 'package:esfotalk_app/common/error_page.dart';
import 'package:esfotalk_app/common/loading_page.dart';
import 'package:esfotalk_app/constants/appwrite_constants.dart';
import 'package:esfotalk_app/features/auth/controller/auth_controller.dart';
import 'package:esfotalk_app/features/notifications/controller/notification_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:esfotalk_app/models/notification_model.dart' as model;

class NotificationView extends ConsumerWidget {
  const NotificationView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserDetailsProvider).value;
    return Scaffold(
      appBar: AppBar(title: const Text('Notificaciones'), centerTitle: true),
      body: currentUser == null
          ? const Loader()
          : ref
                .watch(getNotificationProvider(currentUser.uid))
                .when(
                  data: (notifications) {
                    return ref
                        .watch(getLatestNotificationProvider)
                        .when(
                          data: (data) {
                            if (data.events.contains(
                              'databases.*.collections.${AppwriteConstants.notificationTable}.documents.*.create',
                            )) {
                              final latestNotification =
                                  model.Notification.fromMap(data.payload);
                                  if(latestNotification.uid == currentUser.uid){
                                    notifications.insert(0, latestNotification);
                                  }
                            }
                            return ListView.builder(
                              itemCount: notifications.length,
                              itemBuilder: (BuildContext context, int index) {
                                final notification = notifications[index];
                                return Text(notification.toString());
                              },
                            );
                          },
                          error: (error, stackTrace) =>
                              ErrorText(error: error.toString()),
                          loading: () {
                            return ListView.builder(
                              itemCount: notifications.length,
                              itemBuilder: (BuildContext context, int index) {
                                final notification = notifications[index];
                                return Text(notification.toString());
                              },
                            );
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
