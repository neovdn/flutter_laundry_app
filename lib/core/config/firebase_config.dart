import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Firebase providers
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);
final firestoreProvider = Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);

// Network provider
final connectionCheckerProvider = Provider<InternetConnectionChecker>((ref) => InternetConnectionChecker.createInstance());
