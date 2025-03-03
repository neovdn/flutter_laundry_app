import 'package:flutter/material.dart';
import 'package:flutter_laundry_app/presentation/widgets/common/app_logo_widget.dart';
import 'package:flutter_laundry_app/presentation/widgets/common/custom_text.dart';
import 'package:flutter_laundry_app/presentation/widgets/common/custom_text_form_field.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/loading_indicator.dart';

class LoginScreen extends ConsumerStatefulWidget {
  static const routeName = '/login';

  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider.notifier).resetState();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  void _submitLoginForm() async {
    if (_formKey.currentState!.validate()) {
      await ref.read(authProvider.notifier).login(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );

      final authState = ref.read(authProvider);

      if (authState.status == AuthStatus.success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login berhasil!'),
            backgroundColor: Colors.green,
          ),
        );

        if (mounted) {
          // Ambil role dari user
          final String? role = authState.user?.role;

          if (role == 'Customer') {
            context.go('/user-dashboard');
          } else if (role == 'Worker') {
            context.go('/admin-dashboard');
          } else {
            // Role tidak dikenali, fallback ke halaman login lagi
            context.go('/login');
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            const AppLogoWidget(),
            Spacer(),
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
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
                        authState.status == AuthStatus.loading
                            ? const LoadingIndicator()
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  CustomButton(
                                    width: 110,
                                    text: 'Masuk',
                                    onPressed: authState.status ==
                                            AuthStatus.loading
                                        ? () {} // Fungsi kosong saat loading
                                        : _submitLoginForm,
                                  ),
                                ],
                              ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Spacer(),
            CustomText(
              normalText: 'Belum Punya Akun? ',
              highlightedText: 'Daftar',
              onTap: () {
                context.push('/register');
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
