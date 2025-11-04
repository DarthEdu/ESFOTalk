import 'package:any_link_preview/any_link_preview.dart';
import 'package:esfotalk_app/common/error_page.dart';
import 'package:esfotalk_app/common/loading_page.dart';
import 'package:esfotalk_app/constants/assets_constant.dart';
import 'package:esfotalk_app/core/enums/roar_type_enum.dart';
import 'package:esfotalk_app/features/auth/controller/auth_controller.dart';
import 'package:esfotalk_app/features/roar/controller/roar_controller.dart';
import 'package:esfotalk_app/features/roar/views/roar_reply_view.dart';
import 'package:esfotalk_app/features/roar/widgets/carousel_image.dart';
import 'package:esfotalk_app/features/roar/widgets/hashtag_text.dart';
import 'package:esfotalk_app/features/roar/widgets/roar_icon_button.dart';
import 'package:esfotalk_app/features/user_profile/view/user_profile_view.dart';
import 'package:esfotalk_app/models/roar_model.dart';
import 'package:esfotalk_app/theme/pallete.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:like_button/like_button.dart';
import 'package:timeago/timeago.dart' as timeago;

class RoarCard extends ConsumerWidget {
  final Roar roar;
  const RoarCard({super.key, required this.roar});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserDetailsProvider).value;
    return currentUser == null
        ? const SizedBox()
        : ref
              .watch(userDetailsProvider(roar.uid))
              .when(
                data: (user) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(context, RoarReplyScreen.route(roar));
                    },
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.all(10),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context, UserProfileView.route(user)
                                  );
                                },
                                child: CircleAvatar(
                                  backgroundImage: NetworkImage(user.profilePic),
                                  radius: 35,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                //reroar
                                children: [
                                  if (roar.reroaredBy.isNotEmpty)
                                    Row(
                                      children: [
                                        SvgPicture.asset(
                                          AssetsConstants.retweetIcon,
                                          color: Pallete.greyColor,
                                          height: 20,
                                        ),
                                        const SizedBox(width: 2),
                                        Text(
                                          '${roar.reroaredBy} compartido',
                                          style: const TextStyle(
                                            color: Pallete.greyColor,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  Row(
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.only(right: 5),
                                        child: Text(
                                          user.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 17,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '@${user.name} · ${timeago.format(roar.roaredAt, locale: 'en_short')}',
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (roar.repliedTo.isNotEmpty)
                                    ref
                                        .watch(
                                          getRoarByIdProvider(roar.repliedTo),
                                        )
                                        .when(
                                          data: (repliedToRoar) {
                                            final replyingToUser = ref.watch(userDetailsProvider(repliedToRoar.uid)).value;
                                            return RichText(
                                              text: TextSpan(
                                                text: 'Respondiendo a ',
                                                style: const TextStyle(
                                                  color: Pallete.greyColor,
                                                  fontSize: 15,
                                                ),
                                                children: [
                                                  TextSpan(
                                                    text: '@${replyingToUser?.name}',
                                                    style: const TextStyle(
                                                      color: Pallete.whiteColor,
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                          error: (error, stackTrace) =>
                                              ErrorText(
                                                error: error.toString(),
                                              ),
                                          loading: () => const SizedBox(),
                                        ),
                                  // Texto del roar
                                  HashtagText(text: roar.text),
                                  if (roar.roarType == RoarType.image)
                                    CarouselImage(imageLinks: roar.imageLinks),
                                  if (roar.link.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    AnyLinkPreview(
                                      displayDirection:
                                          UIDirection.uiDirectionHorizontal,
                                      link: 'https://${roar.link}',
                                    ),
                                  ],
                                  // Aquí puedes agregar más widgets para mostrar interacciones como me gusta, comentarios, etc.
                                  Container(
                                    margin: const EdgeInsets.only(top: 10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        // Aquí puedes agregar botones de interacción
                                        RoarIconButton(
                                          pathName: AssetsConstants.viewsIcon,
                                          text:
                                              (roar.commentIds.length +
                                                      roar.reshareCount +
                                                      roar.likes.length)
                                                  .toString(),
                                          onTap: () {},
                                        ),
                                        // Aquí puedes agregar botones de interacción
                                        RoarIconButton(
                                          pathName: AssetsConstants.commentIcon,
                                          text: roar.commentIds.length
                                              .toString(),
                                          onTap: () {},
                                        ),
                                        // Aquí puedes agregar botones de interacción
                                        RoarIconButton(
                                          pathName: AssetsConstants.retweetIcon,
                                          text: roar.reshareCount.toString(),
                                          onTap: () {
                                            ref
                                                .read(
                                                  roarControllerProvider
                                                      .notifier,
                                                )
                                                .reshareRoar(
                                                  roar,
                                                  currentUser,
                                                  context,
                                                );
                                          },
                                        ),
                                        LikeButton(
                                          size: 25,
                                          onTap: (isLiked) async {
                                            ref
                                                .read(
                                                  roarControllerProvider
                                                      .notifier,
                                                )
                                                .likeRoar(roar, user);
                                            return !isLiked;
                                          },
                                          likeBuilder: (isLiked) {
                                            return isLiked
                                                ? SvgPicture.asset(
                                                    AssetsConstants
                                                        .likeFilledIcon,
                                                    color: Pallete.redColor,
                                                  )
                                                : SvgPicture.asset(
                                                    AssetsConstants
                                                        .likeOutlinedIcon,
                                                    color: Pallete.greyColor,
                                                  );
                                          },
                                          likeCount: roar.likes.length,
                                          countBuilder:
                                              (likeCount, isLiked, text) {
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        left: 2.0,
                                                      ),
                                                  child: Text(
                                                    text,
                                                    style: TextStyle(
                                                      color: isLiked
                                                          ? Pallete.redColor
                                                          : Pallete.whiteColor,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                );
                                              },
                                        ),
                                        // Aquí puedes agregar botones de interacción
                                        IconButton(
                                          onPressed: () {},
                                          icon: const Icon(
                                            Icons.share_outlined,
                                            size: 25,
                                            color: Pallete.greyColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 1),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(color: Pallete.greyColor, thickness: 0.2),
                      ],
                    ),
                  );
                },
                error: (error, stackTrace) =>
                    ErrorText(error: error.toString()),
                loading: () => const Loader(),
              );
  }
}
