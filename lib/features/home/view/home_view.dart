import 'package:esfotalk_app/common/error_page.dart';
import 'package:esfotalk_app/common/loading_page.dart';
import 'package:esfotalk_app/constants/constants.dart';
import 'package:esfotalk_app/constants/ui_constants.dart';
import 'package:esfotalk_app/features/auth/controller/auth_controller.dart';
import 'package:esfotalk_app/features/home/widgets/side_drawer.dart';
import 'package:esfotalk_app/features/roar/views/create_roar_view.dart';
import 'package:esfotalk_app/theme/pallete.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide CarouselController;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

// Provider para manejar el estado de la página actual en el BottomNavigationBar
final pageProvider = StateProvider<int>((ref) => 0);

class HomeView extends ConsumerWidget {
  static route() => MaterialPageRoute(builder: (context) => const HomeView());
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. HomeView ahora actúa como un "guardián" de la autenticación.
    return ref.watch(currentUserAccountProvider).when(
          loading: () => const LoadingPage(),
          error: (error, st) => ErrorPage(error: error.toString()),
          data: (user) {
            // Si en algún momento el usuario es nulo, se muestra una carga.
            // La lógica de redirección ya está en el AuthController y en el main.
            if (user == null) {
              return const LoadingPage();
            }

            // 2. El índice de la página se obtiene del nuevo provider.
            final page = ref.watch(pageProvider);
            final appBar = UiConstants.appBar();

            void onPageChange(int index) {
              ref.read(pageProvider.notifier).state = index;
            }

            void onCreateRoar() {
              Navigator.push(context, CreateRoarScreen.route());
            }

            // 3. Se construye la UI principal solo si el usuario está autenticado.
            return Scaffold(
              appBar: page == 0 ? appBar : null,
              body: IndexedStack(index: page, children: UiConstants.bottomTabBarPages),
              floatingActionButton: FloatingActionButton(
                onPressed: onCreateRoar,
                child: const Icon(Icons.add, color: Pallete.whiteColor, size: 28),
              ),
              drawer: const SideDrawer(),
              bottomNavigationBar: CupertinoTabBar(
                currentIndex: page,
                onTap: onPageChange,
                backgroundColor: Pallete.backgroundColor,
                items: [
                  BottomNavigationBarItem(
                    icon: SvgPicture.asset(
                      page == 0
                          ? AssetsConstants.homeFilledIcon
                          : AssetsConstants.homeOutlinedIcon,
                      color: page == 0 ? Pallete.whiteColor : Pallete.greyColor,
                    ),
                  ),
                  BottomNavigationBarItem(
                    icon: SvgPicture.asset(
                      AssetsConstants.searchIcon,
                      color: page == 1 ? Pallete.whiteColor : Pallete.greyColor,
                    ),
                  ),
                  BottomNavigationBarItem(
                    icon: SvgPicture.asset(
                      page == 2
                          ? AssetsConstants.notifFilledIcon
                          : AssetsConstants.notifOutlinedIcon,
                      color: page == 2 ? Pallete.whiteColor : Pallete.greyColor,
                    ),
                  ),
                ],
              ),
            );
          },
        );
  }
}
