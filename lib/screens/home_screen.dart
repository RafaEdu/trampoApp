import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Importar para usar o DocumentSnapshot
import 'package:freelago/components/my_nav_bar.dart';
import 'package:freelago/components/user_tile.dart';
import 'package:freelago/auth/auth_service.dart';
import 'package:freelago/services/chat/chat_service.dart';
import 'package:freelago/models/user_type.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  late final Future<DocumentSnapshot<Map<String, dynamic>>>
  _currentUserDataFuture;

  @override
  void initState() {
    super.initState();
    _currentUserDataFuture = _authService.getUserData();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _getDisplayName(Map<String, dynamic> userData) {
    final userType = parseUserType(userData['type'] as String);
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
        return userData['email'] ?? 'Usuário';
    }
  }

  String _getDisplayDescription(Map<String, dynamic> userData) {
    return userData['descricaoServicos'] ??
        'Clique para ver o perfil e iniciar uma conversa';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("T E L A    I N I C I A L"),
        centerTitle: true,
      ),
      bottomNavigationBar: const MyNavBar(selectedIndex: 0),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Buscar por nome ou serviço...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
          ),
          Expanded(child: _buildUserList()),
        ],
      ),
    );
  }

  Widget _buildUserList() {
    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: _currentUserDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
          return const Center(
            child: Text("Não foi possível carregar seu perfil."),
          );
        }

        final currentUserData = snapshot.data!.data()!;
        final currentUserType = parseUserType(currentUserData['type']);

        // Definindo claramente os grupos
        const contratanteTypes = [
          UserType.pfContratante,
          UserType.pjContratante,
        ];
        const prestadorTypes = [
          UserType.pfAutonoma,
          UserType.pfComCnpj,
          UserType.pjPrestadora,
        ];

        // Determina quais perfis buscar
        List<String> targetTypesAsString;
        if (contratanteTypes.contains(currentUserType)) {
          // Se o usuário é contratante, busca prestadores
          targetTypesAsString = prestadorTypes
              .map((t) => userTypeToString(t))
              .toList();
        } else {
          // Se o usuário é prestador, busca contratantes
          targetTypesAsString = contratanteTypes
              .map((t) => userTypeToString(t))
              .toList();
        }

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("Users")
              .where('type', whereIn: targetTypesAsString)
              .snapshots(),
          builder: (context, streamSnapshot) {
            if (streamSnapshot.hasError) {
              return const Center(child: Text("Erro ao carregar usuários."));
            }
            if (streamSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!streamSnapshot.hasData || streamSnapshot.data!.docs.isEmpty) {
              return const Center(child: Text("Nenhum perfil encontrado."));
            }

            final users = streamSnapshot.data!.docs
                .map((doc) => doc.data() as Map<String, dynamic>)
                .toList();

            final filteredUsers = users.where((userData) {
              final displayName = _getDisplayName(userData).toLowerCase();
              final description = _getDisplayDescription(
                userData,
              ).toLowerCase();
              return displayName.contains(_searchQuery) ||
                  description.contains(_searchQuery);
            }).toList();

            if (filteredUsers.isEmpty) {
              return const Center(
                child: Text("Nenhum resultado para sua busca."),
              );
            }

            return ListView.builder(
              itemCount: filteredUsers.length,
              itemBuilder: (context, index) {
                return _buildUserListItem(filteredUsers[index], context);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildUserListItem(
    Map<String, dynamic> userData,
    BuildContext context,
  ) {
    if (userData["uid"] == _authService.getCurrentUser()?.uid) {
      return Container(); // Garante que o usuário não veja a si mesmo
    }

    return UserTile(
      title: _getDisplayName(userData),
      subtitle: _getDisplayDescription(userData),
      onTap: () {
        context.push('/chat/${userData["uid"]}');
      },
    );
  }
}

// As funções _getDisplayName e _getDisplayDescription devem ser movidas para dentro da classe _HomeScreenState
// ou permanecerem fora se forem usadas em outros lugares, mas por organização, é melhor mantê-las aqui se só
// a HomeScreen as utiliza. Vou movê-las para dentro da classe para melhor encapsulamento.
