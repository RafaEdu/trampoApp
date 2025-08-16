import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class UserTypeSelectionScreen extends StatelessWidget {
  const UserTypeSelectionScreen({super.key});

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
      appBar: AppBar(title: const Text('Escolha seu tipo de conta')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          card(
            'Pessoa Física (Contratante)',
            'Para contratar serviços',
            'pf',
            Icons.person,
          ),
          card(
            'Pessoa Jurídica - Empresa',
            'Empresa que contrata/oferece',
            'pj_empresa',
            Icons.business,
          ),
          card(
            'Pessoa Jurídica - Profissional Individual',
            'MEI/autônomo com CNPJ',
            'pj_individual',
            Icons.badge,
          ),
        ],
      ),
    );
  }
}
