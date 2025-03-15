// domain/repositories/user_repository.dart
import 'package:dartz/dartz.dart';
import '../entities/user.dart';
import '../../../core/error/failures.dart';

abstract class UserRepository {
  Future<Either<Failure, User>> getUser();
  Future<Either<Failure, User>> updateLaundryPrice(
      int regulerPrice, int expressPrice);
}
