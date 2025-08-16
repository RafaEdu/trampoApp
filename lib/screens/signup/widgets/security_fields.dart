import 'package:flutter/material.dart';

class SecurityFields extends StatelessWidget {
  final TextEditingController senha, confirmaSenha;
  const SecurityFields({
    super.key,
    required this.senha,
    required this.confirmaSenha,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Segurança', style: Theme.of(context).textTheme.titleMedium),
        TextFormField(
          controller: senha,
          decoration: const InputDecoration(labelText: 'Senha'),
          obscureText: true,
          validator: (v) =>
              (v == null || v.length < 6) ? 'Mínimo 6 caracteres' : null,
        ),
        TextFormField(
          controller: confirmaSenha,
          decoration: const InputDecoration(labelText: 'Confirmação de senha'),
          obscureText: true,
          validator: (v) =>
              (v == null || v.isEmpty) ? 'Confirme a senha' : null,
        ),
      ],
    );
  }
}
