import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sumeeb_chat/data/cubits/storage/storage_cubit.dart';
import 'package:sumeeb_chat/data/cubits/user-cubit/user_cubit.dart';
import 'package:sumeeb_chat/pages/login/other_info_step.dart';
import '../../data/cubits/auth_cubit.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final _formKey = GlobalKey<FormState>();
  // final _nameC = TextEditingController();
  final _phoneC = TextEditingController();

  // void _onLogin() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: MultiBlocListener(
        listeners: [
          BlocListener<AuthCubit, AuthState>(
            listener: (context, state) {
              ////print(state);
              if (state is AuthInitial || state is AuthUnauthenticated) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              } else if (state is AuthAuthenticated) {
                context.read<StorageCubit>().setNumber(_phoneC.text.trim());
                context.read<UserCubit>().setUuser(state.user);
                print(state.user.profilePhoto);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => OtherInfoStep()),
                );
              }
            },
          ),
        ],
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // const Icon(
                      //   Icons.chat_bubble_outline,
                      //   size: 80,
                      //   // color: Colors.blueAccent,
                      // ),
                      Image.asset('assets/images/logo.png', height: 120),
                      const SizedBox(height: 16),
                      Text(
                        "Welcome Back 👋",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineLarge
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              // color: Colors.blueAccent,
                            ),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _phoneC,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: "Phone Number",
                          prefixIcon: const Icon(Icons.phone),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Enter your phone number";
                          } else if (!RegExp(
                            r'^\+?[0-9]{10,13}$',
                          ).hasMatch(value)) {
                            return "Enter valid phone (e.g. +2348012345678)";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Login button
                      SizedBox(
                        width: double.infinity,
                        child: BlocBuilder<AuthCubit, AuthState>(
                          builder: (context, auth) {
                            return ElevatedButton(
                              onPressed: auth is AuthLoading
                                  ? null
                                  : () async {
                                      if (!_formKey.currentState!.validate()) {
                                        return;
                                      }

                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Is this the correct number?",
                                              ),
                                              SizedBox(height: 10),
                                              Text(
                                                _phoneC.text,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18,
                                                ),
                                              ),
                                            ],
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: Text(
                                                "Edit",
                                                style: TextStyle(
                                                  color: Colors.amber,
                                                ),
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () async {
                                                Navigator.pop(context);
                                                String phoneNumber = '';
                                                if (_phoneC.text[0] == '0') {
                                                  phoneNumber = _phoneC.text
                                                      .replaceFirst(
                                                        '0',
                                                        '+234',
                                                      );
                                                  _phoneC.text = phoneNumber;
                                                } else {
                                                  phoneNumber = _phoneC.text;
                                                }
                                                print(phoneNumber);
                                                await context
                                                    .read<AuthCubit>()
                                                    .login(
                                                      phone: phoneNumber.trim(),
                                                    );
                                              },
                                              child: Text(
                                                "Yes",
                                                style: TextStyle(
                                                  color: Colors.amber,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: auth is AuthLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : Text(
                                      "Connect",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.surface,
                                      ),
                                    ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => context.read<AuthCubit>().logout(),
                        child: const Text(
                          'Reset',
                          style: TextStyle(color: Colors.amber),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
