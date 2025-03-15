import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_laundry_app/presentation/style/app_typography.dart';
import 'package:flutter_laundry_app/presentation/style/colors/background_colors.dart';
import 'package:flutter_laundry_app/presentation/style/sizes/icon_sizes.dart';
import 'package:flutter_laundry_app/presentation/style/sizes/margin_sizes.dart';
import 'package:flutter_laundry_app/presentation/style/sizes/padding_sizes.dart';
import 'package:flutter_laundry_app/presentation/widgets/common/custom_button.dart';
import 'package:flutter_laundry_app/presentation/widgets/common/custom_text_form_field.dart';
import 'package:flutter_laundry_app/presentation/widgets/common/loading_indicator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/order_provider.dart';
import '../../providers/user_provider.dart';

class CreateOrderScreen extends ConsumerStatefulWidget {
  static const routeName = '/create-order-screen';

  const CreateOrderScreen({super.key});

  @override
  CreateOrderScreenState createState() => CreateOrderScreenState();
}

class CreateOrderScreenState extends ConsumerState<CreateOrderScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _uniqueNameController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _clothesController = TextEditingController();
  final TextEditingController _laundrySpeedController = TextEditingController();
  final TextEditingController _vouchersController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  Future<void> _loadUserData() async {
    final userState = ref.read(userProvider);
    if (userState.user == null) {
      try {
        await ref.read(userProvider.notifier).getUser();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load user data: $e')),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _uniqueNameController.dispose();
    _weightController.dispose();
    _clothesController.dispose();
    _laundrySpeedController.dispose();
    _vouchersController.dispose();
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> fetchCustomers() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'Customer')
        .get();

    return snapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }

  void _showCustomerSelectionModal(List<Map<String, dynamic>> customers) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) {
        TextEditingController searchController = TextEditingController();
        List<Map<String, dynamic>> filteredCustomers = List.from(customers);

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter modalSetState) {
            return SafeArea(
              child: Container(
                height: MediaQuery.of(context).size.height * 0.7,
                padding: const EdgeInsets.all(PaddingSizes
                    .cardPadding), // Updated from medium to cardPadding
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.chevron_left,
                            size: IconSizes.navigationIcon,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Text(
                          'Select Unique Name',
                          style: AppTypography.modalTitle,
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                    const SizedBox(height: MarginSizes.modalTop),
                    CustomTextFormField(
                      controller: searchController,
                      hintText: "Search Unique Name...",
                      prefixIcon: Icons.search,
                      onChanged: (value) {
                        modalSetState(() {
                          filteredCustomers = customers
                              .where((customer) => customer['uniqueName']
                                  .toLowerCase()
                                  .contains(value.toLowerCase()))
                              .toList();
                        });
                      },
                    ),
                    const SizedBox(height: MarginSizes.moderate),
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: filteredCustomers.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(filteredCustomers[index]['uniqueName']),
                            onTap: () {
                              if (mounted) {
                                setState(() {
                                  _uniqueNameController.text =
                                      filteredCustomers[index]['uniqueName'];
                                });
                              }
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final orderState = ref.watch(orderNotifierProvider);
    final userState = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create Order',
          style: AppTypography.darkAppBarTitle,
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.chevron_left,
            size: IconSizes.navigationIcon,
          ),
          onPressed: () {
            context.go('/admin-dashboard-screen');
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: PaddingSizes
                  .sectionTitlePadding), // Updated from medium to sectionTitlePadding
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: MarginSizes.medium),
                Text(
                  'Let\'s make your order',
                  style: AppTypography.sectionTitle,
                ),
                const SizedBox(height: MarginSizes.sectionSpacing),
                Text(
                  'Enter customer details to place customer order',
                  style: AppTypography.formInstruction,
                ),
                const SizedBox(height: PaddingSizes.formSpacing),
                if (userState.isLoading || userState.user == null)
                  const Center(child: LoadingIndicator())
                else
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        CustomTextFormField(
                          hintText: 'Select Unique Name',
                          labelText: 'Unique Name',
                          controller: _uniqueNameController,
                          readOnly: true,
                          onTap: () async {
                            final customers = await fetchCustomers();
                            if (mounted) {
                              _showCustomerSelectionModal(customers);
                            }
                          },
                          validator: (value) => value!.isEmpty
                              ? 'Unique name cannot be empty'
                              : null,
                        ),
                        const SizedBox(height: MarginSizes.formFieldSpacing),
                        CustomTextFormField(
                          hintText: 'Input Clothes Weight (kg)',
                          labelText: 'Clothes Weight (kg)',
                          keyboardType: TextInputType.number,
                          controller: _weightController,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Clothing weight cannot be empty';
                            }
                            final weight = double.tryParse(value);
                            if (weight == null || weight <= 0) {
                              return 'Weight must be greater than 0';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: MarginSizes.formFieldSpacing),
                        CustomTextFormField(
                          hintText: 'Input Clothes Quantity',
                          labelText: 'Clothes Quantity',
                          keyboardType: TextInputType.number,
                          controller: _clothesController,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Clothing quantity cannot be empty';
                            }
                            final clothes = int.tryParse(value);
                            if (clothes == null || clothes <= 0) {
                              return 'Quantity must be greater than 0';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: MarginSizes.formFieldSpacing),
                        CustomTextFormField(
                          hintText: 'Select Laundry Speed',
                          labelText: 'Laundry Speed',
                          controller: _laundrySpeedController,
                          readOnly: true,
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (BuildContext context) {
                                return Container(
                                  padding: const EdgeInsets.all(PaddingSizes
                                      .formOuterPadding), // Updated from medium to formOuterPadding
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          IconButton(
                                            icon: Icon(
                                              Icons.chevron_left,
                                              size: IconSizes.navigationIcon,
                                            ),
                                            onPressed: () =>
                                                Navigator.pop(context),
                                          ),
                                          Text(
                                            'Select Laundry Speed',
                                            style: AppTypography.modalTitle,
                                          ),
                                          const SizedBox(width: 48),
                                        ],
                                      ),
                                      ListTile(
                                        title: const Text('Express (1 Day)'),
                                        onTap: () {
                                          if (mounted) {
                                            setState(() {
                                              _laundrySpeedController.text =
                                                  'Express';
                                            });
                                          }
                                          Navigator.pop(context);
                                        },
                                      ),
                                      ListTile(
                                        title: const Text('Reguler (2 Days)'),
                                        onTap: () {
                                          if (mounted) {
                                            setState(() {
                                              _laundrySpeedController.text =
                                                  'Reguler';
                                            });
                                          }
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                          validator: (value) => value!.isEmpty
                              ? 'Laundry speed cannot be empty'
                              : null,
                        ),
                        const SizedBox(height: MarginSizes.formFieldSpacing),
                        CustomTextFormField(
                          hintText: 'Select Voucher',
                          labelText: 'Voucher',
                          controller: _vouchersController,
                        ),
                        const SizedBox(height: PaddingSizes.formSpacing),
                        CustomButton(
                          text: 'Confirm Order',
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              String uniqueName = _uniqueNameController.text;
                              double weight =
                                  double.parse(_weightController.text);
                              int clothes = int.parse(_clothesController.text);
                              String laundrySpeed =
                                  _laundrySpeedController.text;
                              List<String> vouchers = _vouchersController.text
                                  .split(',')
                                  .map((e) => e.trim())
                                  .where((e) => e.isNotEmpty)
                                  .toList();

                              final regulerPrice =
                                  (userState.user!.regulerPrice).toDouble();
                              final expressPrice =
                                  (userState.user!.expressPrice).toDouble();

                              double totalPrice = laundrySpeed == 'Express'
                                  ? expressPrice * weight
                                  : regulerPrice * weight;

                              final scaffoldMessenger =
                                  ScaffoldMessenger.of(context);
                              final router = GoRouter.of(context);

                              try {
                                await ref
                                    .read(orderNotifierProvider.notifier)
                                    .createOrder(
                                      uniqueName,
                                      weight,
                                      clothes,
                                      laundrySpeed,
                                      vouchers,
                                      totalPrice,
                                    );

                                if (mounted) {
                                  scaffoldMessenger.showSnackBar(
                                    SnackBar(
                                      content: const Text(
                                          'Order successfully created'),
                                      backgroundColor: BackgroundColors.success,
                                    ),
                                  );
                                  router.go('/manage-orders-screen');
                                }
                              } catch (e) {
                                if (mounted) {
                                  scaffoldMessenger.showSnackBar(
                                    SnackBar(
                                      content:
                                          Text('Failed to create order: $e'),
                                      backgroundColor: BackgroundColors.error,
                                    ),
                                  );
                                }
                              }
                            }
                          },
                        ),
                        if (orderState.isLoading)
                          Padding(
                            padding: EdgeInsets.only(
                                top: PaddingSizes
                                    .sectionTitlePadding), // Updated from medium to sectionTitlePadding
                            child: const LoadingIndicator(),
                          ),
                        if (orderState.errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(
                                top: PaddingSizes
                                    .sectionTitlePadding), // Updated from medium to sectionTitlePadding
                            child: Text(
                              orderState.errorMessage!,
                              style: AppTypography.errorText,
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
