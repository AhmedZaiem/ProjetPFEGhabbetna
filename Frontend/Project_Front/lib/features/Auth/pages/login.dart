import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../../../config.dart' as config;
import 'package:authproject/features/Auth/services/auth_service.dart';
import 'package:authproject/l10n/app_localizations.dart';
import 'package:authproject/main.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  var emailController = TextEditingController();
  var passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  final AuthService authService = AuthService();

  void loginUser() async {
    final result = await authService.login(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );

    if (result['success']) {
      final accessToken = result['data']['access_token'];
      final decoded = JwtDecoder.decode(accessToken);
      int roleId = decoded['role_id'];

      if (roleId == 1) {
        context.go("/admin_dashboard");
      } else if (roleId == 2) {
        context.go("/supervisor");
      } else {
        context.go("/agent");
      }
    } else {
      _showDialog(AppLocalizations.of(context)!.error_title, result['message']);
    }
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text(AppLocalizations.of(context)!.ok),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 60),
        child: Center(
          child: Container(
            width: 350,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Image.asset('assets/images/logoApp.jpeg', height: 150),

                  Text(
                    AppLocalizations.of(context)!.auth_login,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 30),

                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.auth_email,
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(
                          context,
                        )!.error_email_required;
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  TextFormField(
                    controller: passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.auth_password,
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(
                          context,
                        )!.error_password_required;
                      }
                      if (value.length < 8) {
                        return AppLocalizations.of(
                          context,
                        )!.error_password_length;
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          loginUser();
                        }
                      },
                      icon: const Icon(Icons.login),
                      label: Text(AppLocalizations.of(context)!.auth_login),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1B5E20),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  TextButton(
                    onPressed: () {
                      context.push('/forgot_password');
                    },
                    child: Text(
                      AppLocalizations.of(context)!.auth_forgot_password,
                    ),
                  ),

                  SizedBox(height: 20),

                  IconButton(
                    icon: const Icon(Icons.language),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                title: const Text("العربية"),
                                onTap: () {
                                  (mainAppKey.currentState)?.setLocale(
                                    const Locale('ar', 'AR'),
                                  );
                                  Navigator.pop(context);
                                },
                              ),
                              ListTile(
                                title: const Text("Français"),
                                onTap: () {
                                  (mainAppKey.currentState)?.setLocale(
                                    const Locale('fr', 'FR'),
                                  );
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
