import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicode_todo/core/app_localizations.dart';
import 'package:unicode_todo/utils/nav_utils.dart';

import '../../data/generic_response_model.dart';
import '../../utils/display_utils.dart';
import '../dashboard/dashboard_screen.dart';
import 'login_provider.dart';

class LoginScreen extends ConsumerWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPasswordVisible = ref.watch(passwordVisibilityProvider);
    final isLoginLoading = ref.watch(toggleProgressLogin);
    final isSignUpLoading = ref.watch(toggleProgressSignup);

    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: TextField(
                        maxLength: 150,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          icon: const Icon(Icons.email),
                          hintText: AppLocalizations.of(context)!
                              .translate('enter_email'),
                        ),
                        controller: _emailController,
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
                        controller: _passController,
                      ),
                    ),
                    const SizedBox(height: 24.0),
                    if (isLoginLoading)
                      const CircularProgressIndicator()
                    else
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            // Add login logic here
                            _loginUser(context, ref, true);
                          },
                          child: Text(
                              AppLocalizations.of(context)!.translate('login')),
                        ),
                      ),
                    const SizedBox(height: 8.0),
                    const Text("or"),
                    const SizedBox(height: 8.0),
                    if (isSignUpLoading)
                      const CircularProgressIndicator()
                    else
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            // Add login logic here
                            //add logic for sign Up
                            _loginUser(context, ref, false);
                          },
                          child: Text(AppLocalizations.of(context)!
                              .translate('sign_up')),
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

  void _loginUser(BuildContext context, WidgetRef ref, bool isLogin) async {
    var viewModel = ref.read(loginViewModelProvider);
    Map validation =
        viewModel.validateFields(_emailController.text, _passController.text);
    if (validation['success'] as bool) {
      if (isLogin) {
        ref.read(toggleProgressLogin.notifier).state = true;
      } else {
        ref.read(toggleProgressSignup.notifier).state = true;
      }
      GenericResponse result;
      if (isLogin) {
        result = await viewModel.logInUser(
          _emailController.text,
          _passController.text,
        );
      } else {
        result = await viewModel.registerUser(_emailController.text,
            _passController.text, ref.read(firebaseAuth));
      }
      ref.read(toggleProgressLogin.notifier).state = false;
      ref.read(toggleProgressSignup.notifier).state = false;
      if (result.success) {
        //proceed to home screen
        if (context.mounted) {
          User? user = ref.read(firebaseAuth).currentUser;
          if (user == null) {
            viewModel.storeUserUid(user?.uid != null ? user!.uid : "");
          }
          clearStackNavigate(context, DashboardScreen());
        }
      } else {
        DisplayUtils.showErrorToast(result.errorMessage);
      }
    } else {
      if (kDebugMode) {
        print(validation['message']);
      }
      DisplayUtils.showErrorToast(validation['message']);
    }
  }
}
