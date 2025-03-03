import 'package:flutter/material.dart';
import 'package:flutter_laundry_app/presentation/style/colors/background_colors.dart';
import 'package:flutter_laundry_app/presentation/style/colors/text_colors.dart';
import 'package:flutter_laundry_app/presentation/style/typography.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';

class UserDashboardScreen extends ConsumerWidget {
  static const routeName = '/user-dashboard';

  const UserDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Scaffold(
      backgroundColor: BackgroundColors.secondary,
      appBar: AppBar(
        backgroundColor: BackgroundColors.secondary,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Dashboard',
              style: AppTypography.heading4,
            ),
            IconButton(
              icon: const Icon(
                Icons.logout,
                color: TextColors.quaternary,
              ),
              onPressed: () {
                ref.read(authProvider.notifier).resetState();
                context.go('/login'); // Kembali ke login dan bersihkan stack
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
                    // Add this Expanded widget
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Selamat Datang!',
                                style: AppTypography.heading2,
                              ),
                              Text(
                                'Customer ${user.fullName}',
                                style: AppTypography.heading1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          // Add this Expanded widget
                          child: Container(
                              width: double.infinity, // Ensure full width
                              decoration: BoxDecoration(
                                color: BackgroundColors.primary,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(24),
                                  topRight: Radius.circular(24),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    // Baris pertama SVG
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.48,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.48,
                                          child: SvgPicture.asset(
                                            'assets/svg/create_order_customer.svg',
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                        SizedBox(
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
                                      ],
                                    ),

                                    // Baris kedua SVG
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.48,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.48,
                                          child: SvgPicture.asset(
                                            'assets/svg/edit_address.svg',
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                        SizedBox(
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
                                      ],
                                    ),
                                  ],
                                ),
                              )),
                        ),
                      ],
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
