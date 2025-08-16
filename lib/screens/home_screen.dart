import 'package:freelago/components/my_nav_bar.dart';
import 'package:freelago/components/user_tile.dart';
import 'package:freelago/auth/auth_service.dart';
import 'package:freelago/services/chat/chat_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  //chat e auth service
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();

  void logout() {
    // get auth service
    final auth = AuthService();
    auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("T E L A    I N I C I A L"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      bottomNavigationBar: const MyNavBar(selectedIndex: 0),
      body: _buildUserList(),
    );
  }

  // criar uma lista de usuários para o usuário logado no momento
  Widget _buildUserList() {
    return StreamBuilder(
      stream: _chatService.getUserStream(),
      builder: (context, snapshot) {
        // erros
        if (snapshot.hasError) {
          return const Text("Erro!");
        }

        // se está carregando
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Carregando...");
        }

        //retorna a list view
        return ListView(
          children: snapshot.data!
              .map<Widget>((userData) => _buildUserListItem(userData, context))
              .toList(),
        );
      },
    );
  }

  // cria uma lista individual para o user
  Widget _buildUserListItem(
    Map<String, dynamic> userData,
    BuildContext context,
  ) {
    //mostra todos os usuário exceto o atual
    if (userData["email"] != _authService.getCurrentUser()!.email) {
      return UserTile(
        text: userData["email"],
        onTap: () {
          //clicar em um usuário vai para o chat com ele
          context.go('/chat/${userData["uid"]}');
        },
      );
    } else {
      return Container();
    }
  }
}
