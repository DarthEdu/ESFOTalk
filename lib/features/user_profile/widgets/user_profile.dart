import 'package:esfotalk_app/common/error_page.dart';
import 'package:esfotalk_app/common/loading_page.dart';
import 'package:esfotalk_app/constants/appwrite_constants.dart';
import 'package:esfotalk_app/features/auth/controller/auth_controller.dart';
import 'package:esfotalk_app/features/roar/controller/roar_controller.dart';
import 'package:esfotalk_app/features/roar/widgets/roar_card.dart';
import 'package:esfotalk_app/features/user_profile/controller/user_profile_controller.dart';
import 'package:esfotalk_app/features/user_profile/view/edit_profile_view.dart';
import 'package:esfotalk_app/features/user_profile/widgets/follow_count.dart';
import 'package:esfotalk_app/models/roar_model.dart';
import 'package:esfotalk_app/models/user_model.dart';
import 'package:esfotalk_app/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
                              side: const BorderSide(
                                color: Pallete.whiteColor,
                                width: 1.5,
                              ),
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
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '@${user.name}',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Pallete.greyColor,
                        ),
                      ),
                      Text(
                        user.bio,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
                    final mutableRoars = List.from(roars);
                    return ref
                        .watch(getLatestRoarProvider)
                        .when(
                          data: (data) {
                            final latestRoar = Roar.fromMap(data.payload);

                            bool isRoarAlreadyPresent = false;

                            for (final roarModel in roars) {
                              if (roarModel.id == latestRoar.id) {
                                isRoarAlreadyPresent = true;
                                break;
                              }
                            }

                            if (!isRoarAlreadyPresent) {
                              if (data.events.contains(
                                'databases.*.collections.${AppwriteConstants.roarTable}.documents.*.create',
                              )) {
                                mutableRoars.insert(
                                  0,
                                  Roar.fromMap(data.payload),
                                );
                              } else if (data.events.contains(
                                'databases.*.collections.${AppwriteConstants.roarTable}.documents.*.update',
                              )) {
                                final startingPoint = data.events[0]
                                    .lastIndexOf('documents.');
                                final endingPoint = data.events[0].lastIndexOf(
                                  '.update',
                                );
                                final roarId = data.events[0]
                                    .substring(startingPoint + 10, endingPoint)
                                    .toString();

                                final matchingRoars = mutableRoars.where(
                                  (element) => element.id == roarId,
                                );

                                if (matchingRoars.isNotEmpty) {
                                  final roar = matchingRoars.first;
                                  final roarIndex = mutableRoars.indexOf(roar);
                                  mutableRoars.removeWhere(
                                    (element) => element.id == roarId,
                                  );
                                  final updatedRoar = Roar.fromMap(
                                    data.payload,
                                  );
                                  mutableRoars.insert(roarIndex, updatedRoar);
                                }
                              }
                            }
                            return Expanded(
                              child: ListView.builder(
                                itemCount: mutableRoars.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final roar = mutableRoars[index];
                                  return RoarCard(roar: roar);
                                },
                              ),
                            );
                          },
                          error: (error, stackTrace) =>
                              ErrorText(error: error.toString()),
                          loading: () {
                            return Expanded(
                              child: ListView.builder(
                                itemCount: roars.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final roar = roars[index];
                                  return RoarCard(roar: roar);
                                },
                              ),
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
