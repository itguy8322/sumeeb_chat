import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sumeeb_chat/data/cubits/auth_cubit.dart';
import 'package:sumeeb_chat/data/cubits/chat-connection/chat_connection_cubit.dart';
import 'package:sumeeb_chat/data/cubits/recent-chats-cubit/recent_chat_cubit.dart';
import 'package:sumeeb_chat/data/cubits/recent-chats-cubit/recent_chat_state.dart';
import 'package:sumeeb_chat/data/cubits/sidebar-manager/sider_manager_cubit.dart';
import 'package:sumeeb_chat/data/cubits/user-cubit/user_cubit.dart';
import 'package:sumeeb_chat/data/models/user/user_model.dart';
import 'package:sumeeb_chat/pages/chatroom/chatroom_page.dart';
import 'package:sumeeb_chat/services/stream_service.dart';
import 'package:sumeeb_chat/widgets/recent_chat_tile.dart';

class ChatsPage extends StatefulWidget {
  final StreamService streamService;
  const ChatsPage({super.key, required this.streamService});

  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  @override
  void initState() {
    super.initState();
    _ensureStreamConnected();
    // _fetchPhoneContacts();
  }

  Future<void> _ensureStreamConnected() async {
    final user = context.read<UserCubit>().state.user!;
    print("=============== CONNECTING USER: ${user.id}");
    try {
      final streamService = context
          .read<ChatConnectionCubit>()
          .state
          .streamService;
      await streamService!.connectUser(formatUserId(user.id), user.name);
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
    final user = context.read<UserCubit>().state.user;
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            leading: SizedBox(),
            leadingWidth: 0,
            title: Text("Sumeeb Chat"),
          ),
          // floatingActionButton: Column(
          //   mainAxisAlignment: MainAxisAlignment.end,
          //   children: [
          //     FloatingActionButton(
          //       backgroundColor: Colors.amber,
          //       child: Icon(
          //         Icons.chat,
          //         color: Theme.of(context).colorScheme.surface,
          //       ),
          //       onPressed: () {
          //         final streamService = StreamService();
          //         if (Platform.isWindows) {
          //           context.read<SiderManagerCubit>().onViewContactsPage(
          //             widget.currentUser,
          //             streamService,
          //           );
          //         } else {
          //           Navigator.push(
          //             context,
          //             MaterialPageRoute(
          //               builder: (context) => ContactsPage(
          //                 currentUser: widget.currentUser,
          //                 streamService: streamService,
          //               ),
          //             ),
          //           );
          //         }
          //       },
          //     ),
          //     Platform.isWindows
          //         ? SizedBox(height: MediaQuery.of(context).size.height * 0.15)
          //         : SizedBox(height: MediaQuery.of(context).size.height * 0.09),
          //   ],
          // ),
          body: BlocBuilder<RecentChatCubit, RecentChatState>(
            builder: (context, state) {
              return state.recentChats.isEmpty
                  ? Center(child: Text("No recent chats"))
                  : ListView.builder(
                      itemCount: state.recentChats.length,
                      itemBuilder: (ctx, i) => RecentChatTile(
                        recentChat: state.recentChats[i],
                        onTap: (u) async {
                          print(
                            "=============== CONNECTING OTHER USER: ${u.id}",
                          );
                          context.read<ChatConnectionCubit>().makeConnection(
                            user!,
                            u,
                            widget.streamService,
                          );
                          if (Platform.isWindows) {
                            context
                                .read<SiderManagerCubit>()
                                .onViewChatroomPage();
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
          ),
        );
      },
    );
  }
}
