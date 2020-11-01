import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseMethods {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<String> signIn(String email, String password) async {
    try {
      final result = await firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      final user = result.user;
      return user.uid;
    } catch (e) {
      return ('Error');
    }
  }

  Future<dynamic> signUp(String email, String password) async {
    try {
      final result = await firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      return result;
    } catch (e) {
     print(e.code);
     print(e.code);
     print(e.code);
     print(e.code);
     print(e.code);
      if(e.code == 'email-already-in-use')
        return Exception('Email is already taken');
      else if (e.code == 'invalid-email')
        return Exception('Enter a vaild e-mail');
      else if(e.code == 'weak-password')
        return Exception('Password should be strong');
      else return Exception('Error happening');
    }
  }

  User getCurrentUser() {
    final user = firebaseAuth.currentUser;
    return user;
  }

  Future<void> signOut() async {
    return firebaseAuth.signOut();
  }
}
