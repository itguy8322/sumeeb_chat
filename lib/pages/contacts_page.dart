import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:sumeeb_chat/cubits/chat-connection/chat_connection_cubit.dart';
import '../cubits/auth_cubit.dart';
import '../cubits/contacts_cubit.dart';
import '../models/user_model.dart';
import '../widgets/contact_tile.dart';
import 'chat_page.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import '../services/stream_service.dart';

class ContactsPage extends StatefulWidget {
  final AppUser currentUser;
  final StreamService streamService;
  const ContactsPage({
    super.key,
    required this.currentUser,
    required this.streamService,
  });
  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  // List<String> _phones = [];

  @override
  void initState() {
    super.initState();
    _ensureStreamConnected();
    _fetchPhoneContacts();
  }

  Future<void> _ensureStreamConnected() async {
    print("=============== CONNECTING USER: ${widget.currentUser.id}");
    try {
      await widget.streamService.connectUser(
        formatUserId(widget.currentUser.id),
        widget.currentUser.name,
      );
    } catch (e) {
      // handle
      print('Stream connect error: $e');
    }
  }

  Future<void> _fetchPhoneContacts() async {
    print("============LOADINF");
    var status = await Permission.contacts.status;
    if (!status.isGranted) {
      print("============LOADINF---");
      status = await Permission.contacts.request();
    }

    if (status.isGranted) {
      final contacts = await FlutterContacts.getContacts(withProperties: true);
      final phones = <String>{};
      for (final c in contacts) {
        for (final p in c.phones) {
          final normalized = _normalizePhone(p.number);
          if (normalized.isNotEmpty) phones.add(normalized);
        }
      }
      // setState(() => _phones = phones.toList());
      // Query firestore for registered users using phones
      print("============${phones.toList()}");
      context.read<ContactsCubit>().loadRegisteredContacts(phones.toList());
    }
    // if (!await FlutterContacts.requestPermission()) {
    //   print("============LOADINF---");
    //   return;
    // }
  }

  String _normalizePhone(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^0-9+]'), '');
    // Very naive normalization: ensure starts with + or digits
    return digits;
  }

  String formatUserId(String phoneNumber) {
    // remove '+' and any non-allowed characters
    return phoneNumber.replaceAll(RegExp(r'[^a-z0-9@_-]'), '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chats (${widget.currentUser.name})'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _fetchPhoneContacts(),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthCubit>().logout(),
          ),
        ],
      ),
      body: BlocBuilder<ContactsCubit, ContactsState>(
        builder: (context, state) {
          if (state is ContactsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ContactsEmpty) {
            return const Center(child: Text('No contacts on app'));
          } else if (state is ContactsLoaded) {
            final users = state.contacts;
            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (ctx, i) => ContactTile(
                user: users[i],
                onTap: (u) async {
                  print("=============== CONNECTING OTHER USER: ${u.id}");
                  context.read<ChatConnectionCubit>().makeConnection(
                    widget.currentUser,
                    u,
                    widget.streamService,
                  );
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ChatPage(
                        currentUser: widget.currentUser,
                        other: u,
                        streamService: widget.streamService,
                      ),
                    ),
                  );
                },
              ),
            );
          }
          return const Center(child: Text('Loading...'));
        },
      ),
    );
  }
}
