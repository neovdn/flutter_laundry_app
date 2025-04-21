import 'package:dartz/dartz.dart';
import '../entities/voucher.dart';

abstract class VoucherRepository {
  Future<Either<String, Voucher>> createVoucher(Voucher voucher);
  Future<Either<String, List<Voucher>>> getVouchers();
}
