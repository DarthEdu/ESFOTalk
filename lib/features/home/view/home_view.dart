import 'package:esfotalk_app/constants/constants.dart';
import 'package:esfotalk_app/constants/ui_constants.dart';
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
  final appBar = UiConstants.appBar();

  void onPageChange(int index) {
    setState(() {
      _page = index;
    });
  }

  onCreateRoar() {
    Navigator.push(context, CreateRoarScreen.route());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: IndexedStack(index: _page, children: UiConstants.bottomTabBarPages),
      floatingActionButton: FloatingActionButton(
        onPressed: onCreateRoar,
        child: const Icon(Icons.add, color: Pallete.whiteColor, size: 28),
      ),
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
              // ignore: deprecated_member_use
              color: _page == 0 ? Pallete.whiteColor : Pallete.greyColor,
            ),
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              AssetsConstants.searchIcon,
              // ignore: deprecated_member_use
              color: _page == 1 ? Pallete.whiteColor : Pallete.greyColor,
            ),
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              _page == 2
                  ? AssetsConstants.notifFilledIcon
                  : AssetsConstants.notifOutlinedIcon,
              // ignore: deprecated_member_use
              color: _page == 2 ? Pallete.whiteColor : Pallete.greyColor,
            ),
          ),
        ],
      ),
    );
  }
}
