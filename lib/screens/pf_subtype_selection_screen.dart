import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PfSubtypeSelectionScreen extends StatelessWidget {
  const PfSubtypeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Widget card(String title, String subtitle, String typePath, IconData icon) {
      return Card(
        child: ListTile(
          leading: Icon(icon),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.go('/signup/$typePath'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        // BOTÃO DE VOLTAR ADICIONADO AQUI
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Selecione o tipo de perfil PF'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          card(
            'PF Autônoma',
            'Para profissionais que não possuem CNPJ.',
            'pf_autonoma',
            Icons.person_outline,
          ),
          card(
            'PF com CNPJ (MEI/SIMEI)',
            'Para profissionais autônomos com CNPJ.',
            'pf_com_cnpj',
            Icons.badge,
          ),
        ],
      ),
    );
  }
}
