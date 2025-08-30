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
          onTap: () => context.push('/signup/$typePath'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Selecione o tipo de perfil PF')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          card(
            'PF Autônoma (Prestador)',
            'Para profissionais que não possuem CNPJ e oferecem serviços.',
            'pf_autonoma',
            Icons.construction,
          ),
          card(
            'PF com CNPJ (MEI)',
            'Para profissionais autônomos com CNPJ que oferecem serviços.',
            'pf_com_cnpj',
            Icons.badge,
          ),
          card(
            'PF Contratante',
            'Para quem deseja apenas contratar serviços.',
            'pf_contratante',
            Icons.person_search,
          ),
        ],
      ),
    );
  }
}
