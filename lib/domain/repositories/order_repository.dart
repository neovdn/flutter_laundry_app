import 'package:dartz/dartz.dart' as dartz;
import '../../core/error/failures.dart';
import '../entities/order.dart';

abstract class OrderRepository {
  Future<dartz.Either<Failure, void>> createOrder(Order order);

  Future<dartz.Either<Failure, List<Order>>> getOrders();
  
  Future<dartz.Either<Failure, List<Order>>> getOrdersByStatus(String status);
  
  Future<dartz.Either<Failure, Order>> updateOrderStatus(String orderId, String newStatus);
  
  Future<dartz.Either<Failure, void>> deleteOrder(String orderId);
}
