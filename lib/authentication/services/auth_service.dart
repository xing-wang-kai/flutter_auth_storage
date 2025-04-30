import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<String?> userLoggin(
      {required String email, required String password}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "user-not-found":
          return "O usuário não foi encontrado";
      }
      return e.code;
    }
    return null;
  }

  Future<String?> userCreateAccount({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      await userCredential.user!.updateDisplayName(name);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "email-already-in-use":
          return "O email informado já está em uso por outro usuário.";
      }
      return e.code;
    }
    return null;
  }

  Future<String?> redifinerPasswor({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      return e.code;
    }
    return null;
  }

  Future<String?> logoutUser() async {
    try {
      await _firebaseAuth.signOut();
    } on FirebaseAuthException catch (erro) {
      return erro.message;
    }
    return null;
  }

  Future<String?> removeAccount({required String password}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: _firebaseAuth.currentUser!.email!, password: password);
      await _firebaseAuth.currentUser!.delete();
    } on FirebaseAuthException catch (e) {
      return e.code;
    }
    return null;
  }
}
