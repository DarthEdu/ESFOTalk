// file: C:/Proyectos/ESFOTalk/esfotalk_app/lib/features/auth/view/signup_view.dart
import 'package:esfotalk_app/common/common.dart';
import 'package:esfotalk_app/constants/ui_constants.dart';
import 'package:esfotalk_app/features/auth/controller/auth_controller.dart';
import 'package:esfotalk_app/core/utils.dart';
import 'package:esfotalk_app/features/auth/view/login_view.dart';
import 'package:esfotalk_app/features/auth/widgets/auth_field.dart';
import 'package:esfotalk_app/theme/pallete.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignUpView extends ConsumerStatefulWidget {
  static route() => MaterialPageRoute(builder: (context) => const SignUpView());
  const SignUpView({super.key});

  @override
  ConsumerState<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends ConsumerState<SignUpView> {
  final appBar = UiConstants.appBar();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onSignUp() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    String? error;
    if (email.isEmpty) {
      error = 'Ingresa tu correo electrónico.';
    } else if (!email.contains('@') || !email.contains('.')) {
      error = 'Ingresa un correo electrónico válido.';
    } else if (password.isEmpty) {
      error = 'Ingresa tu contraseña.';
    } else if (password.length < 6) {
      error = 'La contraseña debe tener al menos 6 caracteres.';
    }

    if (error != null) {
      showSnackBar(context, error, type: SnackBarType.error);
      return;
    }

    ref
        .read(authControllerProvider.notifier)
        .signUp(email: email, password: password, context: context);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider);
    return Scaffold(
      appBar: appBar,
      body: isLoading
          ? const Loader()
          : Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      AuthField(
                        controller: _emailController,
                        hintText: 'Correo electrónico',
                      ),
                      const SizedBox(height: 25),
                      AuthField(
                        controller: _passwordController,
                        hintText: 'Contraseña',
                        isPassword: true,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _onSignUp(),
                      ),
                      const SizedBox(height: 40),
                      Align(
                        alignment: Alignment.topRight,
                        child: RoundedSmallButton(
                          onTap: _onSignUp,
                          label: 'Registrarse',
                        ),
                      ),
                      const SizedBox(height: 40),
                      RichText(
                        text: TextSpan(
                          text: "¿Ya tienes una cuenta?",
                          style: const TextStyle(
                            fontSize: 16,
                            color: Pallete.whiteColor,
                          ),
                          children: [
                            TextSpan(
                              text: ' Inicia Sesión',
                              style: TextStyle(
                                color: Pallete.vinoColor,
                                fontSize: 16,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.push(context, LoginView.route());
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
