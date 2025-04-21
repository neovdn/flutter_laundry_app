import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/voucher.dart';
import '../../repositories/voucher_repository.dart';

class CreateVoucherUseCase {
  final VoucherRepository repository;

  CreateVoucherUseCase(this.repository);

  Future<Either<Failure, Voucher>> call(Voucher voucher) async {
    final result = await repository.createVoucher(voucher);
    return result.fold(
      (failureString) {
        if (failureString == 'No internet connection') {
          return Left(NetworkFailure(message: failureString));
        }
        return Left(ServerFailure(message: failureString));
      },
      (voucher) => Right(voucher),
    );
  }
}
