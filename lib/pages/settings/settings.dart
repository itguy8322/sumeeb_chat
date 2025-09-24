// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sumeeb_chat/data/cubits/auth_cubit.dart';
import 'package:sumeeb_chat/data/cubits/sidebar-manager/sider_manager_cubit.dart';
import 'package:sumeeb_chat/data/cubits/storage/storage_cubit.dart';
import 'package:sumeeb_chat/data/cubits/user-cubit/user_cubit.dart';
import 'package:sumeeb_chat/data/cubits/user-cubit/user_state.dart';
import 'package:sumeeb_chat/pages/chatroom/view_profile_photo.dart';
import 'package:sumeeb_chat/pages/login/login_page.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// import '../../data/blocs/authentication/authentication_bloc.dart';
// import '../debug/bloc/debug_cubit.dart';
import 'dark-mode/dark_mode_section.dart';
import 'location-access/location_access_permission.dart';
import 'microphone-access/microphone_access_permission.dart';
import 'notifications/notifications_section.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // leading: (Icons.arrow_back,)
        leading: SizedBox(),
        leadingWidth: 0,
        title: Text('Settings'),
      ),
      // inverted: true,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            AccountSection(),
            DarkThemeSection(),
            SectionTitle('Permissions'),
            MicrophoneAccessPermission(),
            LocationAccessPermission(),
            HapticsPermission(),
            Divider(),
            NotificationPermissionAccess(),
            ClearData(),
            SizedBox(height: 130),
          ],
        ),
      ),
    );
  }
}

class ClearData extends StatelessWidget {
  const ClearData({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () {
              // context.read<DebugCubit>().deleteAllCollectionsAndIsarData();
            },
            child: Text(
              'Clear all app data',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}

class HapticsPermission extends StatelessWidget {
  const HapticsPermission({super.key});

  @override
  Widget build(BuildContext context) {
    return const ListTile(
      title: Text('Haptics'),
      trailing: Checkbox(onChanged: null, value: true),
    );
  }
}

class AccountSection extends StatelessWidget {
  const AccountSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserCubit, UserState>(
      builder: (context, state) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle('Account'),
            Builder(
              builder: (context) {
                // final state.user! = context.select(
                //   (AuthenticationBloc bloc) => bloc.state.state.user!,
                // );
                return ListTile(
                  leading: InkWell(
                    onTap: () {
                      if (Platform.isWindows) {
                        context
                            .read<SiderManagerCubit>()
                            .onViewProfilePhotoPage(state.user!, true);
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ViewProfilePhoto(user: state.user!, isMe: true),
                          ),
                        );
                      }
                    },
                    child: CircleAvatar(
                      child: state.user!.profilePhoto != null
                          ? state.user!.profilePhoto!.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(70),
                                    child: Image.network(
                                      state.user!.profilePhoto!,
                                    ),
                                  )
                                : Text(
                                    state.user!.name[0],
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.surface,
                                      fontSize: 22,
                                    ),
                                  )
                          : Text(
                              state.user!.name[0],
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.surface,
                                fontSize: 22,
                              ),
                            ),
                    ),
                  ),
                  title: Text(state.user!.name),
                  subtitle: Text(state.user!.phone ?? ''),
                  trailing: FilledButton.tonal(
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Sign out'),
                        Icon(Icons.exit_to_app_sharp),
                      ],
                    ),
                    onPressed: () async {
                      await context.read<StorageCubit>().clearStorage();
                      context.read<AuthCubit>().logout();
                      Navigator.of(context).popUntil((route) => route.isFirst);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    },
                  ),
                );
              },
            ),
            const Divider(),
          ],
        );
      },
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.secondary,
        ),
      ),
    );
  }
}
