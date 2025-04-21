import 'package:dartz/dartz.dart';
import '../../../core/error/exceptions.dart';
import '../../../core/network/network_info.dart';
import '../../domain/entities/voucher.dart';
import '../../domain/repositories/voucher_repository.dart';
import '../datasources/remote/firebase_database_remote_data_source.dart';
import '../models/voucher_model.dart';

class VoucherRepositoryImpl implements VoucherRepository {
  final FirebaseDatabaseRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  VoucherRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<String, Voucher>> createVoucher(Voucher voucher) async {
    if (await networkInfo.isConnected) {
      try {
        final voucherModel = VoucherModel.fromEntity(voucher, '');
        final result = await remoteDataSource.createVoucher(voucherModel);
        return Right(result.toEntity());
      } on ServerException {
        return const Left('Failed to create voucher due to server error');
      } catch (e) {
        print('Repository: Error creating voucher: $e'); // Add logging
        return Left(e.toString());
      }
    } else {
      return const Left('No internet connection');
    }
  }

  @override
  Future<Either<String, List<Voucher>>> getVouchers() async {
    if (await networkInfo.isConnected) {
      try {
        final voucherModels = await remoteDataSource.getVouchers();
        final vouchers =
            voucherModels.map((model) => model.toEntity()).toList();
        return Right(vouchers);
      } on ServerException {
        print(
            'Repository: Server error while fetching vouchers'); // Add logging
        return const Left('Failed to fetch vouchers due to server error');
      } catch (e) {
        print('Repository: Error fetching vouchers: $e'); // Add logging
        return Left(e.toString());
      }
    } else {
      print('Repository: No internet connection'); // Add logging
      return const Left('No internet connection');
    }
  }
}
