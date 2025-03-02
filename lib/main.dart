import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_laundry_app/core/router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import 'core/config/firebase_config.dart';
import 'core/network/network_info.dart';
import 'data/datasources/remote/firebase_auth_remote_data_source.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'presentation/providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Membuat container dengan overrides
  final container = ProviderContainer(
    overrides: [
      // Mendefinisikan implementasi untuk authRepositoryProvider
      authRepositoryProvider.overrideWith((ref) {
        final firebaseAuth = ref.watch(firebaseAuthProvider);
        final firestore = ref.watch(firestoreProvider);

        final remoteDataSource = FirebaseAuthRemoteDataSourceImpl(
          firebaseAuth: firebaseAuth,
          firestore: firestore,
        );

        final networkInfo =
            NetworkInfoImpl(InternetConnectionChecker.createInstance());

        return AuthRepositoryImpl(
          remoteDataSource: remoteDataSource,
          networkInfo: networkInfo,
        );
      }),
    ],
  );

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(routerProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Laundry App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      routerConfig: goRouter,
    );
  }
}
