import 'package:esfotalk_app/common/rounded_small_button.dart';
import 'package:esfotalk_app/constants/ui_constants.dart';
import 'package:esfotalk_app/features/auth/widgets/auth_field.dart';
import 'package:esfotalk_app/theme/pallete.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
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
      appBar: UiConstants.appBar(),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                AuthField(controller: emailController, hintText: 'Correo Electrónico'),

                const SizedBox(height: 25),

                AuthField(controller: passwordController, hintText: 'Contraseña'),

                const SizedBox(height: 40),
                Align(
                  alignment: Alignment.topRight,
                  child: RoundedSmallButton(
                    onTap: () {}, 
                    label: 'Iniciar Sesión',
                    )
                  ),
                const SizedBox(height: 40),
                RichText(text: TextSpan(
                  text: "¿No tienes una cuenta?",
                  children: [
                    TextSpan(
                      text: ' Regístrate',
                      style: TextStyle(
                        color: Pallete.vinoColor,
                        fontSize: 16,
                      ),
                      recognizer: TapGestureRecognizer()..onTap = () {
                        // Navegar a la vista de registro
                        
                      },
                    )
                  ],
                ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
