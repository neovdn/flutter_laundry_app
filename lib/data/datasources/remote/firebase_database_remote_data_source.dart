import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_laundry_app/data/models/user_model.dart';
import '../../models/order_model.dart';
import '../../../core/error/exceptions.dart';

abstract class FirebaseDatabaseRemoteDataSource {
  Future<UserModel> getUser();
  Future<UserModel> updateLaundryPrice(int regulerPrice, int expressPrice);
  Future<OrderModel> createOrder(OrderModel order);
}

class FirebaseDatabaseRemoteDataSourceImpl
    implements FirebaseDatabaseRemoteDataSource {
  final FirebaseFirestore firestore;
  final firebase_auth.FirebaseAuth firebaseAuth;

  FirebaseDatabaseRemoteDataSourceImpl({
    required this.firestore,
    required this.firebaseAuth,
  });

  @override
  Future<UserModel> getUser() async {
    try {
      final currentUser = firebaseAuth.currentUser;
      if (currentUser == null) {
        throw ServerException();
      }

      final userDoc =
          await firestore.collection('users').doc(currentUser.uid).get();
      if (!userDoc.exists) {
        throw ServerException();
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      userData['id'] = currentUser.uid;
      return UserModel.fromJson(userData);
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<UserModel> updateLaundryPrice(int regulerPrice, int expressPrice) async {
    try {
      final currentUser = firebaseAuth.currentUser;
      if (currentUser == null) {
        throw ServerException();
      }

      await firestore.collection('users').doc(currentUser.uid).update({
        'regulerPrice': regulerPrice,
        'expressPrice': expressPrice,
      });

      final userDoc =
          await firestore.collection('users').doc(currentUser.uid).get();
      if (!userDoc.exists) {
        throw ServerException();
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      userData['id'] = currentUser.uid;
      return UserModel.fromJson(userData);
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<OrderModel> createOrder(OrderModel order) async {
    try {
      final currentUser = firebaseAuth.currentUser;
      if (currentUser == null) {
        throw ServerException();
      }

      // Use the custom ID that was already generated
      final orderRef = firestore.collection('orders').doc(order.id);
      await orderRef.set(order.toJson());
      return order;
    } catch (e) {
      throw ServerException();
    }
  }
}
