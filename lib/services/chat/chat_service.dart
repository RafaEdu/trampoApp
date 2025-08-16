import 'package:freelago/models/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  // get instance of firebase & auth
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // obter o fluxo do usuário
  /*

  <List<Map<String,dynamic>>>

  Seria como se fosse uma lista de Maps(que seria como um dicionario)
  Ex:

  [
  {
    'email': rafa@gmail.com,
    'id': ...
  },
  {
    'email': rafa@gmail.com,
    'id': ...
  },
  ]

  */
  Stream<List<Map<String, dynamic>>> getUserStream() {
    return _firestore.collection("Users").snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        //vai para cada user individual
        final user = doc.data();

        //retorna o user
        return user;
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
