import 'package:esfotalk_app/common/common.dart';
import 'package:esfotalk_app/features/auth/controller/auth_controller.dart';
import 'package:esfotalk_app/features/auth/view/login_view.dart';
import 'package:esfotalk_app/features/home/view/home_view.dart';
import 'package:esfotalk_app/theme/theme.dart';
import 'package:flutter/material.dart' hide CarouselController;
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'ESFOTalk',
      theme: AppTheme.theme,
      home: ref
          .watch(currentUserAccountProvider)
          .when(
            // Esto sigue siendo un Future, pero el impacto es menor si la UI de carga es simple.
            data: (user) {
              if (user != null) {
                return const HomeView();
              }
              return const LoginView(); // O SignUpView, según tu flujo
            },
            error: (error, st) => ErrorPage(error: error.toString()),
            loading: () => const LoadingPage(),
          ),
    );
  }
}
