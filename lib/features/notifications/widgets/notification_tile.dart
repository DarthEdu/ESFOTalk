import 'package:esfotalk_app/core/enums/notification_type_enum.dart';
import 'package:esfotalk_app/constants/assets_constant.dart';
import 'package:esfotalk_app/models/notification_model.dart' as model;
import 'package:esfotalk_app/theme/pallete.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class NotificationTile extends StatelessWidget {
  final model.Notification notification;
  const NotificationTile({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: notification.notificationType == NotificationType.follow
          ? const Icon(Icons.person, color: Pallete.vinoColor)
          : notification.notificationType == NotificationType.like
          ? SvgPicture.asset(
              AssetsConstants.likeFilledIcon,
              color: Pallete.redColor,
              height: 20,
            )
          : notification.notificationType == NotificationType.reroar
          ? SvgPicture.asset(
              AssetsConstants.retweetIcon,
              color: Pallete.whiteColor,
              height: 20,
            )
          : null,
          title: Text(
            notification.text
          ),
    );
  }
}
