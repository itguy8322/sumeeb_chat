import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sumeeb_chat/cubits/storage/storage_cubit.dart';
import 'package:sumeeb_chat/pages/contacts_page.dart';
import 'package:sumeeb_chat/services/stream_service.dart';
import '../cubits/auth_cubit.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final _form = GlobalKey<FormState>();
  final _nameC = TextEditingController();
  final _phoneC = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 6,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _form,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    MultiBlocListener(
                      listeners: [
                        BlocListener<AuthCubit, AuthState>(
                          listener: (context, state) {
                            ////print(state);
                            if (state is AuthInitial ||
                                state is AuthUnauthenticated) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LoginPage(),
                                ),
                              );
                            } else if (state is AuthAuthenticated) {
                              final streamService = StreamService();
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ContactsPage(
                                    currentUser: state.user,
                                    streamService: streamService,
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                      child: SizedBox(),
                    ),
                    const Icon(
                      Icons.chat_bubble,
                      size: 72,
                      color: Colors.green,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Welcome',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 18),
                    TextFormField(
                      controller: _nameC,
                      decoration: const InputDecoration(
                        labelText: 'Full name',
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Enter name' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _phoneC,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone (+countrycode)',
                        prefixIcon: Icon(Icons.phone),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Enter phone';
                        if (!RegExp(r'^\+?[0-9]{7,15}$').hasMatch(v)) {
                          return 'Invalid phone';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: BlocBuilder<AuthCubit, AuthState>(
                        builder: (context, auth) {
                          return ElevatedButton(
                            onPressed: auth is AuthLoading
                                ? null
                                : () async {
                                    if (!_form.currentState!.validate()) return;
                                    context.read<StorageCubit>().setUserData(
                                      _nameC.text.trim(),
                                      _phoneC.text.trim(),
                                    );
                                    await context.read<AuthCubit>().login(
                                      name: _nameC.text.trim(),
                                      phone: _phoneC.text.trim(),
                                    );
                                  },
                            child: auth is AuthLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text('Continue'),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => context.read<AuthCubit>().logout(),
                      child: const Text('Reset'),
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
}
