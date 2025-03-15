import 'package:dartz/dartz.dart';
import '../../../core/error/exceptions.dart';
import '../../../core/error/failures.dart';
import '../../../core/network/network_info.dart';
import '../datasources/remote/firebase_auth_remote_data_source.dart' as auth_ds;
import '../datasources/remote/firebase_database_remote_data_source.dart'
    as db_ds;
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final auth_ds.FirebaseAuthRemoteDataSource authRemoteDataSource;
  final db_ds.FirebaseDatabaseRemoteDataSource databaseRemoteDataSource;
  final NetworkInfo networkInfo;

  UserRepositoryImpl({
    required this.authRemoteDataSource,
    required this.databaseRemoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, User>> getUser() async {
    if (await networkInfo.isConnected) {
      try {
        final userModel = await authRemoteDataSource.getUser();
        return Right(userModel);
      } on ServerException {
        return Left(ServerFailure());
      } on UserNotFoundException {
        return Left(UserNotFoundFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, User>> updateLaundryPrice(
      int regulerPrice, int expressPrice) async {
    if (await networkInfo.isConnected) {
      try {
        final updatedUser = await databaseRemoteDataSource.updateLaundryPrice(
            regulerPrice, expressPrice);
        return Right(updatedUser);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }
}
