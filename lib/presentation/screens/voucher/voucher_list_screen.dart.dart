import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../core/error/failures.dart';
import '../../providers/voucher_provider.dart';
import '../../widgets/voucher/voucher_card.dart';
import '../../widgets/common/loading_indicator.dart';

class VoucherListScreen extends ConsumerWidget {
  const VoucherListScreen({super.key});

  Widget _buildFilterChip(
      BuildContext context, WidgetRef ref, VoucherFilter filter) {
    final selectedFilter = ref.watch(voucherFilterProvider);
    final isSelected = selectedFilter == filter;

    return FilterChip(
      label: Text(
        _getFilterName(filter),
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black54,
          fontWeight: FontWeight.w500,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        ref.read(voucherFilterProvider.notifier).state = filter;
      },
      checkmarkColor: Colors.white,
      backgroundColor: Colors.grey[200],
      selectedColor: const Color(0xFF95BBE3),
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  String _getFilterName(VoucherFilter filter) {
    switch (filter) {
      case VoucherFilter.all:
        return 'ALL VOUCHERS';
      case VoucherFilter.discount:
        return 'DISCOUNT';
      case VoucherFilter.freeLaundry:
        return 'FREE LAUNDRY';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vouchers = ref.watch(filteredVouchersProvider);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.go('/user-dashboard-screen'),
        ),
        title: const Text(
          'Voucher',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(voucherProvider.notifier).fetchVouchers();
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'My Vouchers',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.grey[100]!,
                    Colors.grey[200]!,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _buildFilterChip(context, ref, VoucherFilter.all),
                    const SizedBox(width: 8),
                    _buildFilterChip(context, ref, VoucherFilter.discount),
                    const SizedBox(width: 8),
                    _buildFilterChip(context, ref, VoucherFilter.freeLaundry),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ref.watch(voucherProvider).when(
                    data: (allVouchers) {
                      if (vouchers.isEmpty) {
                        return const Center(
                            child: Text('No vouchers available'));
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.only(top: 8),
                        itemCount: vouchers.length,
                        itemBuilder: (context, index) {
                          return VoucherCard(voucher: vouchers[index]);
                        },
                      );
                    },
                    loading: () => const Center(child: LoadingIndicator()),
                    error: (error, stackTrace) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            error is ServerFailure
                                ? error.message
                                : error is NetworkFailure
                                    ? error.message
                                    : 'Failed to load vouchers: $error',
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              ref
                                  .read(voucherProvider.notifier)
                                  .fetchVouchers();
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
