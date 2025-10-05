import 'package:esfotalk_app/apis/auth_api.dart';
import 'package:esfotalk_app/core/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authControllerProvider =
    StateNotifierProvider<AuthController, bool>((ref) {
  final authAPI = ref.watch(authAPIProvider);
  return AuthController(authAPI: authAPI);
});

class AuthController extends StateNotifier<bool> {
  final AuthAPI _authAPI;
  AuthController({required AuthAPI authAPI}) : _authAPI = authAPI, super(false);
  //Cargando
  void signUp({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    state = true;
    final res = await _authAPI.signUp(email: email, password: password);
    res.fold((l) => showSnackBar(context, l.message), 
    (r) => print(r.email));
  }
}
