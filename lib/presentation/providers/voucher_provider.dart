import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import '../../core/config/firebase_config.dart';
import '../../core/network/network_info.dart';
import '../../data/datasources/remote/firebase_database_remote_data_source.dart';
import '../../data/repositories/voucher_repository_impl.dart';
import '../../domain/entities/voucher.dart';
import '../../domain/usecases/voucher/create_voucher_usecase.dart';
import '../../domain/usecases/voucher/get_vouchers_usecase.dart'; // Add this import

// Network info provider
final networkInfoProvider = Provider<InternetConnectionChecker>((ref) {
  return InternetConnectionChecker.createInstance();
});

enum VoucherFilter { all, discount, freeLaundry }

final voucherFilterProvider =
    StateProvider<VoucherFilter>((ref) => VoucherFilter.all);

// Repository provider
final voucherRepositoryProvider = Provider<VoucherRepositoryImpl>((ref) {
  final remoteDataSource = FirebaseDatabaseRemoteDataSourceImpl(
    firestore: ref.watch(firestoreProvider),
    firebaseAuth: ref.watch(firebaseAuthProvider),
  );
  final networkInfo = NetworkInfoImpl(ref.watch(networkInfoProvider));
  return VoucherRepositoryImpl(
    remoteDataSource: remoteDataSource,
    networkInfo: networkInfo,
  );
});

// Use case providers
final createVoucherUseCaseProvider = Provider<CreateVoucherUseCase>((ref) {
  final repository = ref.read(voucherRepositoryProvider);
  return CreateVoucherUseCase(repository);
});

final getVouchersUseCaseProvider = Provider<GetVouchersUseCase>((ref) {
  final repository = ref.read(voucherRepositoryProvider);
  return GetVouchersUseCase(repository);
});

// Notifier for voucher management
class VoucherNotifier extends StateNotifier<AsyncValue<List<Voucher>>> {
  final CreateVoucherUseCase createVoucherUseCase;
  final GetVouchersUseCase getVouchersUseCase; // Add GetVouchersUseCase

  VoucherNotifier(this.createVoucherUseCase, this.getVouchersUseCase)
      : super(const AsyncValue.loading()) {
    fetchVouchers(); // Fetch vouchers on initialization
  }

  Future<void> fetchVouchers() async {
    state = const AsyncValue.loading();
    print('Fetching vouchers...'); // Logging
    try {
      final result = await getVouchersUseCase();
      result.fold(
        (failure) {
          print('Failed to fetch vouchers: $failure'); // Logging
          state = AsyncValue.error(failure.toString(), StackTrace.current);
        },
        (vouchers) {
          print(
              'Vouchers fetched successfully: ${vouchers.length} vouchers'); // Logging
          state = AsyncValue.data(vouchers);
        },
      );
    } catch (e) {
      print('Error fetching vouchers: $e'); // Logging
      state = AsyncValue.error(e.toString(), StackTrace.current);
    }
  }

  Future<void> createVoucher(Voucher voucher) async {
    state = const AsyncValue.loading();
    try {
      final result = await createVoucherUseCase(voucher);
      result.fold(
        (failure) {
          state = AsyncValue.error(failure.toString(), StackTrace.current);
        },
        (newVoucher) {
          fetchVouchers(); // Refresh the list from Firestore after creating a new voucher
        },
      );
    } catch (e) {
      state = AsyncValue.error(e.toString(), StackTrace.current);
    }
  }
}

final voucherProvider =
    StateNotifierProvider<VoucherNotifier, AsyncValue<List<Voucher>>>((ref) {
  final createVoucherUseCase = ref.read(createVoucherUseCaseProvider);
  final getVouchersUseCase = ref.read(getVouchersUseCaseProvider);
  return VoucherNotifier(createVoucherUseCase, getVouchersUseCase);
});

final filteredVouchersProvider = Provider<List<Voucher>>((ref) {
  final filter = ref.watch(voucherFilterProvider);
  final vouchers = ref.watch(voucherProvider).value ?? [];
  if (filter == VoucherFilter.all) {
    return vouchers;
  }
  return vouchers.where((voucher) {
    if (filter == VoucherFilter.discount) {
      return voucher.type.toLowerCase().contains('discount');
    } else {
      return voucher.type.toLowerCase().contains('free laundry');
    }
  }).toList();
});
