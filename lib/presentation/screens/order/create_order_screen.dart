import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Tambahkan untuk TextInputFormatter
import 'package:flutter_laundry_app/data/models/order_model.dart';
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

// Custom TextInputFormatter untuk membatasi input maksimum 100
class MaxValueInputFormatter extends TextInputFormatter {
  final double maxValue;

  MaxValueInputFormatter(this.maxValue);

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final double? parsedValue = double.tryParse(newValue.text);
    if (parsedValue == null) {
      return oldValue; // Kembalikan nilai lama jika input tidak valid
    }

    if (parsedValue > maxValue) {
      return oldValue; // Kembalikan nilai lama jika melebihi batas
    }

    return newValue; // Izinkan input jika valid
  }
}

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
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
      _weightController.addListener(_debouncedUpdatePrediction);
      _clothesController.addListener(_debouncedUpdatePrediction);
      _laundrySpeedController.addListener(_debouncedUpdatePrediction);
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

  void _debouncedUpdatePrediction() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _updatePrediction();
    });
  }

  void _updatePrediction() {
    final weightText = _weightController.text;
    final clothesText = _clothesController.text;
    final laundrySpeed = _laundrySpeedController.text;

    // Tambahkan validasi untuk mencegah prediksi saat controller kosong
    if (weightText.isEmpty || clothesText.isEmpty || laundrySpeed.isEmpty) {
      return;
    }

    final weight = double.tryParse(weightText) ?? 0.0;
    final clothes = int.tryParse(clothesText) ?? 0;
    if (weight > 0 && clothes > 0) {
      ref.read(orderNotifierProvider.notifier).predictCompletionTime(
            weight: weight,
            clothes: clothes,
            laundrySpeed: laundrySpeed,
          );
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _weightController.removeListener(_debouncedUpdatePrediction);
    _clothesController.removeListener(_debouncedUpdatePrediction);
    _laundrySpeedController.removeListener(_debouncedUpdatePrediction);
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
                padding: const EdgeInsets.all(PaddingSizes.cardPadding),
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

  Future<Map<String, DateTime?>> _getRealTimePredictions(
      double weight, int clothes) async {
    final predictUseCase = ref.read(predictCompletionTimeUseCaseProvider);

    final expressOrder = OrderModel(
      id: '',
      laundryUniqueName: '',
      customerUniqueName: '',
      weight: weight,
      clothes: clothes,
      laundrySpeed: 'Express',
      vouchers: [],
      totalPrice: 0.0,
      status: 'pending',
      createdAt: DateTime.now(),
      estimatedCompletion: DateTime.now(),
    );

    final regulerOrder = expressOrder.copyWith(laundrySpeed: 'Reguler');

    final expressResult = await predictUseCase(expressOrder);
    final regulerResult = await predictUseCase(regulerOrder);

    return {
      'Express': expressResult.fold((l) => null, (r) => r),
      'Reguler': regulerResult.fold((l) => null, (r) => r),
    };
  }

  void _showLaundrySpeedModal() {
    final weightText = _weightController.text;
    final clothesText = _clothesController.text;

    if (weightText.isEmpty || clothesText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Enter the weight and number of clothes first')),
      );
      return;
    }

    final weight = double.tryParse(weightText) ?? 0.0;
    final clothes = int.tryParse(clothesText) ?? 0;

    if (weight <= 0 || clothes <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Weight and quantity of clothes must be more than 0')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (context) => FutureBuilder<Map<String, DateTime?>>(
        future: _getRealTimePredictions(weight, clothes),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              padding: const EdgeInsets.all(PaddingSizes.formOuterPadding),
              child: const Center(child: LoadingIndicator()),
            );
          }

          if (snapshot.hasError) {
            return Container(
              padding: const EdgeInsets.all(PaddingSizes.formOuterPadding),
              child: const Text('Failed to load estimated time'),
            );
          }

          final predictions = snapshot.data ?? {};
          final expressTime = predictions['Express'];
          final regulerTime = predictions['Reguler'];

          return Container(
            padding: const EdgeInsets.all(PaddingSizes.formOuterPadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.chevron_left,
                          size: IconSizes.navigationIcon),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text('Select Laundry Speed',
                        style: AppTypography.modalTitle),
                    const SizedBox(width: 48),
                  ],
                ),
                ListTile(
                  title: const Text('Express (High Priority)'),
                  subtitle: Text(expressTime != null
                      ? 'AI Estimate: ${expressTime.difference(DateTime.now()).inHours} Hours'
                      : 'AI Cannot predict'),
                  onTap: () {
                    if (mounted) {
                      setState(() {
                        _laundrySpeedController.text = 'Express';
                      });
                      _updatePrediction();
                      Navigator.pop(context);
                    }
                  },
                ),
                ListTile(
                  title: const Text('Regular (Standard)'),
                  subtitle: Text(regulerTime != null
                      ? 'AI Estimate: ${regulerTime.difference(DateTime.now()).inHours} Hours'
                      : 'AI Cannot predict'),
                  onTap: () {
                    if (mounted) {
                      setState(() {
                        _laundrySpeedController.text = 'Reguler';
                      });
                      _updatePrediction();
                      Navigator.pop(context);
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Fungsi untuk mengonversi durasi ke format "X Days Y Hours"
  String _formatDuration(Duration duration) {
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    if (days > 0) {
      return '$days Days $hours Hours';
    }
    return '$hours Hours';
  }

  @override
  Widget build(BuildContext context) {
    final orderState = ref.watch(orderNotifierProvider);
    final userState = ref.watch(userProvider);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: BackgroundColors.transparent,
        shadowColor: BackgroundColors.transparent,
        surfaceTintColor: BackgroundColors.transparent,
        title: Text('Create Order', style: AppTypography.darkAppBarTitle),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: IconSizes.navigationIcon),
          onPressed: () {
            _weightController.removeListener(_debouncedUpdatePrediction);
            _clothesController.removeListener(_debouncedUpdatePrediction);
            _laundrySpeedController.removeListener(_debouncedUpdatePrediction);

            _uniqueNameController.clear();
            _weightController.clear();
            _clothesController.clear();
            _laundrySpeedController.clear();
            _vouchersController.clear();

            ref.read(orderNotifierProvider.notifier).resetPrediction();
            ref.read(orderNotifierProvider);
            context.go('/admin-dashboard-screen');
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: PaddingSizes.sectionTitlePadding),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: MarginSizes.medium),
                Text('Let\'s make your order',
                    style: AppTypography.sectionTitle),
                const SizedBox(height: MarginSizes.sectionSpacing),
                Text('Enter customer details to place customer order',
                    style: AppTypography.formInstruction),
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
                            if (mounted) _showCustomerSelectionModal(customers);
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
                          inputFormatters: [
                            FilteringTextInputFormatter
                                .digitsOnly, // Hanya izinkan angka
                            MaxValueInputFormatter(100), // Batasi maksimum 100
                          ],
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Clothing weight cannot be empty';
                            }
                            final weight = double.tryParse(value);
                            if (weight == null || weight <= 0) {
                              return 'Weight must be greater than 0';
                            }
                            if (weight > 100) {
                              return 'Weight cannot exceed 100 kg';
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
                          onTap: _showLaundrySpeedModal,
                          validator: (value) => value!.isEmpty
                              ? 'Laundry speed must be selected'
                              : null,
                        ),
                        const SizedBox(height: MarginSizes.formFieldSpacing),
                        CustomTextFormField(
                          hintText: 'Select Voucher',
                          labelText: 'Voucher',
                          controller: _vouchersController,
                        ),
                        const SizedBox(height: PaddingSizes.formSpacing),
                        if (orderState.isLoadingPrediction)
                          const Padding(
                            padding: EdgeInsets.only(
                                bottom: PaddingSizes.formSpacing),
                            child: SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        else if (orderState.predictedCompletion != null)
                          Padding(
                            padding: const EdgeInsets.only(
                                bottom: PaddingSizes.formSpacing),
                            child: Text(
                              'Estimated completion: ${_formatDuration(orderState.predictedCompletion!.difference(DateTime.now()))}',
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.black),
                            ),
                          )
                        else
                          const Padding(
                            padding: EdgeInsets.only(
                                bottom: PaddingSizes.formSpacing),
                            child: Text(
                              'Estimated completion: Not available',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          ),
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
                                  // Hapus listener sebelum clear
                                  _weightController.removeListener(
                                      _debouncedUpdatePrediction);
                                  _clothesController.removeListener(
                                      _debouncedUpdatePrediction);
                                  _laundrySpeedController.removeListener(
                                      _debouncedUpdatePrediction);

                                  _uniqueNameController.clear();
                                  _weightController.clear();
                                  _clothesController.clear();
                                  _laundrySpeedController.clear();
                                  _vouchersController.clear();

                                  ref
                                      .read(orderNotifierProvider.notifier)
                                      .resetPrediction();
                                  ref.read(orderNotifierProvider);

                                  scaffoldMessenger.showSnackBar(SnackBar(
                                    content: const Text(
                                        'Order successfully created'),
                                    backgroundColor: BackgroundColors.success,
                                  ));
                                  await Future.delayed(
                                      const Duration(milliseconds: 100));
                                  router.go('/manage-orders-screen');
                                }
                              } catch (e) {
                                if (mounted) {
                                  scaffoldMessenger.showSnackBar(SnackBar(
                                    content: Text('Failed to create order: $e'),
                                    backgroundColor: BackgroundColors.error,
                                  ));
                                }
                              }
                            }
                          },
                        ),
                        if (orderState.isLoading)
                          Padding(
                            padding: EdgeInsets.only(
                                top: PaddingSizes.sectionTitlePadding),
                            child: const LoadingIndicator(),
                          ),
                        if (orderState.errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(
                                top: PaddingSizes.sectionTitlePadding),
                            child: Text(orderState.errorMessage!,
                                style: AppTypography.errorText),
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
