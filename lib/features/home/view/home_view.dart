import 'package:esfotalk_app/constants/constants.dart';
import 'package:esfotalk_app/constants/ui_constants.dart';
import 'package:esfotalk_app/features/home/widgets/side_drawer.dart';
import 'package:esfotalk_app/features/roar/views/create_roar_view.dart';
import 'package:esfotalk_app/theme/pallete.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide CarouselController;
import 'package:flutter_svg/svg.dart';

class HomeView extends StatefulWidget {
  static route() => MaterialPageRoute(builder: (context) => const HomeView());
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _page = 0;
  AppBar _homeAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Pallete.backgroundColor,
      centerTitle: true,
      title: SvgPicture.asset(
        AssetsConstants.dragonLogo,
        colorFilter: const ColorFilter.mode(Pallete.vinoColor, BlendMode.srcIn),
        height: 30,
      ),
      automaticallyImplyLeading: false,
      leading: Builder(
        builder: (ctx) => IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => Scaffold.of(ctx).openDrawer(),
        ),
      ),
    );
  }

  void onPageChange(int index) {
    setState(() {
      _page = index;
    });
  }

  void onCreateRoar() {
    Navigator.push(context, CreateRoarScreen.route());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _page == 0 ? _homeAppBar(context) : null,
      body: IndexedStack(index: _page, children: UiConstants.bottomTabBarPages),
      floatingActionButton: _page == 0
          ? FloatingActionButton(
              onPressed: onCreateRoar,
              child: const Icon(Icons.add, color: Pallete.whiteColor, size: 28),
            )
          : null,
      drawer: const SideDrawer(),
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: _page,
        onTap: onPageChange,
        backgroundColor: Pallete.backgroundColor,
        items: [
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              _page == 0
                  ? AssetsConstants.homeFilledIcon
                  : AssetsConstants.homeOutlinedIcon,
              colorFilter: ColorFilter.mode(
                _page == 0 ? Pallete.whiteColor : Pallete.greyColor,
                BlendMode.srcIn,
              ),
            ),
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              AssetsConstants.searchIcon,
              colorFilter: ColorFilter.mode(
                _page == 1 ? Pallete.whiteColor : Pallete.greyColor,
                BlendMode.srcIn,
              ),
            ),
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              _page == 2
                  ? AssetsConstants.notifFilledIcon
                  : AssetsConstants.notifOutlinedIcon,
              colorFilter: ColorFilter.mode(
                _page == 2 ? Pallete.whiteColor : Pallete.greyColor,
                BlendMode.srcIn,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
