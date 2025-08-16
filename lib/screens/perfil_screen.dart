import 'package:flutter/material.dart';
import 'package:freelago/components/my_nav_bar.dart';
import 'package:freelago/auth/auth_service.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final _formKey = GlobalKey<FormState>();
  final _auth = AuthService();

  final TextEditingController _novaSenhaController = TextEditingController();
  final TextEditingController _confirmarSenhaController =
      TextEditingController();

  Future<void> _salvarAlteracoes() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final user = _auth.getCurrentUser();
      if (user == null) return;

      // Atualiza senha, se necessário
      if (_novaSenhaController.text.isNotEmpty) {
        if (_novaSenhaController.text == _confirmarSenhaController.text) {
          await user.updatePassword(_novaSenhaController.text);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("As senhas não coincidem.")),
          );
          return;
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Dados atualizados com sucesso!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erro ao atualizar dados: $e")));
    }
  }

  void _logout(BuildContext context) async {
    await AuthService().signOut();
    // After logout, the AuthGate will handle navigation.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("P E R F I L"), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Segurança",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _novaSenhaController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Nova senha"),
              ),
              TextFormField(
                controller: _confirmarSenhaController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Confirmar nova senha",
                ),
              ),
              const SizedBox(height: 25),

              ElevatedButton.icon(
                onPressed: _salvarAlteracoes,
                icon: const Icon(Icons.save),
                label: const Text("Salvar alterações"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 24,
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // Agora o botão de logout está dentro da rolagem
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _logout(context),
                  icon: const Icon(Icons.logout),
                  label: const Text("L O G O U T"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 35),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const MyNavBar(selectedIndex: 1),
    );
  }
}
