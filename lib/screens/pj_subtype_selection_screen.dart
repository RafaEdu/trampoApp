import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PjSubtypeSelectionScreen extends StatelessWidget {
  const PjSubtypeSelectionScreen({super.key});

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
          // ALTERAÇÃO AQUI: de go() para push()
          onTap: () => context.push('/signup/$typePath'),
        ),
      );
    }

    return Scaffold(
      // A AppBar agora irá mostrar o botão de voltar automaticamente
      appBar: AppBar(title: const Text('Selecione o tipo de perfil PJ')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          card(
            'Empresa Contratante',
            'Para empresas que desejam contratar serviços.',
            'pj_contratante',
            Icons.business_center,
          ),
          card(
            'Empresa Prestadora de Serviço',
            'Para empresas que oferecem serviços.',
            'pj_prestadora',
            Icons.construction,
          ),
        ],
      ),
    );
  }
}
