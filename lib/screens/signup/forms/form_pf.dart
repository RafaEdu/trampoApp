import 'package:flutter/material.dart';

class FormPF extends StatefulWidget {
  final ValueChanged<Map<String, dynamic>> onChanged;
  const FormPF({super.key, required this.onChanged});

  @override
  State<FormPF> createState() => _FormPFState();
}

class _FormPFState extends State<FormPF> {
  final nome = TextEditingController();
  final sobrenome = TextEditingController();
  final cpf = TextEditingController();
  DateTime? nascimento;
  String? genero;

  void _emit() {
    widget.onChanged({
      'person': {
        'nome': nome.text.trim(),
        'sobrenome': sobrenome.text.trim(),
        'cpf': cpf.text.trim(),
        'nascimento': nascimento?.toIso8601String(),
        'genero': genero,
      },
    });
  }

  @override
  void dispose() {
    nome.dispose();
    sobrenome.dispose();
    cpf.dispose();
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
          onChanged: (_) => _emit(),
          validator: (v) => v == null || v.isEmpty ? 'Informe o nome' : null,
        ),
        TextFormField(
          controller: sobrenome,
          decoration: const InputDecoration(labelText: 'Sobrenome'),
          onChanged: (_) => _emit(),
        ),
        TextFormField(
          controller: cpf,
          decoration: const InputDecoration(labelText: 'CPF'),
          keyboardType: TextInputType.number,
          onChanged: (_) => _emit(),
        ),
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
                  if (picked != null)
                    setState(() {
                      nascimento = picked;
                      _emit();
                    });
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
