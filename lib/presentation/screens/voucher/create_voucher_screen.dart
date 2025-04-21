import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../style/colors/background_colors.dart';
import '../../style/sizes/padding_sizes.dart';
import '../../style/app_typography.dart';
import '../../widgets/common/custom_text_form_field.dart';
import '../../../domain/entities/voucher.dart';
import '../../providers/voucher_provider.dart';

class IconSizes {
  static const double navigationIcon = 24;
}

class MarginSizes {
  static const double modalTop = 16.0;
  static const double moderate = 16.0;
}

class CreateVoucherScreen extends ConsumerStatefulWidget {
  const CreateVoucherScreen({super.key});

  @override
  ConsumerState<CreateVoucherScreen> createState() =>
      _CreateVoucherScreenState();
}

class _CreateVoucherScreenState extends ConsumerState<CreateVoucherScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _typeController = TextEditingController();
  final _obtainMethodController = TextEditingController();
  final _validityPeriodController = TextEditingController();
  DateTime? _validityPeriod;

  final List<String> _voucherTypes = [
    'Free Laundry 1 Kg',
    'Discount 2%',
    'Discount 5%',
    'Discount 10%',
    'Discount 15%',
    'Get Rp. 5.000',
    'Get Rp. 20.000',
    'Discount Rp. 1.000',
    'Discount Rp. 2.000',
    'Discount Rp. 3.000',
    'Discount Rp. 4.000',
    'Discount Rp. 5.000',
    'Discount Rp. 6.000',
    'Discount Rp. 7.000',
    'Discount Rp. 8.000',
    'Discount Rp. 9.000',
    'Discount Rp. 10.000',
    'Discount Rp. 11.000',
    'Discount Rp. 12.000',
  ];
  final List<String> _obtainMethods = [
    'Laundry 5 Kg',
    'Laundry 10 Kg',
    'First Laundry',
    'Laundry on Birthdate',
    'Weekday Laundry',
    'New Service',
    'Twin Date',
    'Special Date'
  ];

  @override
  void initState() {
    super.initState();
    _validityPeriodController.text = 'No Expiry';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _typeController.dispose();
    _obtainMethodController.dispose();
    _validityPeriodController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF6B7280),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogTheme: DialogThemeData(backgroundColor: Colors.white),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _validityPeriod) {
      setState(() {
        _validityPeriod = picked;
        _validityPeriodController.text =
            DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _clearValidityPeriod() {
    setState(() {
      _validityPeriod = null;
      _validityPeriodController.text = 'No Expiry';
    });
  }

  void _createVoucher() {
    if (_formKey.currentState!.validate()) {
      final voucher = Voucher(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        amount: double.parse(_amountController.text),
        type: _typeController.text,
        obtainMethod: _obtainMethodController.text,
        validityPeriod: _validityPeriod,
      );
      ref.read(voucherProvider.notifier).createVoucher(voucher);
    }
  }

  void _showOptionsModal({
    required BuildContext context,
    required List<String> options,
    required TextEditingController controller,
    required String title,
  }) {
    TextEditingController searchController = TextEditingController();
    List<String> filteredOptions = List.from(options);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) {
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
                        Expanded(
                          child: Center(
                            child: Text(
                              'Select $title',
                              style: AppTypography.modalTitle,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        const SizedBox(width: IconSizes.navigationIcon),
                      ],
                    ),
                    const SizedBox(height: MarginSizes.modalTop),
                    CustomTextFormField(
                      controller: searchController,
                      hintText: "Search $title...",
                      prefixIcon: Icons.search,
                      onChanged: (value) {
                        modalSetState(() {
                          filteredOptions = options
                              .where((option) => option
                                  .toLowerCase()
                                  .contains(value.toLowerCase()))
                              .toList();
                        });
                      },
                    ),
                    const SizedBox(height: MarginSizes.moderate),
                    Flexible(
                      child: filteredOptions.isEmpty
                          ? const Center(child: Text('No options found'))
                          : ListView.builder(
                              shrinkWrap: true,
                              itemCount: filteredOptions.length,
                              itemBuilder: (context, index) {
                                final option = filteredOptions[index];
                                return ListTile(
                                  title: Text(
                                    option,
                                    style: AppTypography.formInstruction
                                        .copyWith(color: Colors.black),
                                  ),
                                  onTap: () {
                                    if (mounted) {
                                      setState(() {
                                        controller.text = option;
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
    ).whenComplete(() {
      searchController.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<List<Voucher>>>(voucherProvider, (previous, next) {
      next.when(
        data: (vouchers) {
          if (vouchers.isNotEmpty &&
              (previous?.value?.length ?? 0) < vouchers.length) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Voucher created successfully!')),
            );
            // Navigate to voucher list screen to show the newly created voucher
            context.pushReplacement('/admin-dashboard-screen');
          }
        },
        loading: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Creating voucher...')),
          );
        },
        error: (error, stack) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $error')),
          );
        },
      );
    });

    return Scaffold(
      backgroundColor: BackgroundColors.lightGrey,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            if (mounted) {
              context.pushReplacement('/admin-dashboard-screen');
            }
          },
        ),
        title: Text(
          'Create Voucher',
          style: AppTypography.appBarTitle.copyWith(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: PaddingSizes.sectionTitlePadding,
          vertical: PaddingSizes.contentContainerPadding,
        ),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                'Create Your Voucher',
                style: AppTypography.sectionTitle.copyWith(color: Colors.black),
              ),
              SizedBox(height: PaddingSizes.contentContainerPadding),
              Text(
                'Enter voucher details to create a new voucher',
                style: AppTypography.formInstruction,
              ),
              SizedBox(height: PaddingSizes.screenEdgePadding),
              CustomTextFormField(
                hintText: 'Voucher Name',
                labelText: 'Voucher Name',
                controller: _nameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter voucher name';
                  }
                  return null;
                },
              ),
              SizedBox(height: PaddingSizes.sectionTitlePadding),
              CustomTextFormField(
                hintText: 'Voucher Amount',
                labelText: 'Voucher Amount',
                controller: _amountController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter voucher amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              SizedBox(height: PaddingSizes.sectionTitlePadding),
              CustomTextFormField(
                hintText: 'Voucher Type',
                labelText: 'Voucher Type',
                controller: _typeController,
                readOnly: true,
                onTap: () => _showOptionsModal(
                  context: context,
                  options: _voucherTypes,
                  controller: _typeController,
                  title: 'Voucher Type',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select voucher type';
                  }
                  return null;
                },
                suffixIcon: const Icon(
                  Icons.arrow_drop_down,
                  color: Colors.grey,
                  size: 20,
                ),
              ),
              SizedBox(height: PaddingSizes.sectionTitlePadding),
              CustomTextFormField(
                hintText: 'How to Obtain the Voucher',
                labelText: 'How to Obtain the Voucher',
                controller: _obtainMethodController,
                readOnly: true,
                onTap: () => _showOptionsModal(
                  context: context,
                  options: _obtainMethods,
                  controller: _obtainMethodController,
                  title: 'How to Obtain the Voucher',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select how to obtain the voucher';
                  }
                  return null;
                },
                suffixIcon: const Icon(
                  Icons.arrow_drop_down,
                  color: Colors.grey,
                  size: 20,
                ),
              ),
              SizedBox(height: PaddingSizes.sectionTitlePadding),
              Row(
                children: [
                  Expanded(
                    child: CustomTextFormField(
                      hintText: 'Validity Period',
                      labelText: 'Validity Period',
                      controller: _validityPeriodController,
                      readOnly: true,
                      onTap: () => _selectDate(context),
                      suffixIcon: const Icon(
                        Icons.calendar_today,
                        color: Colors.grey,
                        size: 20,
                      ),
                    ),
                  ),
                  if (_validityPeriod != null) ...[
                    SizedBox(width: PaddingSizes.sectionTitlePadding),
                    IconButton(
                      icon: const Icon(
                        Icons.clear,
                        color: Colors.grey,
                        size: 20,
                      ),
                      onPressed: _clearValidityPeriod,
                    ),
                  ],
                ],
              ),
              SizedBox(height: PaddingSizes.screenEdgePadding),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (mounted) {
                        context.pushReplacement('/admin-dashboard-screen');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                  SizedBox(width: PaddingSizes.sectionTitlePadding),
                  ElevatedButton(
                    onPressed: _createVoucher,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF95BBE3),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: const Text('Create'),
                  ),
                ],
              ),
              SizedBox(height: PaddingSizes.sectionTitlePadding),
            ],
          ),
        ),
      ),
    );
  }
}
