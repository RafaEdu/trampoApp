import 'package:flutter/material.dart';

class FormPjEmpresa extends StatefulWidget {
  final ValueChanged<Map<String, dynamic>> onChanged;
  const FormPjEmpresa({super.key, required this.onChanged});

  @override
  State<FormPjEmpresa> createState() => _FormPjEmpresaState();
}

class _FormPjEmpresaState extends State<FormPjEmpresa> {
  // Empresa
  final razaoSocial = TextEditingController();
  final nomeFantasia = TextEditingController();
  final cnpj = TextEditingController();
  final inscricao = TextEditingController();
  final cnae = TextEditingController();

  // Representante
  final repNome = TextEditingController();
  final repCpf = TextEditingController();
  final repCargo = TextEditingController();

  // Outros
  final descricao = TextEditingController();

  void _emit() {
    widget.onChanged({
      'company': {
        'razaoSocial': razaoSocial.text.trim(),
        'nomeFantasia': nomeFantasia.text.trim(),
        'cnpj': cnpj.text.trim(),
        'inscricao': inscricao.text.trim(), // opcional
        'cnae': cnae.text.trim(),
      },
      'representante': {
        'nome': repNome.text.trim(),
        'cpf': repCpf.text.trim(),
        'cargo': repCargo.text.trim(),
      },
      'descricaoServicos': descricao.text.trim(),
    });
  }

  @override
  void dispose() {
    razaoSocial.dispose();
    nomeFantasia.dispose();
    cnpj.dispose();
    inscricao.dispose();
    cnae.dispose();
    repNome.dispose();
    repCpf.dispose();
    repCargo.dispose();
    descricao.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dados da empresa',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        TextFormField(
          controller: razaoSocial,
          decoration: const InputDecoration(labelText: 'Razão social'),
          onChanged: (_) => _emit(),
          validator: (v) =>
              v == null || v.isEmpty ? 'Informe a razão social' : null,
        ),
        TextFormField(
          controller: nomeFantasia,
          decoration: const InputDecoration(labelText: 'Nome fantasia'),
          onChanged: (_) => _emit(),
        ),
        TextFormField(
          controller: cnpj,
          decoration: const InputDecoration(labelText: 'CNPJ'),
          keyboardType: TextInputType.number,
          onChanged: (_) => _emit(),
          validator: (v) => v == null || v.isEmpty ? 'Informe o CNPJ' : null,
        ),
        TextFormField(
          controller: inscricao,
          decoration: const InputDecoration(
            labelText: 'Inscrição estadual/municipal (opcional)',
          ),
          onChanged: (_) => _emit(),
        ),
        TextFormField(
          controller: cnae,
          decoration: const InputDecoration(labelText: 'CNAE'),
          onChanged: (_) => _emit(),
        ),

        const SizedBox(height: 12),
        Text(
          'Representante legal',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        TextFormField(
          controller: repNome,
          decoration: const InputDecoration(labelText: 'Nome completo'),
          onChanged: (_) => _emit(),
        ),
        TextFormField(
          controller: repCpf,
          decoration: const InputDecoration(labelText: 'CPF'),
          keyboardType: TextInputType.number,
          onChanged: (_) => _emit(),
        ),
        TextFormField(
          controller: repCargo,
          decoration: const InputDecoration(labelText: 'Cargo na empresa'),
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
