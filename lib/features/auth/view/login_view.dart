import 'package:esfotalk_app/common/common.dart';
import 'package:esfotalk_app/constants/ui_constants.dart';
import 'package:esfotalk_app/features/auth/controller/auth_controller.dart';
import 'package:esfotalk_app/features/auth/view/signup_view.dart';
import 'package:esfotalk_app/features/auth/widgets/auth_field.dart';
import 'package:esfotalk_app/theme/pallete.dart';
import 'package:esfotalk_app/core/utils.dart';
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
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty) {
      showSnackBar(context, 'Por favor ingresa tu correo electrónico');
      return;
    }

    if (!email.contains('@') || !email.contains('.')) {
      showSnackBar(context, 'Por favor ingresa un correo válido');
      return;
    }

    if (password.isEmpty) {
      showSnackBar(context, 'Por favor ingresa tu contraseña');
      return;
    }

    ref
        .read(authControllerProvider.notifier)
        .login(email: email, password: password, context: context);
  }

  void onForgotPassword() {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingresa tu correo electrónico'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validación básica de email
    if (!email.contains('@') || !email.contains('.')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingresa un correo válido'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Mostrar diálogo de confirmación
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Recuperar Contraseña'),
        content: Text(
          '¿Enviar enlace de recuperación a:\n$email?',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref
                  .read(authControllerProvider.notifier)
                  .sendPasswordReset(email: email, context: context);
            },
            child: const Text('Enviar'),
          ),
        ],
      ),
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
                          style: const TextStyle(fontSize: 16),
                          children: [
                            TextSpan(
                              text: 'Recupérala aquí',
                              style: TextStyle(
                                color: Pallete.vinoColor,
                                fontSize: 16,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = onForgotPassword,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Texto de registro
                      RichText(
                        text: TextSpan(
                          text: "¿No tienes una cuenta?",
                          style: const TextStyle(fontSize: 16),
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
