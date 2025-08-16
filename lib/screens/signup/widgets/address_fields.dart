import 'package:flutter/material.dart';

class AddressFields extends StatelessWidget {
  final TextEditingController cep,
      rua,
      numero,
      complemento,
      bairro,
      cidade,
      estado;
  const AddressFields({
    super.key,
    required this.cep,
    required this.rua,
    required this.numero,
    required this.complemento,
    required this.bairro,
    required this.cidade,
    required this.estado,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Endereço', style: Theme.of(context).textTheme.titleMedium),
        TextFormField(
          controller: cep,
          decoration: const InputDecoration(labelText: 'CEP'),
          keyboardType: TextInputType.number,
        ),
        TextFormField(
          controller: rua,
          decoration: const InputDecoration(labelText: 'Rua'),
        ),
        TextFormField(
          controller: numero,
          decoration: const InputDecoration(labelText: 'Número'),
          keyboardType: TextInputType.number,
        ),
        TextFormField(
          controller: complemento,
          decoration: const InputDecoration(labelText: 'Complemento'),
        ),
        TextFormField(
          controller: bairro,
          decoration: const InputDecoration(labelText: 'Bairro'),
        ),
        TextFormField(
          controller: cidade,
          decoration: const InputDecoration(labelText: 'Cidade'),
        ),
        TextFormField(
          controller: estado,
          decoration: const InputDecoration(labelText: 'Estado'),
        ),
      ],
    );
  }
}
