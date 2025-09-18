// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:sumeeb_chat/cubits/auth_cubit.dart';
import 'package:sumeeb_chat/cubits/storage/storage_cubit.dart';
import 'package:sumeeb_chat/pages/contacts_page.dart';
import 'package:sumeeb_chat/pages/login_page.dart';
import 'package:sumeeb_chat/services/push_notification_service.dart';
import 'package:sumeeb_chat/services/stream_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

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
      PushNotificationService.initialize();
      final sCubit = BlocProvider.of<StorageCubit>(context);
      sCubit.getUserData();

      // NotificationSettings settings = await messaging.requestPermission(
      //   alert: true,
      //   badge: true,
      //   sound: true,
      // );
    });
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
              BlocListener<StorageCubit, Map<String, dynamic>>(
                listener: (context, state) {
                  ////print(state);
                  if (state["phoneNumber"] != null && state["name"] != null) {
                    print(state["phoneNumber"]);
                    context.read<AuthCubit>().login(
                      phone: state["phoneNumber"],
                      name: state["name"],
                    );
                  } else {
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
            child: Center(
              child: Column(
                children: [
                  CircularProgressIndicator(strokeWidth: 10.0),
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
