import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../models/user_model.dart';
import '../../models/order_model.dart';
import '../../models/voucher_model.dart';
import '../../../core/error/exceptions.dart';

abstract class FirebaseDatabaseRemoteDataSource {
  Future<UserModel> getUser();
  Future<UserModel> updateLaundryPrice(int regulerPrice, int expressPrice);
  Future<OrderModel> createOrder(OrderModel order);
  Future<List<OrderModel>> getActiveOrders();
  Future<VoucherModel> createVoucher(VoucherModel voucher);
  Future<List<VoucherModel>> getVouchers();
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
  Future<UserModel> updateLaundryPrice(
      int regulerPrice, int expressPrice) async {
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

      final orderRef = firestore.collection('orders').doc(order.id);
      await orderRef.set(order.toMap());
      return order;
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<List<OrderModel>> getActiveOrders() async {
    try {
      final snapshot = await firestore
          .collection('orders')
          .where('status', isEqualTo: 'active')
          .get();
      return snapshot.docs
          .map((doc) => OrderModel.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<VoucherModel> createVoucher(VoucherModel voucher) async {
    try {
      final currentUser = firebaseAuth.currentUser;
      if (currentUser == null) {
        throw ServerException();
      }

      // Fetch the user's profile to get the store name
      final userDoc =
          await firestore.collection('users').doc(currentUser.uid).get();
      if (!userDoc.exists) {
        throw ServerException();
      }
      final userData = userDoc.data() as Map<String, dynamic>;
      final storeName = userData['storeName']?.toString() ?? 'Unknown Store';

      // Create a new VoucherModel with userId and storeName
      final voucherWithUserId = VoucherModel(
        id: voucher.id,
        name: voucher.name,
        amount: voucher.amount,
        type: voucher.type,
        obtainMethod: voucher.obtainMethod,
        validityPeriod: voucher.validityPeriod,
        userId: currentUser.uid,
      );

      final voucherRef = firestore.collection('vouchers').doc(voucher.id);
      await voucherRef.set(voucherWithUserId.toMap());
      return voucherWithUserId;
    } catch (e) {
      print('Error creating voucher: $e');
      throw ServerException();
    }
  }

  @override
  Future<List<VoucherModel>> getVouchers() async {
    try {
      final snapshot = await firestore.collection('vouchers').get();
      return snapshot.docs
          .map((doc) => VoucherModel.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error fetching vouchers: $e');
      throw ServerException();
    }
  }
}
