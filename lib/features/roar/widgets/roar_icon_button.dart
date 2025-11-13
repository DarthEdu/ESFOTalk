import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:esfotalk_app/theme/pallete.dart';

class RoarIconButton extends StatelessWidget {
  final String pathName;
  final String text;
  final VoidCallback onTap;
  const RoarIconButton({
    Key? key,
    required this.pathName,
    required this.text,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          SvgPicture.asset(
            pathName,
            colorFilter: const ColorFilter.mode(
              Pallete.greyColor,
              BlendMode.srcIn,
            ),
          ),
          Container(
            margin: const EdgeInsets.all(6),
            child: Text(text, style: const TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
