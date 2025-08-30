import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:freelago/models/user_type.dart';
import 'package:freelago/auth/auth_service.dart';
import 'package:freelago/screens/signup/widgets/address_fields.dart';
import 'package:freelago/screens/signup/widgets/security_fields.dart';
import 'package:freelago/screens/signup/widgets/terms_checkbox.dart';
import 'package:freelago/screens/signup/forms/form_pf.dart';
import 'package:freelago/screens/signup/forms/form_pj_empresa.dart';
import 'package:freelago/screens/signup/forms/form_pj_individual.dart';

class SignUpScreen extends StatefulWidget {
  final String type;
  const SignUpScreen({super.key, required this.type});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _auth = AuthService();
  bool _accepted = false;

  // Campos comuns
  final email = TextEditingController();
  final phone = TextEditingController();
  final cep = TextEditingController();
  final rua = TextEditingController();
  final numero = TextEditingController();
  final complemento = TextEditingController();
  final bairro = TextEditingController();
  final cidade = TextEditingController();
  final estado = TextEditingController();
  final senha = TextEditingController();
  final confirmaSenha = TextEditingController();

  // Dados específicos ficam dentro de cada formulário via callbacks
  Map<String, dynamic> _specific = {};

  Future<void> _submit(UserType userType) async {
    if (!_formKey.currentState!.validate()) return;
    if (!_accepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('É necessário aceitar os termos.')),
      );
      return;
    }
    if (senha.text != confirmaSenha.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('As senhas não coincidem.')));
      return;
    }

    final profileData = {
      'type': userTypeToString(userType),
      'contact': {'email': email.text.trim(), 'phone': phone.text.trim()},
      'address': {
        'cep': cep.text.trim(),
        'rua': rua.text.trim(),
        'numero': numero.text.trim(),
        'complemento': complemento.text.trim(),
        'bairro': bairro.text.trim(),
        'cidade': cidade.text.trim(),
        'estado': estado.text.trim(),
      },
      ..._specific, // mescla com dados específicos
    };

    try {
      await _auth.signUpWithEmailPasswordAndProfile(
        email: email.text.trim(),
        password: senha.text.trim(),
        profileData: profileData,
      );
      // O GoRouter redireciona sozinho para /home pelo authStateChanges()
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final userType = parseUserType(widget.type);

    Widget specificForm() {
      switch (userType) {
        case UserType.pfAutonoma:
          // Passa `isServiceProvider: true` para mostrar o campo de descrição
          return FormPF(
            onChanged: (data) => _specific = data,
            isServiceProvider: true,
          );
        case UserType.pfContratante:
          // Oculta o campo de descrição para contratantes
          return FormPF(
            onChanged: (data) => _specific = data,
            isServiceProvider: false,
          );
        case UserType.pfComCnpj:
          return FormPjIndividual(onChanged: (data) => _specific = data);
        case UserType.pjContratante:
        case UserType.pjPrestadora:
          return FormPjEmpresa(onChanged: (data) => _specific = data);
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Finalize seu Cadastro')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            specificForm(),
            const SizedBox(height: 12),
            // contato
            Text('Contato', style: Theme.of(context).textTheme.titleMedium),
            TextFormField(
              controller: email,
              decoration: const InputDecoration(labelText: 'E-mail (login)'),
              keyboardType: TextInputType.emailAddress,
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Informe o e-mail' : null,
            ),
            TextFormField(
              controller: phone,
              decoration: const InputDecoration(labelText: 'Telefone'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            // endereço
            AddressFields(
              cep: cep,
              rua: rua,
              numero: numero,
              complemento: complemento,
              bairro: bairro,
              cidade: cidade,
              estado: estado,
            ),
            const SizedBox(height: 12),
            // segurança
            SecurityFields(senha: senha, confirmaSenha: confirmaSenha),
            const SizedBox(height: 12),
            TermsCheckbox(
              value: _accepted,
              onChanged: (v) => setState(() => _accepted = v ?? false),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => _submit(userType),
              child: const Text('Criar conta'),
            ),
          ],
        ),
      ),
    );
  }
}
