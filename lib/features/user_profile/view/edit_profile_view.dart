import 'dart:io';

import 'package:esfotalk_app/common/loading_page.dart';
import 'package:esfotalk_app/core/utils.dart';
import 'package:esfotalk_app/features/auth/controller/auth_controller.dart';
import 'package:esfotalk_app/features/user_profile/controller/user_profile_controller.dart';
import 'package:esfotalk_app/theme/pallete.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditProfileView extends ConsumerStatefulWidget {
  static route() =>
      MaterialPageRoute(builder: (context) => const EditProfileView());
  const EditProfileView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EditProfileViewState();
}

class _EditProfileViewState extends ConsumerState<EditProfileView> {
  late TextEditingController nameController;
  late TextEditingController bioController;
  File? bannerImage;
  File? profileImage;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(
      text: ref.read(currentUserDetailsProvider).value?.name ?? '',
    );
    bioController = TextEditingController(
      text: ref.read(currentUserDetailsProvider).value?.bio ?? '',
    );
  }

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    bioController.dispose();
  }

  void selectBannerImage() async {
    final banner = await pickImage();
    if (banner != null) {
      setState(() {
        bannerImage = banner;
      });
    }
  }

  void selectProfileImage() async {
    final profile = await pickImage();
    if (profile != null) {
      setState(() {
        profileImage = profile;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserDetailsProvider).value;
    final isLoading = ref.watch(userProfileControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        centerTitle: false,
        actions: [
          TextButton(
            onPressed: () {
              ref
                  .read(userProfileControllerProvider.notifier)
                  .updateUserProfile(
                    userModel: user!.copyWith(
                      bio: bioController.text,
                      name: nameController.text,
                    ),
                    context: context,
                    bannerFile: bannerImage,
                    profileFile: profileImage,
                  );
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
      body: isLoading || user == null
          ? const Loader()
          : Column(
              children: [
                SizedBox(
                  height: 200,
                  child: Stack(
                    children: [
                      GestureDetector(
                        onTap: selectBannerImage,
                        child: Container(
                          width: double.infinity,
                          height: 150,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: bannerImage != null
                              ? Image.file(bannerImage!)
                              : user.bannerPic.isEmpty
                              ? Container(color: Pallete.vinoColor)
                              : Image.network(
                                  user.bannerPic,
                                  fit: BoxFit.fitWidth,
                                ),
                        ),
                      ),
                      Positioned(
                        bottom: 20,
                        left: 20,
                        child: GestureDetector(
                          onTap: selectProfileImage,
                          child: profileImage != null
                              ? CircleAvatar(
                                  backgroundImage: FileImage(profileImage!),
                                  radius: 40,
                                )
                              : CircleAvatar(
                                  backgroundImage: NetworkImage(
                                    user.profilePic,
                                  ),
                                  radius: 40,
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    hintText: 'Nombre',
                    contentPadding: EdgeInsets.all(18),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: bioController,
                  decoration: const InputDecoration(
                    hintText: 'Presentación',
                    contentPadding: EdgeInsets.all(18),
                  ),
                  maxLines: 5,
                ),
              ],
            ),
    );
  }
}
