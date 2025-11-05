import 'package:esfotalk_app/common/error_page.dart';
import 'package:esfotalk_app/features/user_profile/controller/user_profile_controller.dart';
import 'package:esfotalk_app/features/user_profile/widgets/user_profile.dart';
import 'package:esfotalk_app/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserProfileView extends ConsumerWidget {
  static route(UserModel userModel) => MaterialPageRoute(
        builder: (context) => UserProfileView(userModel: userModel),
      );
  final UserModel userModel;
  const UserProfileView({super.key, required this.userModel});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: ref.watch(userDataProvider(userModel.uid)).when(
            data: (user) {
              return UserProfile(user: user);
            },
            error: (error, stackTrace) => ErrorText(error: error.toString()),
            loading: () => UserProfile(user: userModel), // Muestra los datos iniciales mientras carga el stream
          ),
    );
  }
}
