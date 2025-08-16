import 'package:flutter/material.dart';
import 'package:freelago/auth/auth_service.dart';
import 'package:freelago/components/my_button.dart';
import 'package:freelago/components/my_textfield.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  //email e senha controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  //método de  login
  void login(BuildContext context) async {
    // chama o método de autenticação
    final authService = AuthService();

    // tenta entrar
    try {
      await authService.signInWithEmailAndPassword(
        _emailController.text,
        _senhaController.text,
      );
    }
    // pega os erros
    catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(title: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 50),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //welcome back message
                const Text(
                  "Bem-vindo de volta, sentimos saudades!",
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),

                const SizedBox(height: 25),

                //email and password textfild
                MyTextfield(
                  hintText: "Email",
                  obscureText: false,
                  controller: _emailController,
                ),

                const SizedBox(height: 10),

                MyTextfield(
                  hintText: "Senha",
                  obscureText: true,
                  controller: _senhaController,
                ),

                const SizedBox(height: 25),

                //login button
                MyButton(text: "Login", onTap: () => login(context)),

                const SizedBox(height: 25),

                //register now
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Ainda não é um usuário? ",
                      style: TextStyle(color: Colors.black),
                    ),
                    GestureDetector(
                      onTap: () => context.go('/select-user-type'),
                      child: const Text(
                        "Registre-se agora",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
