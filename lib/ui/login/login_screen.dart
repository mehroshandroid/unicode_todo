import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicode_todo/core/app_localizations.dart';

import '../../utils/display_utils.dart';
import '../dashboard/dashboard_screen.dart';
import 'login_provider.dart';

class LoginScreen extends ConsumerWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPasswordVisible = ref.watch(passwordVisibilityProvider);

    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: TextField(
                        decoration: InputDecoration(
                          icon: const Icon(Icons.email),
                          hintText: AppLocalizations.of(context)!
                              .translate('enter_email'),
                        ),
                        controller: emailController,
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    SizedBox(
                      width: double.infinity,
                      child: TextField(
                        decoration: InputDecoration(
                          icon: const Icon(Icons.lock),
                          hintText: AppLocalizations.of(context)!
                              .translate('enter_password'),
                          suffixIcon: IconButton(
                            icon: Icon(
                              isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              ref
                                  .read(passwordVisibilityProvider.notifier)
                                  .state = !isPasswordVisible;
                            },
                          ),
                        ),
                        obscureText: !isPasswordVisible,
                        controller: passwordController,
                      ),
                    ),
                    const SizedBox(height: 24.0),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Add login logic here
                          clearStackNavigate(context, const DashboardScreen());
                        },
                        child: Text(
                            AppLocalizations.of(context)!.translate('login')),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
