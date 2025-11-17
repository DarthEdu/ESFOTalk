import 'package:esfotalk_app/constants/assets_constant.dart';
import 'package:esfotalk_app/features/explore/view/explore_view.dart';
import 'package:esfotalk_app/features/notifications/views/notification_view.dart';
import 'package:esfotalk_app/features/roar/widgets/roar_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:esfotalk_app/theme/pallete.dart';

class UiConstants {
  static AppBar appBar() {
    return AppBar(
      backgroundColor: Pallete.backgroundColor,
      title: SvgPicture.asset(
        AssetsConstants.dragonLogo,
        colorFilter: const ColorFilter.mode(Pallete.vinoColor, BlendMode.srcIn),
        height: 30,
      ),
      centerTitle: true,
      automaticallyImplyLeading:
          false, // Evita flecha back en pestañas principales
    );
  }

  static const List<Widget> bottomTabBarPages = [
    RoarList(),
    ExploreView(),
    NotificationView(),
  ];
}
