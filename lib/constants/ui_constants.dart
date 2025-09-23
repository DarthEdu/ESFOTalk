import 'package:esfotalk_app/constants/assets_constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:esfotalk_app/theme/pallete.dart';

class UiConstants {
  static AppBar appBar() {
    return AppBar(
      title: SvgPicture.asset(
        AssetsConstants.dragonLogo,
        // ignore: deprecated_member_use
        color: Pallete.vinoColor,
        height: 30,
      ),
      centerTitle: true,
    );
  }
}
