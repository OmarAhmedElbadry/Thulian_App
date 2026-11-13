import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart" as firebase;
import "package:google_sign_in/google_sign_in.dart";

import "../domain/auth_failure.dart";
import "../domain/entities/auth_user.dart";
import "../domain/repositories/auth_repository.dart";

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(this._auth, this._firestore, this._googleSignIn);

  final firebase.FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;
  Future<void>? _googleInitialization;

  @override
  AuthUser? get currentUser =>
      _auth.currentUser == null ? null : _toDomain(_auth.currentUser!);

  @override
  Stream<AuthUser?> get authStateChanges => _auth.authStateChanges().map(
    (user) => user == null ? null : _toDomain(user),
  );

  @override
  Future<AuthUser> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) throw const AuthFailure("Sign-in did not complete.");
      await _syncProfile(user);
      return _toDomain(user);
    } on firebase.FirebaseAuthException catch (error) {
      throw AuthFailure(_messageFor(error.code), code: error.code);
    } on FirebaseException catch (error) {
      throw AuthFailure(
        "Signed in, but your profile could not be loaded. Check Firestore setup.",
        code: error.code,
      );
    }
  }

  @override
  Future<AuthUser> createAccount({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) throw const AuthFailure("Account creation failed.");
      await user.updateDisplayName(name.trim());
      await _syncProfile(user);
      return _toDomain(user);
    } on firebase.FirebaseAuthException catch (error) {
      throw AuthFailure(_messageFor(error.code), code: error.code);
    } on FirebaseException catch (error) {
      throw AuthFailure(
        "Your account was created, but profile setup failed. Check Firestore setup.",
        code: error.code,
      );
    }
  }

  @override
  Future<AuthUser> signInWithGoogle() async {
    try {
      _googleInitialization ??= _googleSignIn.initialize();
      await _googleInitialization;
      final googleUser = await _googleSignIn.authenticate();
      final credential = firebase.GoogleAuthProvider.credential(
        idToken: googleUser.authentication.idToken,
      );
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      if (user == null) throw const AuthFailure("Google sign-in failed.");
      await _syncProfile(user);
      return _toDomain(user);
    } on firebase.FirebaseAuthException catch (error) {
      throw AuthFailure(_messageFor(error.code), code: error.code);
    } on FirebaseException catch (error) {
      throw AuthFailure(
        "Signed in, but your profile could not be loaded. Check Firestore setup.",
        code: error.code,
      );
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on firebase.FirebaseAuthException catch (error) {
      throw AuthFailure(_messageFor(error.code), code: error.code);
    }
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
    try {
      _googleInitialization ??= _googleSignIn.initialize();
      await _googleInitialization;
      await _googleSignIn.signOut();
    } catch (_) {
      // Firebase remains the source of truth if Google sign-out is unavailable.
    }
  }

  Future<void> _syncProfile(firebase.User user) async {
    final email = user.email;
    if (email == null || email.isEmpty) {
      throw const AuthFailure("Your account does not have an email address.");
    }

    final reference = _firestore.collection("users").doc(user.uid);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(reference);
      final profile = <String, Object?>{
        "uid": user.uid,
        "displayName": user.displayName ?? "",
        "email": email,
        "photoUrl": user.photoURL,
        "updatedAt": FieldValue.serverTimestamp(),
      };
      if (snapshot.exists) {
        transaction.update(reference, profile);
      } else {
        transaction.set(reference, {
          ...profile,
          "createdAt": FieldValue.serverTimestamp(),
        });
      }
    });
  }

  AuthUser _toDomain(firebase.User user) => AuthUser(
    id: user.uid,
    email: user.email ?? "",
    displayName: user.displayName ?? "",
    photoUrl: user.photoURL,
  );

  String _messageFor(String code) => switch (code) {
    "email-already-in-use" => "An account already exists for that email.",
    "invalid-email" => "Enter a valid email address.",
    "weak-password" => "Choose a stronger password.",
    "user-not-found" ||
    "wrong-password" ||
    "invalid-credential" => "Email or password is incorrect.",
    "operation-not-allowed" => "This sign-in method is not enabled yet.",
    "too-many-requests" => "Too many attempts. Try again later.",
    "network-request-failed" => "Check your internet connection and try again.",
    _ => "We couldn't complete that request. Please try again.",
  };
}
