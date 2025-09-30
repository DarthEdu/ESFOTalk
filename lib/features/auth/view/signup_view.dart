import 'package:esfotalk_app/common/rounded_small_button.dart';
import 'package:esfotalk_app/constants/ui_constants.dart';
import 'package:esfotalk_app/features/auth/view/login_view.dart';
import 'package:esfotalk_app/features/auth/widgets/auth_field.dart';
import 'package:esfotalk_app/theme/pallete.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class SignUpView extends StatefulWidget {
  
  static route() => MaterialPageRoute(builder: (context) => const SignUpView());
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final appbar = UiConstants.appBar();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbar,
      body: Center(
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
                ),

                const SizedBox(height: 40),
                Align(
                  alignment: Alignment.topRight,
                  child: RoundedSmallButton(onTap: () {}, label: 'Registrarse'),
                ),
                const SizedBox(height: 40),
                RichText(
                  text: TextSpan(
                    text: "¿Ya tienes una cuenta?",
                    children: [
                      TextSpan(
                        text: ' Inicia Sesión',
                        style: TextStyle(
                          color: Pallete.vinoColor,
                          fontSize: 16,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            // Navegar a la vista de registro
                            Navigator.push(
                              context,
                              LoginView.route()
                            );
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
