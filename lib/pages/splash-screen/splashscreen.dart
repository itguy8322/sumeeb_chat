// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sumeeb_chat/data/cubits/auth_cubit.dart';
import 'package:sumeeb_chat/data/cubits/chat-connection/chat_connection_cubit.dart';
import 'package:sumeeb_chat/data/cubits/storage/storage_cubit.dart';
import 'package:sumeeb_chat/data/cubits/storage/storage_state.dart';
import 'package:sumeeb_chat/data/cubits/user-cubit/user_cubit.dart';
import 'package:sumeeb_chat/data/models/user/user_model.dart';
import 'package:sumeeb_chat/pages/home/home_page.dart';
import 'package:sumeeb_chat/pages/login/login_page.dart';
import 'package:sumeeb_chat/pages/login/other_info_step.dart';
import 'package:sumeeb_chat/services/push_notification_service.dart';
import 'package:sumeeb_chat/services/stream_service.dart';

class SplashScreen extends StatefulWidget {
  final StreamService streamService;
  const SplashScreen({super.key, required this.streamService});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  void requestPermissions() async {
    try {
      await Permission.storage.request();
    } catch (e) {
      ////print(e.toString());
    }
  }

  void status(var title, var status) {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(title: Text(title), content: Text(status)),
    );
  }

  @override
  void initState() {
    super.initState();
    requestPermissions();
    // FirebaseMessaging messaging = FirebaseMessaging.instance;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final sCubit = BlocProvider.of<StorageCubit>(context);
      sCubit.getUserData();

      // NotificationSettings settings = await messaging.requestPermission(
      //   alert: true,
      //   badge: true,
      //   sound: true,
      // );
    });
  }

  Future<void> _ensureStreamConnected(AppUser user) async {
    print("=============== SPLASH SCREEN @ @ CONNECTING USER: ${user.id}");
    try {
      await widget.streamService.connectUser(formatUserId(user.id), user.name);
    } catch (e) {
      // handle
      print('Stream connect error: $e');
    }
  }

  String formatUserId(String phoneNumber) {
    // remove '+' and any non-allowed characters
    return phoneNumber.replaceAll(RegExp(r'[^a-z0-9@_-]'), '');
  }

  @override
  Widget build(BuildContext context) {
    // final loginCubit = BlocProvider.of<AuthCubit>(context);
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          MultiBlocListener(
            listeners: [
              BlocListener<StorageCubit, StorageState>(
                listener: (context, state) {
                  ////print(state);
                  final appSettings = state.appSettings;
                  if (appSettings != null) {
                    if (appSettings.phone != null) {
                      context.read<AuthCubit>().login(
                        phone: appSettings.phone!,
                      );

                      print(appSettings.phone);
                    } else {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    }
                  } else {
                    print("NULLLLLLLLL");
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  }
                },
              ),
              BlocListener<AuthCubit, AuthState>(
                listener: (context, state) {
                  ////print(state);
                  if (state is AuthInitial || state is AuthUnauthenticated) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  } else if (state is AuthAuthenticated) {
                    _ensureStreamConnected(state.user);
                    context.read<UserCubit>().setUuser(state.user);
                    if (state.user.name.isNotEmpty) {
                      context.read<ChatConnectionCubit>().setStreamService(
                        widget.streamService,
                      );
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              HomePage(streamService: widget.streamService),
                        ),
                      );
                    } else {
                      print(state.user.profilePhoto);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OtherInfoStep(),
                        ),
                      );
                    }
                  }
                },
              ),
            ],
            child: Center(
              child: Column(
                children: [
                  CircularProgressIndicator(strokeWidth: 6.0),
                  SizedBox(height: 10),
                  Text("Initializing app...", style: TextStyle(fontSize: 20)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
