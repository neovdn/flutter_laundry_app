import 'package:flutter/material.dart';
import 'package:flutter_laundry_app/presentation/providers/order_provider.dart'
    as order_provider; // Alias lower_case_with_underscores
import 'package:flutter_laundry_app/presentation/style/app_typography.dart';
import 'package:flutter_laundry_app/presentation/style/colors/background_colors.dart';
import 'package:flutter_laundry_app/presentation/style/colors/text_colors.dart';
import 'package:flutter_laundry_app/presentation/style/sizes/icon_sizes.dart';
import 'package:flutter_laundry_app/presentation/style/sizes/padding_sizes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';

class UserDashboardScreen extends ConsumerWidget {
  static const routeName = '/user-dashboard-screen';

  const UserDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Scaffold(
      backgroundColor: BackgroundColors.dashboardBackground,
      appBar: AppBar(
        backgroundColor: BackgroundColors.appBarBackground,
        shadowColor: BackgroundColors.transparent,
        surfaceTintColor: BackgroundColors.transparent,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: PaddingSizes.dashboardHorizontal,
              ),
              child: Text(
                'Dashboard',
                style: AppTypography.appBarTitle,
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.logout,
                size: IconSizes.logout,
                color: TextColors.lightText,
              ),
              onPressed: () {
                _handleLogout(context, ref);
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            user == null
                ? const Center(child: CircularProgressIndicator())
                : Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: PaddingSizes.sectionTitlePadding,
                            vertical: PaddingSizes.dashboardVertical,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome!',
                                style: AppTypography.welcomeIntro,
                              ),
                              Text(
                                'Customer ${user.fullName}',
                                style: AppTypography.welcomeFullName,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: BackgroundColors.contentContainer,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(24),
                                topRight: Radius.circular(24),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(
                                  PaddingSizes.contentContainerPadding),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(
                                        PaddingSizes.formOuterPadding),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Our services',
                                          style: AppTypography.sectionTitle,
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Tambahkan SingleChildScrollView untuk scrolling vertikal
                                  Expanded(
                                    child: SingleChildScrollView(
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  context.go(
                                                      '/order-tracking-screen');
                                                },
                                                child: SizedBox(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.48,
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.48,
                                                  child: SvgPicture.asset(
                                                    'assets/svg/track_orders.svg',
                                                    fit: BoxFit.contain,
                                                  ),
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: () {},
                                                child: SizedBox(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.48,
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.48,
                                                  child: SvgPicture.asset(
                                                    'assets/svg/history.svg',
                                                    fit: BoxFit.contain,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(
                                              height: 16), // Jarak antar baris
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  context.go('/vouchers');
                                                },
                                                child: SizedBox(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.48,
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.48,
                                                  child: SvgPicture.asset(
                                                    'assets/svg/voucher.svg',
                                                    fit: BoxFit.contain,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    navigateToLogin() => context.go('/login-screen');

    try {
      await ref.read(order_provider.firebaseAuthProvider).signOut();
      ref.invalidate(order_provider.currentUserUniqueNameProvider);
      ref.invalidate(order_provider.customerOrdersProvider);

      if (context.mounted) {
        navigateToLogin();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error signing out: $e')),
        );
      }
    }
  }
}
