import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:dartz/dartz.dart' as dartz;
import '../../core/error/failures.dart';
import '../../domain/entities/order.dart' as domain;
import '../../domain/repositories/order_repository.dart';
import '../datasources/remote/firebase_database_remote_data_source.dart';
import '../models/order_model.dart';

class OrderRepositoryImpl implements OrderRepository {
  final firestore.FirebaseFirestore _firestore;
  final FirebaseDatabaseRemoteDataSource remoteDataSource;

  OrderRepositoryImpl({
    required firestore.FirebaseFirestore firestore,
    required this.remoteDataSource,
  }) : _firestore = firestore;

  @override
  Future<dartz.Either<Failure, void>> createOrder(domain.Order order) async {
    try {
      final orderModel = OrderModel(
        id: order.id,
        laundryUniqueName: order.laundryUniqueName,
        customerUniqueName: order.customerUniqueName,
        weight: order.weight,
        clothes: order.clothes,
        laundrySpeed: order.laundrySpeed,
        vouchers: order.vouchers,
        status: order.status,
        totalPrice: order.totalPrice,
        createdAt: order.createdAt,
        estimatedCompletion: order.estimatedCompletion,
        completedAt: order.completedAt,
        cancelledAt: order.cancelledAt,
        updatedAt: order.updatedAt,
      );
      await remoteDataSource.createOrder(orderModel);
      return const dartz.Right(null);
    } catch (e) {
      return dartz.Left(OrderFailure(message: 'Failed to create order: $e'));
    }
  }

  @override
  Future<dartz.Either<Failure, List<domain.Order>>> getOrders() async {
    try {
      final querySnapshot = await _firestore.collection('orders').get();
      final orders = querySnapshot.docs
          .map((doc) => OrderModel.fromJson(doc.data(), doc.id))
          .toList();
      return dartz.Right(orders);
    } on firestore.FirebaseException catch (e) {
      return dartz.Left(
          ServerFailure(message: e.message ?? 'Failed to fetch orders'));
    } catch (e) {
      return dartz.Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<dartz.Either<Failure, List<domain.Order>>> getOrdersByStatus(
      String status) async {
    try {
      final querySnapshot = await _firestore
          .collection('orders')
          .where('status', isEqualTo: status)
          .get();
      final orders = querySnapshot.docs
          .map((doc) => OrderModel.fromJson(doc.data(), doc.id))
          .toList();
      return dartz.Right(orders);
    } on firestore.FirebaseException catch (e) {
      return dartz.Left(
          ServerFailure(message: e.message ?? 'Failed to fetch orders'));
    } catch (e) {
      return dartz.Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<dartz.Either<Failure, domain.Order>> updateOrderStatus(
      String orderId, String newStatus) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': newStatus,
        'updatedAt': firestore.FieldValue.serverTimestamp(),
      });

      final docSnapshot =
          await _firestore.collection('orders').doc(orderId).get();
      if (!docSnapshot.exists) {
        return dartz.Left(ServerFailure(message: 'Order not found'));
      }

      final updatedOrder =
          OrderModel.fromJson(docSnapshot.data()!, docSnapshot.id);
      return dartz.Right(updatedOrder);
    } on firestore.FirebaseException catch (e) {
      return dartz.Left(
          ServerFailure(message: e.message ?? 'Failed to update order status'));
    } catch (e) {
      return dartz.Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<dartz.Either<Failure, void>> updateOrderStatusAndCompletion(
      String orderId, String newStatus) async {
    try {
      final updateData = {
        'status': newStatus,
        'updatedAt': firestore.FieldValue.serverTimestamp(),
        if (newStatus == 'completed')
          'completedAt': firestore.FieldValue.serverTimestamp(),
        if (newStatus == 'cancelled')
          'cancelledAt':
              firestore.FieldValue.serverTimestamp(), // Tambahkan ini
      };

      await _firestore.collection('orders').doc(orderId).update(updateData);
      return const dartz.Right(null);
    } catch (e) {
      return dartz.Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<dartz.Either<Failure, void>> deleteOrder(String orderId) async {
    try {
      await _firestore.collection('orders').doc(orderId).delete();
      return const dartz.Right(null);
    } on firestore.FirebaseException catch (e) {
      return dartz.Left(
          ServerFailure(message: e.message ?? 'Failed to delete order'));
    } catch (e) {
      return dartz.Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<List<domain.Order>> getActiveOrders() async {
    return await remoteDataSource.getActiveOrders();
  }
}
