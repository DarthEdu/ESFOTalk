import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:esfotalk_app/common/error_page.dart';
import 'package:esfotalk_app/common/loading_page.dart';
import 'package:esfotalk_app/constants/assets_constant.dart';
import 'package:esfotalk_app/features/auth/controller/auth_controller.dart';
import 'package:esfotalk_app/features/roar/widgets/roar_card.dart';
import 'package:esfotalk_app/features/user_profile/controller/user_profile_controller.dart';
import 'package:esfotalk_app/features/user_profile/view/edit_profile_view.dart';
import 'package:esfotalk_app/features/user_profile/widgets/follow_count.dart';
import 'package:esfotalk_app/models/user_model.dart';
import 'package:esfotalk_app/theme/theme.dart';

class UserProfile extends ConsumerWidget {
  final UserModel user;
  const UserProfile({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserDetailsProvider).value;

    return currentUser == null
        ? const Loader()
        : NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  expandedHeight: 150,
                  floating: true,
                  snap: true,
                  flexibleSpace: Stack(
                    children: [
                      Positioned.fill(
                        child: user.bannerPic.isEmpty
                            ? Container(color: Pallete.vinoColor)
                            : Image.network(
                                user.bannerPic,
                                fit: BoxFit.fitWidth,
                              ),
                      ),
                      Positioned(
                        bottom: 0,
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(user.profilePic),
                          radius: 45,
                        ),
                      ),
                      Container(
                        alignment: Alignment.bottomRight,
                        margin: const EdgeInsets.all(20),
                        child: OutlinedButton(
                          onPressed: () {
                            if (currentUser.uid == user.uid) {
                              // editar perfil
                              Navigator.push(context, EditProfileView.route());
                            } else {
                              ref
                                  .read(userProfileControllerProvider.notifier)
                                  .followUser(
                                    user: user,
                                    context: context,
                                    currentUser: currentUser,
                                  );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: const BorderSide(color: Pallete.whiteColor),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 25),
                          ),
                          child: Text(
                            currentUser.uid == user.uid
                                ? 'Editar Perfil'
                                : currentUser.following.contains(user.uid)
                                ? 'Dejar de seguir'
                                : 'Seguir',
                            style: const TextStyle(color: Pallete.whiteColor),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(8),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      Row(
                        children: [
                          Text(
                            user.name,
                            style: const TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (user.isDragonred)
                            Padding(
                              padding: const EdgeInsets.only(left: 3.0),
                              child: SvgPicture.asset(
                                AssetsConstants.verifiedIcon,
                              ),
                            ),
                        ],
                      ),
                      Text(
                        '@${user.name}',
                        style: const TextStyle(
                          fontSize: 17,
                          color: Pallete.greyColor,
                        ),
                      ),
                      Text(user.bio, style: const TextStyle(fontSize: 17)),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          FollowCount(
                            count: user.following.length,
                            text: 'Siguiendo',
                          ),
                          const SizedBox(width: 15),
                          FollowCount(
                            count: user.followers.length,
                            text: 'Seguidores',
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      const Divider(color: Pallete.whiteColor),
                    ]),
                  ),
                ),
              ];
            },
            body: ref
                .watch(getUserRoarsProvider(user.uid))
                .when(
                  data: (roars) {
                    return ListView.builder(
                      itemCount: roars.length,
                      itemBuilder: (BuildContext context, int index) {
                        final roar = roars[index];
                        return RoarCard(roar: roar);
                      },
                    );
                  },
                  error: (error, st) => ErrorText(error: error.toString()),
                  loading: () => const Loader(),
                ),
          );
  }
}
