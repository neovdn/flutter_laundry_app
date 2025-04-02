// ignore_for_file: unused_result

import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:dartz/dartz.dart';
import 'package:flutter_laundry_app/core/error/failures.dart';
import 'package:flutter_laundry_app/data/datasources/remote/firebase_database_remote_data_source.dart';
import 'package:flutter_laundry_app/data/models/order_model.dart';
import 'package:flutter_laundry_app/data/repositories/order_repository_impl.dart';
import 'package:flutter_laundry_app/domain/repositories/order_repository.dart';
import 'package:flutter_laundry_app/domain/usecases/order/predict_completion_time_usecase.dart';
import 'package:flutter_laundry_app/presentation/providers/user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/order_number_generator.dart';
import '../../domain/entities/order.dart' as domain;
import '../../domain/usecases/order/create_order_usecase.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class OrderState {
  final bool isLoading;
  final bool isLoadingPrediction; // Tambahkan properti ini
  final String? errorMessage;
  final DateTime? predictedCompletion;

  OrderState({
    this.isLoading = false,
    this.isLoadingPrediction = false, // Default false
    this.errorMessage,
    this.predictedCompletion,
  });

  OrderState copyWith({
    bool? isLoading,
    bool? isLoadingPrediction,
    String? errorMessage,
    DateTime? predictedCompletion,
  }) {
    return OrderState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingPrediction: isLoadingPrediction ?? this.isLoadingPrediction,
      errorMessage: errorMessage ?? this.errorMessage,
      predictedCompletion: predictedCompletion ?? this.predictedCompletion,
    );
  }
}

class OrderNotifier extends StateNotifier<OrderState> {
  final CreateOrderUseCase createOrderUseCase;
  final PredictCompletionTimeUseCase predictCompletionTimeUseCase;
  final firebase_auth.FirebaseAuth firebaseAuth;
  final Ref ref;

  OrderNotifier({
    required this.createOrderUseCase,
    required this.predictCompletionTimeUseCase,
    required this.firebaseAuth,
    required this.ref,
  }) : super(OrderState());

  Future<void> createOrder(
    String customerUniqueName,
    double weight,
    int clothes,
    String laundrySpeed,
    List<String> vouchers,
    double totalPrice,
  ) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final id = OrderNumberGenerator.generateUniqueNumber();
    final currentUser = firebaseAuth.currentUser;
    if (currentUser == null) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'No user logged in',
      );
      return;
    }

    try {
      final user = await ref.read(currentUserProvider.future);
      final laundryUniqueName = user.uniqueName;

      ref.read(orderRepositoryProvider);

      final order = domain.Order(
        id: id,
        laundryUniqueName: laundryUniqueName,
        customerUniqueName: customerUniqueName,
        weight: weight,
        clothes: clothes,
        laundrySpeed: laundrySpeed,
        vouchers: vouchers,
        totalPrice: totalPrice,
        status: 'pending',
        createdAt: DateTime.now(),
        estimatedCompletion: state.predictedCompletion ?? DateTime.now(),
      );

      final result = await createOrderUseCase(order);
      result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
          );
        },
        (_) {
          state = state.copyWith(
            isLoading: false,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<Either<Failure, DateTime?>> predictCompletionTime({
    required double weight,
    required int clothes,
    required String laundrySpeed,
  }) async {
    state = state.copyWith(isLoadingPrediction: true, errorMessage: null);

    final orderModel = OrderModel(
      id: '',
      laundryUniqueName: '',
      customerUniqueName: '',
      weight: weight,
      clothes: clothes,
      laundrySpeed: laundrySpeed,
      vouchers: [],
      totalPrice: 0.0,
      status: 'pending',
      createdAt: DateTime.now(),
      estimatedCompletion: DateTime.now(),
    );

    final result = await predictCompletionTimeUseCase(orderModel);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoadingPrediction: false,
          errorMessage: failure.message,
          predictedCompletion: null,
        );
      },
      (predictedCompletion) {
        state = state.copyWith(
          isLoadingPrediction: false,
          predictedCompletion: predictedCompletion,
        );
      },
    );

    return result;
  }

  void resetPrediction() {
    state = OrderState(
      isLoading: state.isLoading,
      isLoadingPrediction: false,
      errorMessage: state.errorMessage,
      predictedCompletion: null,
    );
  }
}

// Providers
final orderNotifierProvider =
    StateNotifierProvider<OrderNotifier, OrderState>((ref) {
  final createOrderUseCase = ref.read(createOrderUseCaseProvider);
  final predictCompletionTimeUseCase =
      ref.read(predictCompletionTimeUseCaseProvider);
  final firebaseAuth = ref.read(firebaseAuthProvider);
  return OrderNotifier(
    createOrderUseCase: createOrderUseCase,
    predictCompletionTimeUseCase: predictCompletionTimeUseCase,
    firebaseAuth: firebaseAuth,
    ref: ref,
  );
});

final predictCompletionTimeUseCaseProvider =
    Provider<PredictCompletionTimeUseCase>((ref) {
  final repository = ref.read(orderRepositoryProvider);
  return PredictCompletionTimeUseCase(repository);
});

