import 'package:flutter_laundry_app/core/error/failures.dart';
import 'package:flutter_laundry_app/data/repositories/user_repository_impl.dart';
import 'package:flutter_laundry_app/domain/entities/user.dart';
import 'package:flutter_laundry_app/domain/usecases/user/get_user_usecase.dart';
import 'package:flutter_laundry_app/domain/usecases/user/update_laundry_price_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart' as fs;
import 'package:flutter_laundry_app/data/datasources/remote/firebase_auth_remote_data_source.dart';
import 'package:flutter_laundry_app/data/datasources/remote/firebase_database_remote_data_source.dart';
import 'package:flutter_laundry_app/core/network/network_info.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

// Firebase services
final firebaseAuthProvider = Provider<auth.FirebaseAuth>((ref) {
  return auth.FirebaseAuth.instance;
});

final firestoreProvider = Provider<fs.FirebaseFirestore>((ref) {
  return fs.FirebaseFirestore.instance;
});

final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfoImpl(InternetConnectionChecker.createInstance());
});

// Data source providers
final firebaseAuthRemoteDataSourceProvider =
    Provider<FirebaseAuthRemoteDataSource>((ref) {
  return FirebaseAuthRemoteDataSourceImpl(
    firebaseAuth: ref.watch(firebaseAuthProvider),
    firestore: ref.watch(firestoreProvider),
  );
});

final firebaseDatabaseRemoteDataSourceProvider =
    Provider<FirebaseDatabaseRemoteDataSource>((ref) {
  return FirebaseDatabaseRemoteDataSourceImpl(
    firestore: ref.watch(firestoreProvider),
    firebaseAuth: ref.watch(firebaseAuthProvider),
  );
});

// Repository provider
final userRepositoryProvider = Provider<UserRepositoryImpl>((ref) {
  return UserRepositoryImpl(
    authRemoteDataSource: ref.watch(firebaseAuthRemoteDataSourceProvider),
    databaseRemoteDataSource:
        ref.watch(firebaseDatabaseRemoteDataSourceProvider),
    networkInfo: ref.watch(networkInfoProvider),
  );
});

// Use case providers
final getUserUseCaseProvider = Provider<GetUserUseCase>((ref) {
  return GetUserUseCase(ref.watch(userRepositoryProvider));
});

final updateLaundryPriceUseCaseProvider =
    Provider<UpdateLaundryPriceUseCase>((ref) {
  return UpdateLaundryPriceUseCase(ref.watch(userRepositoryProvider));
});

class UserState {
  final User? user;
  final bool isLoading;
  final Failure? failure;

  UserState({
    this.user,
    this.isLoading = false,
    this.failure,
  });

  UserState copyWith({
    User? user,
    bool? isLoading,
    Failure? failure,
  }) {
    return UserState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      failure: failure ?? this.failure,
    );
  }
}

class UserNotifier extends StateNotifier<UserState> {
  final GetUserUseCase _getUserUseCase;
  final UpdateLaundryPriceUseCase _updateLaundryPriceUseCase;

  UserNotifier({
    required GetUserUseCase getUserUseCase,
    required UpdateLaundryPriceUseCase updateLaundryPriceUseCase,
  })  : _getUserUseCase = getUserUseCase,
        _updateLaundryPriceUseCase = updateLaundryPriceUseCase,
        super(UserState());

  Future<void> getUser() async {
    state = state.copyWith(isLoading: true, failure: null);
    final result = await _getUserUseCase();
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, failure: failure),
      (user) => state = state.copyWith(isLoading: false, user: user),
    );
  }

  Future<void> updateLaundryPrice(int regulerPrice, int expressPrice) async {
    state = state.copyWith(isLoading: true, failure: null);
    final result = await _updateLaundryPriceUseCase(regulerPrice, expressPrice);
    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, failure: failure);
        throw Exception('Failed to update prices: ${failure.message}');
      },
      (user) => state = state.copyWith(isLoading: false, user: user),
    );
  }
}

final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  final getUserUseCase = ref.watch(getUserUseCaseProvider);
  final updateLaundryPriceUseCase =
      ref.watch(updateLaundryPriceUseCaseProvider);
  return UserNotifier(
    getUserUseCase: getUserUseCase,
    updateLaundryPriceUseCase: updateLaundryPriceUseCase,
  );
});

// Tambahkan provider ini
final currentUserProvider = FutureProvider<User>((ref) async {
  final firebaseAuth = ref.watch(firebaseAuthProvider);
  final firestore = ref.watch(firestoreProvider);

  final currentUser = firebaseAuth.currentUser;
  if (currentUser == null) {
    throw Exception('No user logged in');
  }

  final userDoc =
      await firestore.collection('users').doc(currentUser.uid).get();

  if (!userDoc.exists) {
    throw Exception('User data not found');
  }

  final data = userDoc.data()!;
  
  // Tangani createdAt yang bisa berupa String atau Timestamp
  DateTime createdAt;
  if (data['createdAt'] is fs.Timestamp) {
    createdAt = (data['createdAt'] as fs.Timestamp).toDate();
  } else if (data['createdAt'] is String) {
    createdAt = DateTime.parse(data['createdAt'] as String);
  } else {
    // Jika createdAt tidak ada atau format tidak dikenali, gunakan default
    createdAt = DateTime.now();
  }

  return User(
    id: currentUser.uid,
    role: data['role'] as String,
    fullName: data['fullName'] as String,
    uniqueName: data['uniqueName'] as String,
    email: data['email'] as String,
    phoneNumber: data['phoneNumber'] as String,
    address: data['address'] as String,
    regulerPrice: data['regulerPrice'] as int? ?? 7000,
    expressPrice: data['expressPrice'] as int? ?? 10000,
    createdAt: createdAt,
  );
});