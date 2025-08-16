import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyTextfield extends StatelessWidget {
  //Defino que quando chamar a classe devo passar a mensagem que vai no hintText
  //hintText seria a mensagem que aparece no fundo dos textfield
  final String hintText;
  //Define se aparece ou não o que está sendo escrito no textfield
  final bool obscureText;
  //Controle o timpo de textfield (email, senha, etc..)
  final TextEditingController controller;
  final FocusNode? focusNode;
  final List<TextInputFormatter>? inputFormatters;

  const MyTextfield({
    super.key,
    required this.hintText,
    required this.obscureText,
    required this.controller,
    this.focusNode,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextField(
        obscureText: obscureText,
        controller: controller,
        focusNode: focusNode,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          //coloco bordas no Text Field
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.grey,
            ),
          ),
          //troco a cor da borda ao clicar no textfield
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.black,
            ),
          ),
          fillColor: Colors.grey.shade100,
          filled: true,
          //aqui eu defino o que vai ser escrito no hint, quando passo no construtor la em cima
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}
