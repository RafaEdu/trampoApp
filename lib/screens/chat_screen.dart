import 'package:freelago/components/chat_bubble.dart';
import 'package:freelago/components/my_textfield.dart';
import 'package:freelago/auth/auth_service.dart';
import 'package:freelago/services/chat/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  //recebe o id do usário para saber com quem estou conversando
  final String receiverID;

  const ChatScreen({super.key, required this.receiverID});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // text controller
  final TextEditingController _messageController = TextEditingController();

  // chat & auth services
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();

  // para foco em campo de texto (rolar para cima quando abre o teclado)
  FocusNode myFocusNode = FocusNode();

  // para mostrar o nome do usuário
  String receiverName = '...';

  @override
  void initState() {
    super.initState();

    _loadReceiverName();

    myFocusNode.addListener(() {
      if (myFocusNode.hasFocus) {
        // causa um atraso para que o teclado tenha tempo de aparecer
        // então a quantidade de espaço restante será calculada,
        // então role para baixo
        Future.delayed(const Duration(milliseconds: 500), () => scrolDown());
      }
    });

    // espere um pouco para que a lista seja construída e role para baixo
    Future.delayed(const Duration(milliseconds: 500), () => scrolDown());
  }

  // localiza o nome do usuário
  void _loadReceiverName() async {
    final doc = await FirebaseFirestore.instance
        .collection("Users")
        .doc(widget.receiverID)
        .get();

    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        receiverName = data['nome'] ?? 'Usuário';
      });
    }
  }

  @override
  void dispose() {
    myFocusNode.dispose();
    _messageController.dispose();
    super.dispose();
  }

  // scroll controller
  final ScrollController _scrollController = ScrollController();
  void scrolDown() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(seconds: 1),
      curve: Curves.fastOutSlowIn,
    );
  }

  // enviar uma mensagem
  void sendMessage() async {
    // só mandar se tiver algo para mandar no textfield
    if (_messageController.text.isNotEmpty) {
      // mandar a mensagem
      await _chatService.sendMessage(
        widget.receiverID,
        _messageController.text,
      );

      // clear text controller
      _messageController.clear();
    }

    scrolDown();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(receiverName),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.grey,
        elevation: 0,
      ),
      body: Column(
        children: [
          // display all messages
          Expanded(child: _buildMessageList()),

          //user input
          _buildUserInput(),
        ],
      ),
    );
  }

  // build messagem list
  Widget _buildMessageList() {
    String senderID = _authService.getCurrentUser()!.uid;
    return StreamBuilder(
      stream: _chatService.getMessages(widget.receiverID, senderID),
      builder: (context, snapshot) {
        // erros
        if (snapshot.hasError) {
          return const Text("Error");
        }

        // loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Carregando...");
        }

        // return list view
        return ListView(
          controller: _scrollController,
          children: snapshot.data!.docs
              .map((doc) => _buildMessageItem(doc))
              .toList(),
        );
      },
    );
  }

  // construtor do item de mensagens
  Widget _buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // is current user
    bool isCurrentUser = data['senderID'] == _authService.getCurrentUser()!.uid;

    // alinha a mensagem na direita se o "sender" é o usuário atual, se não, à direita
    var alignment = isCurrentUser
        ? Alignment.centerRight
        : Alignment.centerLeft;

    return Container(
      alignment: alignment,
      child: Column(
        crossAxisAlignment: isCurrentUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          ChatBubble(message: data["message"], isCurrentUser: isCurrentUser),
        ],
      ),
    );
  }

  // build message input
  Widget _buildUserInput() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 50.0),
      child: Row(
        children: [
          // textfield should take up most od the space
          Expanded(
            child: MyTextfield(
              hintText: "Digite uma mensagem",
              obscureText: false,
              controller: _messageController,
              focusNode: myFocusNode,
            ),
          ),

          // send button
          Container(
            decoration: const BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
            ),
            margin: const EdgeInsets.only(right: 25),
            child: IconButton(
              onPressed: sendMessage,
              icon: const Icon(Icons.arrow_upward, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
