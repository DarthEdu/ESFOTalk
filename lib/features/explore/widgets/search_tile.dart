import 'package:esfotalk_app/features/user_profile/view/user_profile_view.dart';
import 'package:esfotalk_app/models/user_model.dart';
import 'package:esfotalk_app/theme/pallete.dart';
import 'package:flutter/material.dart';

class SearchTile extends StatelessWidget {
  final UserModel userModel;

  const SearchTile({super.key, required this.userModel});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        Navigator.push(context, UserProfileView.route(userModel));
      },
      leading: CircleAvatar(
        backgroundImage: NetworkImage(userModel.profilePic),
        radius: 30,
        backgroundColor: Pallete.greyColor,
      ),
      title: Text(
        userModel.name,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '@${userModel.name}',
            style: const TextStyle(fontSize: 16, color: Pallete.greyColor),
          ),
          const SizedBox(height: 2),
          Text(
            userModel.bio,
            style: const TextStyle(color: Pallete.whiteColor),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
