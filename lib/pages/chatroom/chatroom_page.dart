import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sumeeb_chat/data/cubits/chat-connection/chat_connection_cubit.dart';
import 'package:sumeeb_chat/data/cubits/chat-connection/chat_connection_state.dart';
import 'package:sumeeb_chat/data/cubits/recent-chats-cubit/recent_chat_cubit.dart';
import 'package:sumeeb_chat/data/cubits/sidebar-manager/sider_manager_cubit.dart';
import 'package:sumeeb_chat/data/cubits/user-cubit/user_cubit.dart';
import 'package:sumeeb_chat/pages/chatroom/view_profile_photo.dart';
import 'package:sumeeb_chat/pages/contacts/contacts_page.dart';
import 'package:sumeeb_chat/pages/home/home_page.dart';
import 'package:sumeeb_chat/services/stream_service.dart';
import 'package:sumeeb_chat/styles/color_schemes.dart';
import 'thread_page.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:file_picker/file_picker.dart';

class ChatroomPage extends StatefulWidget {
  final StreamService streamService;
  const ChatroomPage({super.key, required this.streamService});

  @override
  State<ChatroomPage> createState() => _ChatroomPageState();
}

class _ChatroomPageState extends State<ChatroomPage> {
  bool _showEmojiPicker = false;
  final TextEditingController _messageController = TextEditingController();

  void _onEmojiSelected(Category? category, Emoji emoji) {
    _messageController.text += emoji.emoji;
    _messageController.selection = TextSelection.fromPosition(
      TextPosition(offset: _messageController.text.length),
    );
  }

