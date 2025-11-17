import 'package:esfotalk_app/common/loading_page.dart';
import 'package:esfotalk_app/features/auth/controller/auth_controller.dart';
import 'package:esfotalk_app/features/user_profile/controller/user_profile_controller.dart';
import 'package:esfotalk_app/features/user_profile/view/user_profile_view.dart';
import 'package:esfotalk_app/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SideDrawer extends ConsumerWidget {
  const SideDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserAsync = ref.watch(currentUserDetailsStreamProvider);

    return SafeArea(
      child: Drawer(
        backgroundColor: Pallete.backgroundColor,
        child: currentUserAsync.when(
          data: (currentUser) {
            if (currentUser == null) {
              return const Center(child: Text('No se pudo cargar el usuario'));
            }

            return Column(
              children: [
                const SizedBox(height: 50),
                ListTile(
                  leading: const Icon(Icons.person, size: 30),
                  title: const Text(
                    'Mi Perfil',
                    style: TextStyle(fontSize: 22),
                  ),
                  onTap: () {
                    Navigator.push(context, UserProfileView.route(currentUser));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.payment, size: 30),
                  title: const Text(
                    'Dragon Premium',
                    style: TextStyle(fontSize: 22),
                  ),
                  onTap: () {
                    ref
                        .read(userProfileControllerProvider.notifier)
                        .updateUserProfile(
                          userModel: currentUser.copyWith(isDragonred: true),
                          context: context,
                          bannerFile: null,
                          profileFile: null,
                        );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.logout, size: 30),
                  title: const Text(
                    'Cerrar Sesión',
                    style: TextStyle(fontSize: 22),
                  ),
                  onTap: () {
                    ref.read(authControllerProvider.notifier).logout(context);
                  },
                ),
              ],
            );
          },
          error: (error, stackTrace) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                const Text('Error al cargar el perfil'),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    ref.invalidate(currentUserDetailsStreamProvider);
                  },
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          ),
          loading: () => const Loader(),
        ),
      ),
    );
  }
}
