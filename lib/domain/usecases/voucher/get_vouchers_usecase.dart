import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/voucher.dart';
import '../../repositories/voucher_repository.dart';

class GetVouchersUseCase {
  final VoucherRepository repository;

  GetVouchersUseCase(this.repository);

  Future<Either<Failure, List<Voucher>>> call() async {
    final result = await repository.getVouchers();
    return result.fold(
      (failureString) {
        if (failureString == 'No internet connection') {
          return Left(NetworkFailure(message: failureString));
        }
        return Left(
            ServerFailure(message: failureString)); // Pass the failure message
      },
      (vouchers) => Right(vouchers),
    );
  }
}
