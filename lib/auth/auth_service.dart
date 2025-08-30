import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? getCurrentUser() => _auth.currentUser;

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserData() async {
    final user = getCurrentUser();
    if (user == null) {
      throw Exception("Nenhum usuário logado.");
    }
    return await _firestore.collection('Users').doc(user.uid).get();
  }

  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  // Cria o user e salva o perfil completo
  Future<UserCredential> signUpWithEmailPasswordAndProfile({
    required String email,
    required String password,
    required Map<String, dynamic> profileData,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = cred.user!.uid;

      final data = {
        'uid': uid,
        'email': email, // O e-mail já está aqui
        'createdAt': FieldValue.serverTimestamp(),
        ...profileData, // inclui type, contact, address, etc.
      };

      // Corrigindo para que o e-mail não seja duplicado dentro de 'contact'
      if (profileData.containsKey('contact') && profileData['contact'] is Map) {
        (data['contact'] as Map).remove('email');
      }

      await _firestore
          .collection('Users')
          .doc(uid)
          .set(data, SetOptions(merge: true));
      return cred;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  // Mántem o método antigo para compatibilidade
  Future<UserCredential> signUpWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _firestore.collection("Users").doc(cred.user!.uid).set({
        'uid': cred.user!.uid,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return cred;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  Future<void> signOut() async {
    return await _auth.signOut();
  }
}
