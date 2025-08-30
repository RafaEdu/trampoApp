import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:freelago/components/my_nav_bar.dart';
import 'package:freelago/auth/auth_service.dart';
import 'package:freelago/models/user_type.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final AuthService _auth = AuthService();
  late Future<DocumentSnapshot<Map<String, dynamic>>> _userDataFuture;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  void _fetchUserData() {
    setState(() {
      _userDataFuture = _auth.getUserData();
    });
  }

  void _logout() async {
    await _auth.signOut();
  }

  String _getDisplayName(Map<String, dynamic> userData, UserType userType) {
    switch (userType) {
      case UserType.pfAutonoma:
      case UserType.pfContratante:
        return "${userData['person']['nome'] ?? ''} ${userData['person']['sobrenome'] ?? ''}"
            .trim();
      case UserType.pfComCnpj:
        return userData['person']['nomeCompleto'] ??
            userData['company']['nomeFantasia'] ??
            'Usuário PF CNPJ';
      case UserType.pjContratante:
      case UserType.pjPrestadora:
        return userData['company']['nomeFantasia'] ??
            userData['company']['razaoSocial'] ??
            'Empresa';
      default:
        return 'Usuário';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Meu Perfil"), centerTitle: true),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: _userDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Erro: ${snapshot.error}"));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Perfil não encontrado."));
          }

          final userData = snapshot.data!.data()!;
          final userType = parseUserType(userData['type'] as String);
          final displayName = _getDisplayName(userData, userType);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  displayName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // ÍCONE DE PERFIL (Placeholder)
                CircleAvatar(
                  radius: 70,
                  backgroundColor: Colors.grey.shade300,
                  child: Icon(
                    Icons.person,
                    size: 80,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Futuramente: Toque para adicionar/alterar foto",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 30),

                ElevatedButton.icon(
                  onPressed: () async {
                    await context.push('/perfil/edit');
                    _fetchUserData(); // Recarrega os dados ao retornar da tela de edição
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text("Editar meus dados"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 24,
                    ),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 20),

                Card(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: const Text('Tipo de Usuário'),
                    subtitle: Text(
                      userTypeToString(
                        userType,
                      ).replaceAll('_', ' ').toUpperCase(),
                    ),
                  ),
                ),

                const SizedBox(height: 50),

                ElevatedButton.icon(
                  onPressed: _logout,
                  icon: const Icon(Icons.logout),
                  label: const Text("S A I R"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 24,
                    ),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: const MyNavBar(selectedIndex: 1),
    );
  }
}
