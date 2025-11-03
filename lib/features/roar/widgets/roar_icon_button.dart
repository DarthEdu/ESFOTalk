import 'package:esfotalk_app/theme/pallete.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class RoarIconButton extends StatelessWidget {
  final String pathName;
  final String text;
  final VoidCallback onTap;

  const RoarIconButton({
    super.key,
    required this .pathName,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          SvgPicture.asset(pathName, color: Pallete.greyColor),
          Container(
            margin: const EdgeInsets.only(left: 2),
            child: Text(
              text,
              style: const TextStyle(
                color: Pallete.greyColor,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      
    );
  }
}
