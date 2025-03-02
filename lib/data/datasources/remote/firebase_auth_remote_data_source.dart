import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/error/exceptions.dart';
import '../../models/user_model.dart';

abstract class FirebaseAuthRemoteDataSource {
  Future<UserModel> register({
    required String role,
    required String fullName,
    required String uniqueName,
    required String email,
    required String password,
    required String phoneNumber,
    required String address,
  });

  Future<UserModel> login({
    required String email,
    required String password,
  });
}

class FirebaseAuthRemoteDataSourceImpl implements FirebaseAuthRemoteDataSource {
  final firebase_auth.FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

  FirebaseAuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.firestore,
  });

  @override
  Future<UserModel> register({
    required String role,
    required String fullName,
    required String uniqueName,
    required String email,
    required String password,
    required String phoneNumber,
    required String address,
  }) async {
    try {
      // Create user with email and password
      final userCredential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw ServerException();
      }

      final userId = userCredential.user!.uid;
      final currentDateTime = DateTime.now();

      // Create user document in Firestore
      final userData = UserModel(
        id: userId,
        role: role,
        fullName: fullName,
        uniqueName: uniqueName,
        email: email,
        phoneNumber: phoneNumber,
        address: address,
        createdAt: currentDateTime,
      );

      // Save user data to Firestore
      await firestore.collection('users').doc(userId).set(userData.toJson());

      // Update display fullName in Firebase Auth
      await userCredential.user!.updateDisplayFullName(fullName);

      return userData;
    } on firebase_auth.FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw WeakPasswordException();
      } else if (e.code == 'email-already-in-use') {
        throw EmailAlreadyInUseException();
      } else {
        throw ServerException();
      }
    } catch (e) {
      throw ServerException();
    }
  }

    @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      // Sign in user with email and password
      final userCredential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw ServerException();
      }

      final userId = userCredential.user!.uid;

      // Get user data from Firestore
      final userDoc = await firestore.collection('users').doc(userId).get();
      
      if (!userDoc.exists) {
        throw UserNotFoundException();
      }

      return UserModel.fromJson(userDoc.data()!..addAll({'id': userId}));
    } on firebase_auth.FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        throw InvalidCredentialsException();
      } else {
        throw ServerException();
      }
    } catch (e) {
      throw ServerException();
    }
  }
}
