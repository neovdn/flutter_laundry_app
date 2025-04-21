import 'package:flutter_laundry_app/presentation/screens/admin/manage_orders_screen.dart';
import 'package:flutter_laundry_app/presentation/screens/admin/price_management_screen.dart';
import 'package:flutter_laundry_app/presentation/screens/dashboard/admin_dashboard_screen.dart';
import 'package:flutter_laundry_app/presentation/screens/dashboard/user_dashboard_screen.dart';
import 'package:flutter_laundry_app/presentation/screens/order/create_order_screen.dart';
import 'package:flutter_laundry_app/presentation/screens/order/order_tracking_screen.dart';
import 'package:flutter_laundry_app/presentation/screens/auth/login_screen.dart';
import 'package:flutter_laundry_app/presentation/screens/auth/register_screen.dart';
import 'package:flutter_laundry_app/presentation/screens/splash_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_laundry_app/presentation/screens/voucher/voucher_list_screen.dart.dart';
import 'package:flutter_laundry_app/presentation/screens/voucher/create_voucher_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash-screen', // Atur splash screen sebagai rute awal
    routes: [
      GoRoute(
        path: '/splash-screen',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register-screen',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/login-screen',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/user-dashboard-screen',
        builder: (context, state) => const UserDashboardScreen(),
      ),
      GoRoute(
        path: '/admin-dashboard-screen',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/create-order-screen',
        builder: (context, state) => const CreateOrderScreen(),
      ),
      GoRoute(
        path: '/manage-orders-screen',
        builder: (context, state) => const ManageOrdersScreen(),
      ),
      GoRoute(
        path: '/order-tracking-screen',
        builder: (context, state) => const OrderTrackingScreen(),
      ),
      GoRoute(
        path: '/price-management-screen',
        builder: (context, state) => const PriceManagementScreen(),
      ),
      GoRoute(
        path: '/create-voucher',
        builder: (context, state) => const CreateVoucherScreen(),
      ),
      GoRoute(
        path: '/vouchers', // Add the route for VoucherListScreen
        builder: (context, state) => const VoucherListScreen(),
      ),
    ],
  );
});
