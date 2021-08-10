import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_chat_app/cubits/authentication/authentication_cubit.dart';
import 'package:flutter_chat_app/data_repo/models/user_model.dart';

class UserAuthenticationRepo {
  final FirebaseAuth? _firebaseAuth;

  UserAuthenticationRepo({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  Future<MyUser?> signInInEmailAndPassword(
      {required String email,
      required String password,
      required AuthRegistrationListener authRegistrationListener}) async {
    authRegistrationListener.loading();
    try {
      var userCredential = await _firebaseAuth!
          .signInWithEmailAndPassword(email: email, password: password);
      authRegistrationListener.success();
      return MyUser(
          id: userCredential.user!.uid, email: userCredential.user!.email);
    } on FirebaseException catch (e) {
      authRegistrationListener.failed();
    }
  }

  String? userData() {
    final User? user = _firebaseAuth!.currentUser;
    final String? uid = user!.uid;
    return uid;
  }

  Future<MyUser?> registerUser(
      {required String email,
      required String password,
      required AuthRegistrationListener authRegistrationListener}) async {
    authRegistrationListener.loading();
    try {
      UserCredential userCredential = await _firebaseAuth!
          .createUserWithEmailAndPassword(email: email, password: password);
      _firebaseAuth!.signOut();
      authRegistrationListener.success();
      return MyUser(
          id: userCredential.user!.uid, email: userCredential.user!.email);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        //authRegistrationListener.weakPassword();
      } else if (e.code == 'email-already-in-use') {
        authRegistrationListener.userExists();
      }
    } catch (e) {
      print(e);
      authRegistrationListener.failed();
    }
  }

  Future<void> logout() async {
    try {
      await Future.wait([
        _firebaseAuth!.signOut(),
      ]);
    } on Exception {
      throw Exception();
    }
  }
}