import 'package:flutter/material.dart';
import 'package:flutter_laundry_app/domain/entities/order.dart';
import 'package:flutter_laundry_app/presentation/providers/order_provider.dart';
import 'package:flutter_laundry_app/presentation/style/app_typography.dart';
import 'package:flutter_laundry_app/presentation/style/colors/background_colors.dart';
import 'package:flutter_laundry_app/presentation/style/colors/button_colors.dart';
import 'package:flutter_laundry_app/presentation/style/colors/text_colors.dart';
import 'package:flutter_laundry_app/presentation/style/sizes/icon_sizes.dart';
import 'package:flutter_laundry_app/presentation/style/sizes/margin_sizes.dart';
import 'package:flutter_laundry_app/presentation/style/sizes/padding_sizes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/order/order_card.dart';
import '../../widgets/common/loading_indicator.dart';

class OrderTrackingScreen extends ConsumerWidget {
  const OrderTrackingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        if (user == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go('/login-screen');
          });
          return const Scaffold(
            body: Center(child: LoadingIndicator()),
          );
        }
        return _buildOrdersScreen(context, ref);
      },
      loading: () => const Scaffold(
        body: Center(child: LoadingIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildOrdersScreen(BuildContext context, WidgetRef ref) {
    final selectedFilter = ref.watch(orderFilterProvider);
    final ordersAsync = ref.watch(customerOrdersProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: BackgroundColors.transparent,
        shadowColor: BackgroundColors.transparent,
        surfaceTintColor: BackgroundColors.transparent,
        leading: IconButton(
          icon: const Icon(
            Icons.chevron_left,
            size: IconSizes.navigationIcon,
          ),
          onPressed: () {
            context.go('/user-dashboard-screen');
          },
        ),
        title: Text(
          'Track Orders',
          style: AppTypography.darkAppBarTitle,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(customerOrdersProvider),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              right: PaddingSizes.sectionTitlePadding, // Updated from medium
              left: PaddingSizes.sectionTitlePadding, // Updated from medium
              top: PaddingSizes.topOnly,
            ),
            child: Text(
              'Tracking your orders',
              style: AppTypography.sectionTitle,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(
                PaddingSizes.cardPadding), // Updated from medium
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip(context, ref, OrderFilter.all),
                  const SizedBox(width: MarginSizes.filterChipSpacing),
                  _buildFilterChip(context, ref, OrderFilter.pending),
                  const SizedBox(width: MarginSizes.filterChipSpacing),
                  _buildFilterChip(context, ref, OrderFilter.processing),
                  const SizedBox(width: MarginSizes.filterChipSpacing),
                  _buildFilterChip(context, ref, OrderFilter.completed),
                  const SizedBox(width: MarginSizes.filterChipSpacing),
                  _buildFilterChip(context, ref, OrderFilter.cancelled),
                ],
              ),
            ),
          ),
          Expanded(
            child: ordersAsync.when(
              data: (orders) {
                if (orders.isEmpty) {
                  return _buildEmptyState(context, selectedFilter);
                }
                return _buildOrdersList(orders);
              },
              loading: () => const Center(child: LoadingIndicator()),
              error: (error, stackTrace) => Center(
                child: Text(
                  'Error: ${error.toString()}',
                  style: AppTypography.errorText,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
      BuildContext context, WidgetRef ref, OrderFilter filter) {
    final selectedFilter = ref.watch(orderFilterProvider);
    final isSelected = selectedFilter == filter;

    return Material(
      elevation: isSelected ? 6 : 2,
      shadowColor: Colors.black.withAlpha(76),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: FilterChip(
        label: Text(
          _getFilterName(filter),
          style: TextStyle(
            color: isSelected
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
        selected: isSelected,
        onSelected: (selected) {
          ref.read(orderFilterProvider.notifier).state = filter;
        },
        checkmarkColor: TextColors.lightText,
        backgroundColor: ButtonColors.filterChipUnselected,
        selectedColor: ButtonColors.filterChipSelected,
        side: BorderSide.none,
      ),
    );
  }

  String _getFilterName(OrderFilter filter) {
    switch (filter) {
      case OrderFilter.all:
        return 'All Orders';
      case OrderFilter.pending:
        return 'Pending';
      case OrderFilter.processing:
        return 'Processing';
      case OrderFilter.completed:
        return 'Completed';
      case OrderFilter.cancelled:
        return 'Cancelled';
    }
  }

  Widget _buildOrdersList(List<Order> orders) {
    return ListView.builder(
  padding: const EdgeInsets.only(bottom: PaddingSizes.sectionTitlePadding), // Updated from medium to sectionTitlePadding
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return OrderCard(order: order, isAdmin: false);
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, OrderFilter filter) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: IconSizes.emptyStateIcon,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(
              height: MarginSizes.medium), // Assuming medium for consistency
          Text(
            'No ${_getFilterName(filter).toLowerCase()} found',
            style: AppTypography.emptyStateTitle,
          ),
          const SizedBox(
              height: MarginSizes.small), // Assuming small for consistency
          Text(
            'Orders matching your filter will appear here',
            style: AppTypography.emptyStateSubtitle,
          ),
        ],
      ),
    );
  }
}
