import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

import 'package:freelago/auth/auth_service.dart';
import 'package:freelago/models/user_type.dart';
import 'package:freelago/screens/signup/widgets/address_fields.dart'; // Reutilizamos os campos de endereço
import 'package:freelago/screens/signup/widgets/security_fields.dart'; // Reutilizamos os campos de segurança

class EditPerfilScreen extends StatefulWidget {
  const EditPerfilScreen({super.key});

  @override
  State<EditPerfilScreen> createState() => _EditPerfilScreenState();
}

class _EditPerfilScreenState extends State<EditPerfilScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _auth = AuthService();
  late Future<DocumentSnapshot<Map<String, dynamic>>> _userDataFuture;
  UserType? _userType;

  // Controllers para todos os campos
  final Map<String, TextEditingController> _controllers = {};

  final TextEditingController _novaSenhaController = TextEditingController();
  final TextEditingController _confirmarSenhaController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _userDataFuture = _auth.getUserData();
  }

  // Helper para inicializar controllers com dados do Firestore
  void _initializeControllers(Map<String, dynamic> data) {
    // Limpa controllers antigos para evitar duplicação (se chamado mais de uma vez)
    _controllers.forEach((key, controller) => controller.dispose());
    _controllers.clear();

    // Itera sobre os dados e cria um controller para cada campo
    data.forEach((key, value) {
      if (value is Map) {
        (value as Map<String, dynamic>).forEach((subKey, subValue) {
          _controllers['$key.$subKey'] = TextEditingController(
            text: subValue?.toString() ?? '',
          );
        });
      } else {
        _controllers[key] = TextEditingController(
          text: value?.toString() ?? '',
        );
      }
    });

    // Parse do tipo de usuário
    if (data.containsKey('type')) {
      _userType = parseUserType(data['type']);
    }
  }

  Future<void> _salvarAlteracoes() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final user = _auth.getCurrentUser();
      if (user == null) return;

      final Map<String, dynamic> updatedData = {};
      _controllers.forEach((key, controller) {
        final parts = key.split('.');
        if (parts.length == 2) {
          // Cria mapas aninhados se não existirem
          if (!updatedData.containsKey(parts[0])) {
            updatedData[parts[0]] = {};
          }
          (updatedData[parts[0]] as Map)[parts[1]] = controller.text.trim();
        } else {
          updatedData[key] = controller.text.trim();
        }
      });

      // Remove campos que não devem ser editados ou que o Firebase gerencia
      updatedData.remove('uid');
      updatedData.remove('email');
      updatedData.remove('createdAt');
      updatedData.remove('type'); // Tipo de usuário não deve ser alterado aqui
      updatedData.remove('profilePictureUrl'); // Foto é atualizada à parte

      await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .update(updatedData);

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
      context.pop(); // Volta para a PerfilScreen após salvar
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erro ao atualizar dados: $e")));
    }
  }

  // Helper para criar um TextFormField
  Widget _buildTextField(
    String mapKey,
    String label, {
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: _controllers[mapKey],
      decoration: InputDecoration(labelText: label),
      keyboardType: keyboardType,
      validator: (v) => v == null || v.isEmpty ? 'Campo obrigatório' : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Editar Perfil"), centerTitle: true),
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
          _initializeControllers(userData); // Inicializa controllers AQUI

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- SEÇÃO DE DADOS PESSOAIS/EMPRESA ---
                  if (_userType != null) ..._buildProfileFields(),

                  const SizedBox(height: 25),

                  // --- SEÇÃO DE CONTATO ---
                  const Text(
                    "Contato",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _controllers['contact.email'],
                    decoration: const InputDecoration(
                      labelText: "E-mail (não editável)",
                    ),
                    enabled:
                        false, // E-mail geralmente não é editável diretamente
                  ),
                  _buildTextField(
                    'contact.phone',
                    'Telefone',
                    keyboardType: TextInputType.phone,
                  ),

                  const SizedBox(height: 25),

                  // --- SEÇÃO DE ENDEREÇO ---
                  const Text(
                    "Endereço",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  // Reutilizamos os widgets de Endereço aqui, mas passando os controllers
                  // Note: Isso requer uma pequena adaptação em AddressFields se ele não aceitar controllers externos
                  _buildTextField(
                    'address.cep',
                    'CEP',
                    keyboardType: TextInputType.number,
                  ),
                  _buildTextField('address.rua', 'Rua'),
                  _buildTextField(
                    'address.numero',
                    'Número',
                    keyboardType: TextInputType.number,
                  ),
                  _buildTextField('address.complemento', 'Complemento'),
                  _buildTextField('address.bairro', 'Bairro'),
                  _buildTextField('address.cidade', 'Cidade'),
                  _buildTextField('address.estado', 'Estado'),

                  const SizedBox(height: 25),

                  // --- SEÇÃO DE SEGURANÇA ---
                  const Text(
                    "Alterar Senha",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _novaSenhaController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText:
                          "Nova senha (deixe em branco para não alterar)",
                    ),
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
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 35),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Constrói os campos de perfil com base no tipo de usuário
  List<Widget> _buildProfileFields() {
    switch (_userType) {
      case UserType.pfContratante:
      case UserType.pfAutonoma:
        return [
          const Text(
            "Dados Pessoais",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _buildTextField('person.nome', 'Nome'),
          _buildTextField('person.sobrenome', 'Sobrenome'),
          if (_userType == UserType.pfAutonoma)
            _buildTextField('descricaoServicos', 'Descrição dos Serviços'),
        ];
      case UserType.pfComCnpj:
        return [
          const Text(
            "Dados Pessoais",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _buildTextField('person.nomeCompleto', 'Nome Completo'),
          const SizedBox(height: 25),
          const Text(
            "Dados da Empresa",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _buildTextField('company.nomeFantasia', 'Nome Fantasia'),
          _buildTextField(
            'company.cnpj',
            'CNPJ',
            keyboardType: TextInputType.number,
          ),
          _buildTextField(
            'company.cnae',
            'CNAE',
            keyboardType: TextInputType.number,
          ),
          _buildTextField('descricaoServicos', 'Descrição dos Serviços'),
        ];
      case UserType.pjContratante:
      case UserType.pjPrestadora:
        return [
          const Text(
            "Dados da Empresa",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _buildTextField('company.razaoSocial', 'Razão Social'),
          _buildTextField('company.nomeFantasia', 'Nome Fantasia'),
          _buildTextField(
            'company.cnpj',
            'CNPJ',
            keyboardType: TextInputType.number,
          ),
          _buildTextField('company.inscricaoEstadual', 'Inscrição Estadual'),
          const SizedBox(height: 25),
          const Text(
            "Representante Legal",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _buildTextField('representante.nome', 'Nome do Representante'),
          _buildTextField('representante.cargo', 'Cargo na Empresa'),
          _buildTextField(
            'representante.cpf',
            'CPF do Representante',
            keyboardType: TextInputType.number,
          ),
          if (_userType == UserType.pjPrestadora)
            _buildTextField('descricaoServicos', 'Descrição dos Serviços'),
        ];
      default:
        return [const Text("Tipo de perfil desconhecido.")];
    }
  }

  @override
  void dispose() {
    _controllers.forEach((_, controller) => controller.dispose());
    _novaSenhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }
}
