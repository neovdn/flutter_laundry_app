import 'package:flutter_laundry_app/presentation/screens/admin/manage_orders_screen.dart';
import 'package:flutter_laundry_app/presentation/screens/admin/price_management_screen.dart';
import 'package:flutter_laundry_app/presentation/screens/dashboard/admin_dashboard_screen.dart';
import 'package:flutter_laundry_app/presentation/screens/dashboard/user_dashboard_screen.dart';
import 'package:flutter_laundry_app/presentation/screens/order/create_order_screen.dart';
import 'package:flutter_laundry_app/presentation/screens/order/order_tracking_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_laundry_app/presentation/screens/auth/login_screen.dart';
import 'package:flutter_laundry_app/presentation/screens/auth/register_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    routes: [
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
    ],
  );
});
