import 'package:flutter/material.dart';

class FormPjIndividual extends StatefulWidget {
  final ValueChanged<Map<String, dynamic>> onChanged;
  const FormPjIndividual({super.key, required this.onChanged});

  @override
  State<FormPjIndividual> createState() => _FormPjIndividualState();
}

class _FormPjIndividualState extends State<FormPjIndividual> {
  // Pessoais
  final nomeCompleto = TextEditingController();
  final cpf = TextEditingController();

  // Empresa
  final cnpj = TextEditingController();
  final nomeFantasia = TextEditingController();
  final cnae = TextEditingController();

  // Outros
  final descricao = TextEditingController();

  void _emit() {
    widget.onChanged({
      'person': {
        'nomeCompleto': nomeCompleto.text.trim(),
        'cpf': cpf.text.trim(),
      },
      'company': {
        'cnpj': cnpj.text.trim(),
        'nomeFantasia': nomeFantasia.text.trim(),
        'cnae': cnae.text.trim(),
      },
      'descricaoServicos': descricao.text.trim(),
    });
  }

  @override
  void dispose() {
    nomeCompleto.dispose();
    cpf.dispose();
    cnpj.dispose();
    nomeFantasia.dispose();
    cnae.dispose();
    descricao.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Dados pessoais', style: Theme.of(context).textTheme.titleMedium),
        TextFormField(
          controller: nomeCompleto,
          decoration: const InputDecoration(labelText: 'Nome completo'),
          onChanged: (_) => _emit(),
          validator: (v) => v == null || v.isEmpty ? 'Informe o nome' : null,
        ),
        TextFormField(
          controller: cpf,
          decoration: const InputDecoration(labelText: 'CPF'),
          keyboardType: TextInputType.number,
          onChanged: (_) => _emit(),
        ),

        const SizedBox(height: 12),
        Text(
          'Dados da empresa',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        TextFormField(
          controller: cnpj,
          decoration: const InputDecoration(
            labelText: 'CNPJ (MEI/EIRELI/Outro)',
          ),
          keyboardType: TextInputType.number,
          onChanged: (_) => _emit(),
          validator: (v) => v == null || v.isEmpty ? 'Informe o CNPJ' : null,
        ),
        TextFormField(
          controller: nomeFantasia,
          decoration: const InputDecoration(
            labelText: 'Nome fantasia (opcional)',
          ),
          onChanged: (_) => _emit(),
        ),
        TextFormField(
          controller: cnae,
          decoration: const InputDecoration(labelText: 'CNAE'),
          onChanged: (_) => _emit(),
        ),

        const SizedBox(height: 12),
        Text('Outros', style: Theme.of(context).textTheme.titleMedium),
        TextFormField(
          controller: descricao,
          decoration: const InputDecoration(
            labelText: 'Descrição dos serviços oferecidos',
          ),
          minLines: 2,
          maxLines: 5,
          onChanged: (_) => _emit(),
        ),
      ],
    );
  }
}
