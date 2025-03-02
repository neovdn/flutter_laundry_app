import 'package:flutter_laundry_app/core/config/firebase_config.dart';
import 'package:flutter_laundry_app/domain/usecases/auth/login_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/auth/register_usecase.dart';
import '../../core/error/failures.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/datasources/remote/firebase_auth_remote_data_source.dart';
import '../../core/network/network_info.dart';

// Firebase dan network dependencies
final firebaseAuthRemoteDataSourceProvider =
    Provider<FirebaseAuthRemoteDataSource>((ref) {
  final firebaseAuth = ref.watch(firebaseAuthProvider);
  final firestore = ref.watch(firestoreProvider);
  return FirebaseAuthRemoteDataSourceImpl(
    firebaseAuth: firebaseAuth,
    firestore: firestore,
  );
});

final networkInfoProvider = Provider<NetworkInfo>((ref) {
  final connectionChecker = ref.watch(connectionCheckerProvider);
  return NetworkInfoImpl(connectionChecker);
});

// Auth repository implementation
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remoteDataSource = ref.watch(firebaseAuthRemoteDataSourceProvider);
  final networkInfo = ref.watch(networkInfoProvider);
  return AuthRepositoryImpl(
    remoteDataSource: remoteDataSource,
    networkInfo: networkInfo,
  );
});

// Register use case
final registerUseCaseProvider = Provider<RegisterUseCase>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return RegisterUseCase(authRepository);
});

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return LoginUseCase(authRepository);
});

// Auth state
enum AuthStatus { initial, loading, success, error }

class AuthState {
  final AuthStatus status;
  final User? user;
  final Failure? failure;
  final String operationType; // Add this field

  AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.failure,
    this.operationType = '', // Default empty string
  });

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    Failure? failure,
    String? operationType,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      failure: failure ?? this.failure,
      operationType: operationType ?? this.operationType,
    );
  }
}

// Auth notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final RegisterUseCase _registerUseCase;
  final LoginUseCase _loginUseCase;
  bool _isProcessing = false; // Tambahkan flag untuk melacak proses

  AuthNotifier(this._registerUseCase, this._loginUseCase) : super(AuthState());

  void resetState() {
    state = AuthState();
    _isProcessing = false; // Reset flag
  }

  Future<void> register({
    required String role,
    required String fullName,
    required String uniqueName,
    required String email,
    required String password,
    required String phoneNumber,
    required String address,
  }) async {
    if (_isProcessing) return; // Cegah pemanggilan berulang
    _isProcessing = true;
    state = AuthState(operationType: 'register'); // Set operation type

    state = state.copyWith(status: AuthStatus.loading);

    final result = await _registerUseCase(
      role: role,
      fullName: fullName,
      uniqueName: uniqueName,
      email: email,
      password: password,
      phoneNumber: phoneNumber,
      address: address,
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        failure: failure,
      ),
      (user) => state = state.copyWith(
        status: AuthStatus.success,
        user: user,
      ),
    );
    _isProcessing = false; // Reset flag setelah selesai
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    if (_isProcessing) return; // Cegah pemanggilan berulang
    _isProcessing = true;

    state = AuthState(operationType: 'login');
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _loginUseCase(
      email: email,
      password: password,
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        failure: failure,
      ),
      (user) => state = state.copyWith(
        status: AuthStatus.success,
        user: user,
      ),
    );

    _isProcessing = false; // Reset flag setelah selesai
  }
}

// Auth provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final registerUseCase = ref.watch(registerUseCaseProvider);
  final loginUseCase = ref.watch(loginUseCaseProvider);
  return AuthNotifier(registerUseCase, loginUseCase);
});
