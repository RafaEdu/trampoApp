import 'package:freelago/models/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:freelago/models/user_type.dart'; // Importar UserType

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Manter o método antigo caso seja usado em outro lugar
  Stream<List<Map<String, dynamic>>> getUserStream() {
    return _firestore.collection("Users").snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final user = doc.data();
        return user;
      }).toList();
    });
  }

  // NOVO MÉTODO: Busca usuários com base no perfil do usuário logado
  Stream<List<Map<String, dynamic>>> getFilteredUsersStream() async* {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      yield []; // Retorna uma lista vazia se não houver usuário
      return;
    }

    // 1. Descobrir o tipo do usuário atual
    final currentUserDoc = await _firestore
        .collection("Users")
        .doc(currentUser.uid)
        .get();
    if (!currentUserDoc.exists) {
      yield [];
      return;
    }
    final currentUserType = parseUserType(currentUserDoc.data()!['type']);

    // 2. Definir quais tipos de perfil buscar
    List<String> targetTypes;
    final isContratante = [
      UserType.pfContratante,
      UserType.pjContratante,
    ].contains(currentUserType);

    if (isContratante) {
      // Se for contratante, busca por prestadores de serviço
      targetTypes = [
        userTypeToString(UserType.pfAutonoma),
        userTypeToString(UserType.pfComCnpj),
        userTypeToString(UserType.pjPrestadora),
      ];
    } else {
      // Se for prestador, busca por contratantes
      targetTypes = [
        userTypeToString(UserType.pfContratante),
        userTypeToString(UserType.pjContratante),
      ];
    }

    // Se targetTypes estiver vazio, não faz a query
    if (targetTypes.isEmpty) {
      yield [];
      return;
    }

    // 3. Retornar a stream com o filtro
    yield* _firestore
        .collection("Users")
        .where('type', whereIn: targetTypes)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return doc.data();
          }).toList();
        });
  }

  // mandar a mensagem
  Future<void> sendMessage(String receiverID, message) async {
    // get current user info
    final String currentUserID = _auth.currentUser!.uid;
    final String currentUserEmail = _auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();

    // create a new message
    Message newMessage = Message(
      senderID: currentUserID,
      senderEmail: currentUserEmail,
      receiverID: receiverID,
      message: message,
      timestamp: timestamp,
    );

    // construir ID de sala de bate-papo para os dois usuários (classificados para garantir exclusividade)
    List<String> ids = [currentUserID, receiverID];
    ids.sort(); // classificar os IDs (isso garante que o ID da sala de bate-papo seja o mesmo para quaisquer 2 pessoas)
    String chatRoomID = ids.join('_');

    // adiciona a mensagem na database
    await _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .add(newMessage.toMap());
  }

  // receber a mensagem
  Stream<QuerySnapshot> getMessages(String userID, otherUserID) {
    // construir uma ID de sala de bate-papo para os dois usuários
    List<String> ids = [userID, otherUserID];
    ids.sort();
    String chatRoomID = ids.join('_');

    return _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .orderBy("timestamp", descending: false)
        .snapshots();
  }
}