final firestoreProvider = Provider<firestore.FirebaseFirestore>((ref) {
  return firestore.FirebaseFirestore.instance;
});

final firebaseAuthProvider = Provider<firebase_auth.FirebaseAuth>((ref) {
  return firebase_auth.FirebaseAuth.instance;
});

final firebaseDatabaseRemoteDataSourceProvider =
    Provider<FirebaseDatabaseRemoteDataSource>((ref) {
  final firestore = ref.watch(firestoreProvider);
  final firebaseAuth = ref.watch(firebaseAuthProvider);
  return FirebaseDatabaseRemoteDataSourceImpl(
    firestore: firestore,
    firebaseAuth: firebaseAuth,
  );
});

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  final firestore = ref.watch(firestoreProvider);
  final remoteDataSource = ref.watch(firebaseDatabaseRemoteDataSourceProvider);
  return OrderRepositoryImpl(
    firestore: firestore,
    remoteDataSource: remoteDataSource,
  );
});

final createOrderUseCaseProvider = Provider<CreateOrderUseCase>((ref) {
  final repository = ref.read(orderRepositoryProvider);
  return CreateOrderUseCase(repository);
});

// Order states
enum OrderFilter { all, pending, processing, completed, cancelled }

final orderFilterProvider = StateProvider<OrderFilter>((ref) {
  return OrderFilter.all;
});

// Define currentUserUniqueNameProvider at the top level
final currentUserUniqueNameProvider = FutureProvider<String>((ref) async {
  final user = firebase_auth.FirebaseAuth.instance.currentUser;
  if (user == null) throw Exception('No user logged in');

  final userDoc = await firestore.FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .get();
  if (!userDoc.exists) throw Exception('User data not found');
  return userDoc['uniqueName'] as String;
});

// Add authStateProvider
final authStateProvider = StreamProvider<firebase_auth.User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

// Add userRoleProvider
final userRoleProvider = FutureProvider<String>((ref) async {
  final user = firebase_auth.FirebaseAuth.instance.currentUser;
  if (user == null) throw Exception('No user logged in');

  final userDoc = await firestore.FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .get();
  if (!userDoc.exists) throw Exception('User data not found');
  return userDoc['role'] as String; // "customer" atau "admin"
});

// Customer Orders Provider
final customerOrdersProvider = StreamProvider<List<domain.Order>>((ref) async* {
  final authState = ref.watch(authStateProvider);
  if (authState.value == null) {
    yield [];
    return;
  }

  final uniqueName = await ref.watch(currentUserUniqueNameProvider.future);
  final filter = ref.watch(orderFilterProvider);

  var query = firestore.FirebaseFirestore.instance
      .collection('orders')
      .where('customerUniqueName', isEqualTo: uniqueName);

  if (filter != OrderFilter.all) {
    query = query.where('status', isEqualTo: filter.name);
  }

  yield* query.snapshots().map((snapshot) => snapshot.docs.map((doc) {
        final data = doc.data();
        return OrderModel.fromJson(data, doc.id);
      }).toList());
});

// Laundry Orders Provider
final laundryOrdersProvider = StreamProvider<List<domain.Order>>((ref) async* {
  final authState = ref.watch(authStateProvider);
  if (authState.value == null) {
    yield [];
    return;
  }

  final uniqueName = await ref.watch(currentUserUniqueNameProvider.future);
  final filter = ref.watch(orderFilterProvider);

  var query = firestore.FirebaseFirestore.instance
      .collection('orders')
      .where('laundryUniqueName', isEqualTo: uniqueName);

  if (filter != OrderFilter.all) {
    query = query.where('status', isEqualTo: filter.name);
  }

  yield* query.snapshots().map((snapshot) => snapshot.docs.map((doc) {
        final data = doc.data();
        return OrderModel.fromJson(data, doc.id);
      }).toList());
});

// Order Actions Provider
final orderActionsProvider = Provider<OrderActions>((ref) {
  final repository = ref.watch(orderRepositoryProvider);
  return OrderActions(repository: repository, ref: ref);
});

class OrderActions {
  final OrderRepository repository;
  final Ref ref;

  OrderActions({required this.repository, required this.ref});

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    final result =
        await repository.updateOrderStatusAndCompletion(orderId, newStatus);
    result.fold(
      (failure) => throw Exception(failure.message),
      (_) {
        final userRoleAsync = ref.read(userRoleProvider);
        if (userRoleAsync.hasValue) {
          final userRole = userRoleAsync.value;
          if (userRole == 'admin') {
            ref.refresh(laundryOrdersProvider);
          } else {
            ref.refresh(customerOrdersProvider);
          }
        }
      },
    );
  }

  Future<void> deleteOrder(String orderId) async {
    final result = await repository.deleteOrder(orderId);
    result.fold(
      (failure) => throw Exception(failure.message),
      (_) {
        final userRoleAsync = ref.read(userRoleProvider);
        if (userRoleAsync.hasValue) {
          final userRole = userRoleAsync.value;
          if (userRole == 'admin') {
            ref.refresh(laundryOrdersProvider);
          } else {
            ref.refresh(customerOrdersProvider);
          }
        }
      },
    );
  }
}
