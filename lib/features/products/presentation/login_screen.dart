import 'package:ecommerce_app_task/core/utils/app_string.dart';
import 'package:ecommerce_app_task/core/utils/size_config.dart';
import 'package:ecommerce_app_task/features/products/presentation/dashboard_screen.dart';
import 'package:ecommerce_app_task/features/products/provider/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  // Dummy credentials for verification
  static const String _correctUser = 'admin';
  static const String _correctPass = '123456';

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {

    final sc = SizeConfig.of(context);

    return GestureDetector(
      onTap: (){
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // App Logo / Icon
                    getLogoWelcomeTextAndSubText(sc),

                    // Username Field with Validation
                    getUserNameField(sc),

                    // Password Field with Validation & Eye Toggle
                    getPasswordField(sc),

                    // Login Button with Loading State
                    getLoginBtn(sc),
                    // Demo Credentials Hint

                    Padding(
                      padding:  EdgeInsets.only(top: 10),
                      child: const Text(
                        'Demo: admin / 123456',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget getLogoWelcomeTextAndSubText(SizeConfig sc) {
    return Column(
      children: [
        Icon(
          Icons.shopping_bag_rounded,
          size: sc.shortest * 0.16,
          color: Colors.blue,
        ),
        Padding(
          padding: EdgeInsets.only(top: sc.gap * 0.8),
          child: const Text(
            'Welcome Back!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: sc.gap * 0.3),
          child: const Text(
            'Login to continue shopping',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ),
      ],
    );
  }

  Widget getUserNameField(SizeConfig sc) {
    return Padding(
      padding: EdgeInsets.only(top: sc.gap * 1.5),
      child: TextFormField(
        controller: _usernameController,
        decoration: const InputDecoration(
          labelText: 'Username',
          prefixIcon: Icon(Icons.person_outline),
          border: OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return AppStrings.usernameRequired;
          }
          if (value.trim().length < 3) {
            return AppStrings.usernameTooShort;
          }
          return null;
        },
      ),
    );
  }

  Widget getPasswordField(SizeConfig sc) {
    return Padding(
      padding: EdgeInsets.only(top: sc.gap),
      child: TextFormField(
        controller: _passwordController,
        obscureText: _obscurePassword,
        decoration: InputDecoration(
          labelText: 'Password',
          prefixIcon: const Icon(Icons.lock_outline),
          border: const OutlineInputBorder(),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return AppStrings.passwordRequired;
          }
          if (value.length < 6) {
            return AppStrings.passwordTooShort;
          }
          return null;
        },
      ),
    );
  }

  Widget getLoginBtn(SizeConfig sc) {
    return Padding(
      padding: EdgeInsets.only(top: sc.gap * 1.2),
      child: SizedBox(
        height: sc.buttonHeight,
        child: FilledButton(
          onPressed: _isLoading ? null : _handleLogin,
          child: _isLoading
              ? const SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2.5,
            ),
          )
              : const Text(
            'Login',
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }

  void _handleLogin() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    Future.delayed(const Duration(seconds: 1), () async {
      if (!mounted) return;
      setState(() => _isLoading = false);

      final messenger = ScaffoldMessenger.of(context);
      final profile = context.read<ProfileProvider>();

      if (_usernameController.text.trim() == _correctUser &&
          _passwordController.text == _correctPass) {
        messenger.showSnackBar(
          const SnackBar(content: Text(AppStrings.loginSuccess)),
        );

        // Save hote hi main.dart ka Consumer Dashboard khol dega,
        // isliye yahan Navigator ki zaroorat nahi
        await profile.login(
          _usernameController.text.trim(),
          image: AppStrings.demoUserCredential, // profile photo
        );
      } else {
        messenger.showSnackBar(
          const SnackBar(content: Text(AppStrings.loginFailed)),
        );
      }
    });
  }


}