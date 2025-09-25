// ignore_for_file: no_leading_underscores_for_local_identifiers, use_build_context_synchronously

import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sumeeb_chat/data/cubits/chat-connection/chat_connection_cubit.dart';
import 'package:sumeeb_chat/data/cubits/contacts-cubit/contacts_cubit.dart';
import 'package:sumeeb_chat/data/cubits/contacts-cubit/contacts_state.dart';
import 'package:sumeeb_chat/data/cubits/recent-chats-cubit/recent_chat_cubit.dart';
import 'package:sumeeb_chat/data/cubits/sidebar-manager/sider_manager_cubit.dart';
import 'package:sumeeb_chat/data/cubits/user-cubit/user_cubit.dart';
import 'package:sumeeb_chat/data/cubits/user-cubit/user_state.dart';
import '../../data/cubits/auth_cubit.dart';
import '../../data/models/user/user_model.dart';
import '../../widgets/contact_tile.dart';
import '../chatroom/chatroom_page.dart';
import '../../services/stream_service.dart';

class ContactsPage extends StatefulWidget {
  final StreamService streamService;
  const ContactsPage({super.key, required this.streamService});
  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  // List<String> _phones = [];
  final storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    // _ensureStreamConnected();
    // _fetchPhoneContacts();
  }

  // Future<void> _ensureStreamConnected() async {
  //   print("=============== CONNECTING USER: ${widget.currentUser.id}");
  //   try {
  //     await widget.streamService.connectUser(
  //       formatUserId(widget.currentUser.id),
  //       widget.currentUser.name,
  //     );
  //   } catch (e) {
  //     // handle
  //     print('Stream connect error: $e');
  //   }
  // }

  String _normalizePhone(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^0-9+]'), '');
    // Very naive normalization: ensure starts with + or digits
    return digits;
  }

  String formatUserId(String phoneNumber) {
    // remove '+' and any non-allowed characters
    return phoneNumber.replaceAll(RegExp(r'[^a-z0-9@_-]'), '');
  }

  showAddContactField() {
    final name = TextEditingController();
    final phone = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Add New Contact"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 10,
          children: [
            TextFormField(
              controller: name,
              decoration: InputDecoration(hintText: "Name (Optional)"),
            ),
            TextFormField(
              controller: phone,
              decoration: InputDecoration(hintText: "Phone (+234)"),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              if (phone.text.isNotEmpty) {
                context.read<ContactsCubit>().addContact(name.text, phone.text);
                Navigator.pop(context);
              }
            },
            child: Text("Add Contact"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("Cancel"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // foregroundColor: Colors.white,
        // backgroundColor: Colors.blueAccent,
        title: Text('Contacts'),
        actions: [
          Platform.isWindows
              ? IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => showAddContactField(),
                )
              : SizedBox(),
          BlocBuilder<ContactsCubit, ContactsState>(
            builder: (context, state) {
              if (state.loadingInProgress) {
                return SizedBox(
                  width: 25,
                  height: 25,
                  child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                );
              }
              return IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () =>
                    context.read<ContactsCubit>().fetchPhoneContacts(),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<ContactsCubit, ContactsState>(
        builder: (context, state) {
          // if (state is ContactsLoading) {
          //   return Center(
          //     child: CircularProgressIndicator(
          //       color: Theme.of(context).colorScheme.onSurface,
          //     ),
          //   );
          // } else
          if (state.contacts.isEmpty) {
            return const Center(child: Text('No contacts on app'));
          } else {
            final users = state.contacts;

            return BlocBuilder<UserCubit, UserState>(
              builder: (context, _user) {
                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (ctx, i) => ContactTile(
                    user: users[i],
                    onTap: (u) async {
                      print("=============== CONNECTING OTHER USER: ${u.id}");
                      context.read<RecentChatCubit>().resetMessageCount(u.id);
                      context.read<ChatConnectionCubit>().makeConnection(
                        _user.user!,
                        u,
                        widget.streamService,
                      );
                      if (Platform.isWindows) {
                        context.read<SiderManagerCubit>().onViewChatroomPage();
                      } else {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ChatroomPage(
                              streamService: widget.streamService,
                            ),
                          ),
                        );
                      }
                    },
                  ),
                );
              },
            );
          }
          // return const Center(child: Text('Loading...'));
        },
      ),
    );
  }
}
