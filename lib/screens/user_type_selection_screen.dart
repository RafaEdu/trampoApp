import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class UserTypeSelectionScreen extends StatelessWidget {
  const UserTypeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Widget card(
      String title,
      String subtitle,
      String routePath,
      IconData icon,
    ) {
      return Card(
        child: ListTile(
          leading: Icon(icon),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.chevron_right),
          // ALTERAÇÃO AQUI: de go() para push()
          onTap: () => context.push(routePath),
        ),
      );
    }

    return Scaffold(
      // A AppBar agora irá mostrar o botão de voltar automaticamente
      appBar: AppBar(title: const Text('Como você irá se cadastrar?')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          card(
            'Pessoa Física',
            'Para autônomos ou para contratar serviços como pessoa física.',
            '/select-user-type/pf',
            Icons.person,
          ),
          card(
            'Pessoa Jurídica',
            'Para empresas que contratam ou oferecem serviços.',
            '/select-user-type/pj',
            Icons.business,
          ),
        ],
      ),
    );
  }
}
