import 'package:flutter/material.dart';
import 'package:flutter_laundry_app/presentation/widgets/common/app_logo_widget.dart';
import 'package:flutter_laundry_app/presentation/widgets/common/custom_text.dart';
import 'package:flutter_laundry_app/presentation/widgets/common/custom_text_form_field.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/loading_indicator.dart';
import 'package:go_router/go_router.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  static const routeName = '/register';

  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _roleController =
      TextEditingController(text: "Customer");
  final _fullNameController = TextEditingController();
  final _uniqueNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    // Reset auth state when entering screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider.notifier).resetState();
    });
  }

  @override
  void dispose() {
    _roleController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneNumberController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  void _submitRegisterForm() async {
    if (_formKey.currentState!.validate()) {
      await ref.read(authProvider.notifier).register(
            role: _roleController.text.trim(),
            fullName: _fullNameController.text.trim(),
            uniqueName: _uniqueNameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
            phoneNumber: _phoneNumberController.text.trim(),
            address: _addressController.text.trim(),
          );

      final authState = ref.read(authProvider);

      if (authState.status == AuthStatus.success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registrasi berhasil!'),
            backgroundColor: Colors.green,
          ),
        );

        if (mounted) {
          // Cek role dan arahkan ke halaman yang sesuai
          if (_roleController.text.trim() == 'Customer') {
            context.go('/user-dashboard');
          } else if (_roleController.text.trim() == 'Worker') {
            context.go('/admin-dashboard');
          }
        }
      } else if (authState.status == AuthStatus.error &&
          authState.failure != null &&
          mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authState.failure!.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showRoleSelection() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Customer'),
              onTap: () {
                setState(() {
                  _roleController.text = 'Customer';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.work),
              title: Text('Worker'),
              onTap: () {
                setState(() {
                  _roleController.text = 'Worker';
                });
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _showAddressForm() {
    TextEditingController streetController = TextEditingController();
    TextEditingController houseNumberController = TextEditingController();
    TextEditingController districtController = TextEditingController();
    TextEditingController cityController = TextEditingController();
    TextEditingController provinceController = TextEditingController();
    TextEditingController postalCodeController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextFormField(
                  controller: streetController,
                  hintText: 'Masukkan Nama Jalan',
                  labelText: 'Nama Jalan',
                  prefixIcon: Icons.location_on,
                ),
                const SizedBox(height: 8),
                CustomTextFormField(
                  controller: houseNumberController,
                  hintText: 'Masukkan Nomor Rumah',
                  labelText: 'Nomor Rumah',
                  prefixIcon: Icons.home,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),
                CustomTextFormField(
                  controller: districtController,
                  hintText: 'Masukkan Kelurahan/Kecamatan',
                  labelText: 'Kelurahan/Kecamatan',
                  prefixIcon: Icons.location_city,
                ),
                const SizedBox(height: 8),
                CustomTextFormField(
                  controller: cityController,
                  hintText: 'Masukkan Kota/Kabupaten',
                  labelText: 'Kota/Kabupaten',
                  prefixIcon: Icons.apartment,
                ),
                const SizedBox(height: 8),
                CustomTextFormField(
                  controller: provinceController,
                  hintText: 'Masukkan Provinsi',
                  labelText: 'Provinsi',
                  prefixIcon: Icons.map,
                ),
                const SizedBox(height: 8),
                CustomTextFormField(
                  controller: postalCodeController,
                  hintText: 'Masukkan Kode Pos',
                  labelText: 'Kode Pos',
                  prefixIcon: Icons.local_post_office,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                CustomButton(
                  text: 'Selesai',
                  onPressed: () {
                    setState(() {
                      _addressController.text =
                          '${streetController.text}, No. ${houseNumberController.text}, '
                          '${districtController.text}, ${cityController.text}, '
                          '${provinceController.text}, ${postalCodeController.text}';
                    });
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 12),
            const AppLogoWidget(),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        CustomTextFormField(
                          controller: _roleController,
                          hintText: 'Pilih Peran',
                          labelText: 'Peran',
                          prefixIcon: Icons.manage_accounts,
                          suffixIcon: Icon(Icons.arrow_drop_down),
                          readOnly: true, // Agar tidak bisa diketik manual
                          onTap: _showRoleSelection,
                          validator: Validators.validateRole,
                        ),
                        const SizedBox(height: 12),
                        CustomTextFormField(
                          controller: _fullNameController,
                          hintText: _roleController.text == 'Worker'
                              ? 'Masukkan Nama Laundry'
                              : 'Masukkan Nama Lengkap',
                          labelText: _roleController.text == 'Worker'
                              ? 'Nama Laundry'
                              : 'Nama Lengkap',
                          prefixIcon: Icons.person,
                          textInputAction: TextInputAction.next,
                          validator: Validators.validateFullName,
                        ),
                        const SizedBox(height: 12),
                        CustomTextFormField(
                          controller: _uniqueNameController,
                          hintText: 'Masukkan Nama Unik',
                          labelText: 'Nama Unik',
                          prefixIcon: Icons.badge,
                          textInputAction: TextInputAction.next,
                          validator: Validators.validateUniqueName,
                        ),
                        const SizedBox(height: 12),
                        CustomTextFormField(
                          controller: _emailController,
                          hintText: 'Masukkan Email',
                          labelText: 'Email',
                          prefixIcon: Icons.email,
                          textInputAction: TextInputAction.next,
                          validator: Validators.validateEmail,
                        ),
                        const SizedBox(height: 12),
                        CustomTextFormField(
                          controller: _passwordController,
                          hintText: 'Masukkan Password',
                          labelText: 'Password',
                          prefixIcon: Icons.password,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: _togglePasswordVisibility,
                          ),
                          obscureText: !_isPasswordVisible,
                          textInputAction: TextInputAction.next,
                          validator: Validators.validatePassword,
                        ),
                        const SizedBox(height: 12),
                        CustomTextFormField(
                          controller: _phoneNumberController,
                          hintText: 'Masukkan Nomer WhatsApp',
                          labelText: 'Nomer WhatsApp',
                          prefixIcon: Icons.phone,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.done,
                          validator: Validators.validatePhoneNumber,
                        ),
                        const SizedBox(height: 12),
                        CustomTextFormField(
                          controller: _addressController,
                          hintText: _roleController.text == 'Worker'
                              ? 'Masukkan Alamat Laundry'
                              : 'Masukkan Alamat Rumah',
                          labelText: _roleController.text == 'Worker'
                              ? 'Alamat Laundry'
                              : 'Alamat Rumah',
                          prefixIcon: Icons.location_on,
                          readOnly: true, // Mencegah input manual
                          onTap: _showAddressForm,
                          validator: Validators.validateAddress,
                        ),
                        const SizedBox(height: 12),
                        authState.status == AuthStatus.loading
                            ? const LoadingIndicator()
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  CustomButton(
                                    width: 110,
                                    text: 'Daftar',
                                    onPressed: _submitRegisterForm,
                                  ),
                                ],
                              )
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            CustomText(
              normalText: 'Sudah Punya Akun? ',
              highlightedText: 'Masuk',
              onTap: () {
                context.push('/login');
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
