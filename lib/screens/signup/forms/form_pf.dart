import 'package:flutter/material.dart';

class FormPF extends StatefulWidget {
  final ValueChanged<Map<String, dynamic>> onChanged;
  final bool isServiceProvider;

  const FormPF({
    super.key,
    required this.onChanged,
    this.isServiceProvider = false,
  });

  @override
  State<FormPF> createState() => _FormPFState();
}

class _FormPFState extends State<FormPF> {
  final nome = TextEditingController();
  final sobrenome = TextEditingController();
  final cpf = TextEditingController();
  final descricao = TextEditingController();
  DateTime? nascimento;
  String? genero;

  @override
  void initState() {
    super.initState();
    // Adiciona listeners para chamar _emit a cada mudança
    nome.addListener(_emit);
    sobrenome.addListener(_emit);
    cpf.addListener(_emit);
    descricao.addListener(_emit);
  }

  void _emit() {
    widget.onChanged({
      'person': {
        'nome': nome.text.trim(),
        'sobrenome': sobrenome.text.trim(),
        'cpf': cpf.text.trim(),
        'nascimento': nascimento?.toIso8601String(), // Corrigido
        'genero': genero,
      },
      // SINTAXE CORRIGIDA AQUI: Usando o spread operator (...)
      if (widget.isServiceProvider && descricao.text.trim().isNotEmpty) ...{
        'descricaoServicos': descricao.text.trim(),
      },
    });
  }

  @override
  void dispose() {
    nome.removeListener(_emit);
    sobrenome.removeListener(_emit);
    cpf.removeListener(_emit);
    descricao.removeListener(_emit);
    nome.dispose();
    sobrenome.dispose();
    cpf.dispose();
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
          controller: nome,
          decoration: const InputDecoration(labelText: 'Nome'),
          validator: (v) => v == null || v.isEmpty ? 'Informe o nome' : null,
        ),
        TextFormField(
          controller: sobrenome,
          decoration: const InputDecoration(labelText: 'Sobrenome'),
        ),
        TextFormField(
          controller: cpf,
          decoration: const InputDecoration(labelText: 'CPF'),
          keyboardType: TextInputType.number,
        ),
        if (widget.isServiceProvider) ...[
          const SizedBox(height: 12),
          Text('Serviços', style: Theme.of(context).textTheme.titleMedium),
          TextFormField(
            controller: descricao,
            decoration: const InputDecoration(
              labelText: 'Descrição dos serviços oferecidos',
            ),
            minLines: 2,
            maxLines: 5,
          ),
        ],
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () async {
                  final now = DateTime.now();
                  final picked = await showDatePicker(
                    context: context,
                    firstDate: DateTime(1900),
                    lastDate: DateTime(now.year, now.month, now.day),
                    initialDate: DateTime(now.year - 18, now.month, now.day),
                  );
                  if (picked != null) {
                    setState(() {
                      nascimento = picked;
                      _emit();
                    });
                  }
                },
                child: Text(
                  nascimento == null
                      ? 'Data de nascimento'
                      : '${nascimento!.day}/${nascimento!.month}/${nascimento!.year}',
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: genero,
                decoration: const InputDecoration(
                  labelText: 'Gênero (opcional)',
                ),
                items: const [
                  DropdownMenuItem(value: 'feminino', child: Text('Feminino')),
                  DropdownMenuItem(
                    value: 'masculino',
                    child: Text('Masculino'),
                  ),
                  DropdownMenuItem(value: 'outro', child: Text('Outro')),
                  DropdownMenuItem(
                    value: 'prefiro_nao_informar',
                    child: Text('Prefiro não informar'),
                  ),
                ],
                onChanged: (v) {
                  setState(() => genero = v);
                  _emit();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