  void _toggleEmojiPicker() {
    setState(() {
      _showEmojiPicker = !_showEmojiPicker;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<UserCubit>().state.user!;
    print("##############################");
    final other = context.read<ChatConnectionCubit>().state.otherUser;
    print("##############################");
    return BlocBuilder<ChatConnectionCubit, ChatConnectionState>(
      builder: (context, conn) {
        return MaterialApp(
          theme: ThemeData(colorScheme: myColorScheme),
          builder: (context, child) {
            print(
              "########### ${widget.streamService} #################>>>>>>>>>>>",
            );
            return StreamChat(
              client: widget.streamService.client,
              child: child,
            );
          },
          home: BlocBuilder<ChatConnectionCubit, ChatConnectionState>(
            builder: (context, state) {
              if (state.channel != null) {
                return StreamChannel(
                  channel:
                      state.channel ??
                      Channel(
                        widget.streamService.client,
                        'messaging',
                        '',
                        extraData: {},
                      ),
                  child: StreamChatTheme(
                    data: StreamChatThemeData(
                      otherMessageTheme: StreamMessageThemeData(
                        messageBackgroundColor: Colors.white,
                        messageTextStyle: const TextStyle(
                          color: Colors.black,
                          fontSize: 17,
                        ),
                      ),
                      ownMessageTheme: StreamMessageThemeData(
                        messageBackgroundColor: const Color.fromARGB(
                          255,
                          221,
                          209,
                          173,
                        ),
                        messageTextStyle: const TextStyle(
                          color: Colors.black,
                          fontSize: 17,
                        ),
                      ),
                      channelHeaderTheme: StreamChannelHeaderThemeData(
                        color: Theme.of(
                          context,
                        ).colorScheme.surface, // 👈 header background
                        // titleStyle: TextStyle(        // 👈 channel name style
                        //   color: Colors.white,
                        //   fontWeight: FontWeight.bold,
                        //   fontSize: 18,
                        // ),
                        // subtitleStyle: TextStyle(     // 👈 subtitle (like last seen)
                        //   color: Colors.white70,
                        //   fontSize: 14,
                        // ),
                      ),
                      messageListViewTheme: StreamMessageListViewThemeData(
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.surface, // 👈 change background here
                      ),
                    ),
                    child: Scaffold(
                      appBar: StreamChannelHeader(
                        leading: IconButton(
                          onPressed: () {
                            context
                                .read<ChatConnectionCubit>()
                                .resetConnection();
                            if (Platform.isWindows) {
                              context
                                  .read<SiderManagerCubit>()
                                  .resetToDefaultPage();
                              return;
                            }
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HomePage(
                                  streamService: widget.streamService,
                                ),
                              ),
                            );
                          },
                          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                        ),

                        title: Row(
                          children: [
                            Text(
                              other != null
                                  ? other.disPlayName.isNotEmpty
                                        ? other.disPlayName
                                        : other.name
                                  : 'Unknown',
                            ),
                          ],
                        ),
                        onBackPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ContactsPage(
                                streamService: widget.streamService,
                              ),
                            ),
                          );
                        },
                        actions: [
                          InkWell(
                            onTap: () {
                              if (other == null) return;
                              if (Platform.isWindows) {
                                context
                                    .read<SiderManagerCubit>()
                                    .onViewProfilePhotoPage(other, false);
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ViewProfilePhoto(
                                      user: other,
                                      isMe: false,
                                    ),
                                  ),
                                );
                              }
                            },
                            child: CircleAvatar(
                              child: other != null
                                  ? other.profilePhoto != null
                                        ? other.profilePhoto!.isNotEmpty
                                              ? ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(70),
                                                  child: Image.network(
                                                    other.profilePhoto!,
                                                  ),
                                                )
                                              : Text(
                                                  other.name[0],
                                                  style: TextStyle(
                                                    color: Theme.of(
                                                      context,
                                                    ).colorScheme.surface,
                                                  ),
                                                )
                                        : Text(
                                            other.name[0],
                                            style: TextStyle(
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.surface,
                                            ),
                                          )
                                  : Text(
                                      'Unknown',
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.surface,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                      body: Column(
                        children: [
                          Expanded(
                            child: (state.conectingInProgress)
                                ? Center(child: CircularProgressIndicator())
                                : (state.connectionSuccess)
                                ? StreamMessageListView(
                                    messageBuilder: (context, details, messages, defaultMessage) {
                                      final message = details.message;
                                      final currentUser = StreamChat.of(
                                        context,
                                      ).currentUser;

                                      if (message.user!.id != currentUser!.id) {
                                        // Receiver’s message → custom avatar + bubble
                                        return Stack(
                                          children: [
                                            defaultMessage,
                                            Positioned(
                                              bottom: 0,
                                              left: 5,
                                              child: CircleAvatar(
                                                radius: 18,

                                                child: other != null
                                                    ? other.profilePhoto != null
                                                          ? other
                                                                    .profilePhoto!
                                                                    .isNotEmpty
                                                                ? ClipRRect(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                          70,
                                                                        ),
                                                                    child: Image.network(
                                                                      other
                                                                          .profilePhoto!,
                                                                    ),
                                                                  )
                                                                : Text(
                                                                    other
                                                                        .name[0],
                                                                    style: TextStyle(
                                                                      color: Theme.of(
                                                                        context,
                                                                      ).colorScheme.surface,
                                                                    ),
                                                                  )
                                                          : Text(
                                                              other.name[0],
                                                              style: TextStyle(
                                                                color: Theme.of(
                                                                  context,
                                                                ).colorScheme.surface,
                                                              ),
                                                            )
                                                    : Text(
                                                        'Unknown',
                                                        style: TextStyle(
                                                          color: Theme.of(
                                                            context,
                                                          ).colorScheme.surface,
                                                        ),
                                                      ),
                                              ),
                                            ),
                                          ],
                                        );
                                      }

                                      // Sender’s (my own) message → just bubble
                                      return defaultMessage;
                                    },
                                    threadBuilder: (context, parent) {
                                      return ThreadPage(parent: parent!);
                                    },
                                  )
                                : (state.connectingFailure)
                                ? Center(child: Text("Error Loading message"))
                                : Center(child: Text("Error Loading message")),
                          ),
                          // StreamMessageInput(),
                          Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(18.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Color.fromARGB(255, 7, 0, 41),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.attach_file),
                                        onPressed: () async {
                                          FilePickerResult? result =
                                              await FilePicker.platform
                                                  .pickFiles();

                                          if (result != null &&
                                              result.files.single.path !=
                                                  null) {
                                            final filePath =
                                                result.files.single.path!;

                                            // Send the file as attachment
                                            await state.channel!.sendMessage(
                                              Message(
                                                attachments: [
                                                  Attachment(
                                                    type: 'file',
                                                    file: AttachmentFile(
                                                      path: filePath,
                                                      name: result
                                                          .files
                                                          .single
                                                          .name,
                                                      size: result
                                                          .files
                                                          .single
                                                          .size,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.emoji_emotions),
                                        onPressed: _toggleEmojiPicker,
                                      ),
                                      Expanded(
                                        child: TextField(
                                          controller: _messageController,
                                          decoration: InputDecoration(
                                            hintText: 'Type a message...',
                                            border: InputBorder.none,
                                          ),

                                          onSubmitted: (text) async {
                                            if (text.trim().isEmpty ||
                                                other == null)
                                              return;

                                            context
                                                .read<RecentChatCubit>()
                                                .addChatToHistory(
                                                  other,
                                                  text.trim(),
                                                );
                                            await state.channel!.sendMessage(
                                              Message(
                                                text: text.trim(),
                                                extraData: {
                                                  'sender_id': currentUser.id,
                                                  'sender_name':
                                                      currentUser.name,
                                                },
                                              ),
                                            );
                                            _messageController.clear();
                                          },
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.send),
                                        onPressed: () async {
                                          final text = _messageController.text
                                              .trim();
                                          if (text.isEmpty || other == null) {
                                            return;
                                          }
                                          context
                                              .read<RecentChatCubit>()
                                              .addChatToHistory(other, text);
                                          await state.channel!.sendMessage(
                                            Message(text: text),
                                          );
                                          _messageController.clear();
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Offstage(
                                offstage: !_showEmojiPicker,
                                child: SizedBox(
                                  height: 250,
                                  child: EmojiPicker(
                                    onEmojiSelected: _onEmojiSelected,
                                    config: Config(
                                      emojiViewConfig: EmojiViewConfig(
                                        // backgroundColor: Theme.of(context).colorScheme.surface,
                                        columns: Platform.isAndroid ? 10 : 13,
                                        emojiSizeMax: Platform.isAndroid
                                            ? 32
                                            : 28,
                                        // buttonMode: ButtonMode.NONE,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              } else {
                return Scaffold(
                  appBar: AppBar(
                    leading: IconButton(
                      onPressed: () {
                        context.read<ChatConnectionCubit>().resetConnection();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                HomePage(streamService: widget.streamService),
                          ),
                        );
                      },
                      icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                    ),
                    title: Text("Sumeeb Chat"),
                  ),
                  body: Center(
                    child: state.conectingInProgress
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(strokeWidth: 3.0),
                              SizedBox(height: 10),
                              Text(
                                "Loading messages...",
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          )
                        : state.connectingFailure
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            spacing: 10,
                            children: [
                              Text(
                                "Connection error, check your internet and try again",
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.amber,
                                  padding: EdgeInsets.symmetric(
                                    vertical: 14,
                                    horizontal:
                                        MediaQuery.of(context).size.width *
                                        0.12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () {
                                  if (other != null) {
                                    context
                                        .read<ChatConnectionCubit>()
                                        .makeConnection(
                                          currentUser,
                                          other,
                                          widget.streamService,
                                        );
                                  }
                                },
                                child: Text(
                                  "Retry",
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                            ],
                          )
                        : SizedBox(),
                  ),
                );
              }
            },
          ),
        );
      },
    );
  }
}
