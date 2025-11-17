import 'package:esfotalk_app/common/common.dart';
import 'package:esfotalk_app/constants/ui_constants.dart';
import 'package:esfotalk_app/features/auth/controller/auth_controller.dart';
import 'package:esfotalk_app/features/auth/view/forgot_password_view.dart';
import 'package:esfotalk_app/features/auth/view/signup_view.dart';
import 'package:esfotalk_app/features/auth/widgets/auth_field.dart';
import 'package:esfotalk_app/theme/pallete.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginView extends ConsumerStatefulWidget {
  static route() => MaterialPageRoute(builder: (context) => const LoginView());

  const LoginView({super.key});

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  final appbar = UiConstants.appBar();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void onLogin() {
    // Invalidar providers antes de login para limpiar caché
    ref.invalidate(currentUserAccountProvider);
    ref.invalidate(currentUserDetailsProvider);

    ref
        .read(authControllerProvider.notifier)
        .login(
          email: emailController.text,
          password: passwordController.text,
          context: context,
        );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider);
    return Scaffold(
      appBar: appbar,
      body: isLoading
          ? const Loader()
          : Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      AuthField(
                        controller: emailController,
                        hintText: 'Correo Electrónico',
                      ),
                      const SizedBox(height: 25),
                      AuthField(
                        controller: passwordController,
                        hintText: 'Contraseña',
                        isPassword: true,
                      ),
                      const SizedBox(height: 40),
                      Align(
                        alignment: Alignment.topRight,
                        child: RoundedSmallButton(
                          onTap: onLogin,
                          label: 'Iniciar Sesión',
                        ),
                      ),
                      const SizedBox(height: 40),
                      // Texto de recuperación de contraseña
                      RichText(
                        text: TextSpan(
                          text: "¿Olvidaste tu contraseña? ",
                          style: const TextStyle(
                            fontSize: 16,
                            color: Pallete.whiteColor,
                          ),
                          children: [
                            TextSpan(
                              text: 'Recupérala aquí',
                              style: TextStyle(
                                color: Pallete.vinoColor,
                                fontSize: 16,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.push(
                                    context,
                                    ForgotPasswordView.route(),
                                  );
                                },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Texto de registro
                      RichText(
                        text: TextSpan(
                          text: "¿No tienes una cuenta?",
                          style: const TextStyle(
                            fontSize: 16,
                            color: Pallete.whiteColor,
                          ),
                          children: [
                            TextSpan(
                              text: ' Regístrate',
                              style: TextStyle(
                                color: Pallete.vinoColor,
                                fontSize: 16,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.push(context, SignUpView.route());
                                },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
