import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sumeeb_chat/cubits/chat-connection/chat_connection_cubit.dart';
import 'package:sumeeb_chat/cubits/chat-connection/chat_connection_state.dart';
import 'package:sumeeb_chat/services/stream_service.dart';
import '../models/user_model.dart';
import 'thread_page.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:file_picker/file_picker.dart';

class ChatPage extends StatefulWidget {
  final AppUser currentUser;
  final AppUser other;
  final StreamService streamService;
  const ChatPage({
    super.key,
    required this.currentUser,
    required this.other,
    required this.streamService,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
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
    // MaterialApp(
    //                     builder: (context, child) {
    //                       return StreamChat(
    //                         client: widget.streamService.client,
    //                         child: child,
    //                       );
    //                     },
    //                     home: StreamChannel(
    //                       channel: channel,
    //                       child: ChatPage(
    //                         currentUser: widget.currentUser,
    //                         other: u,
    //                         channel: channel,
    //                         streamService: widget.streamService,
    //                       ),
    //                     ),
    //                   )
    return MaterialApp(
      builder: (context, child) {
        return StreamChat(client: widget.streamService.client, child: child);
      },
      home: BlocBuilder<ChatConnectionCubit, ChatConnectionState>(
        builder: (context, state) {
          if (state.channel != null) {
            return StreamChannel(
              channel: state.channel!,
              child: Scaffold(
                appBar: AppBar(
                  title: Row(
                    children: [
                      CircleAvatar(
                        child: Text(
                          widget.other.name.isNotEmpty
                              ? widget.other.name[0]
                              : '?',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.other.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            widget.other.phone ?? '',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                body: Column(
                  children: [
                    Expanded(
                      child: (state.conectingInProgress)
                          ? Center(child: CircularProgressIndicator())
                          : (state.connectionSuccess)
                          ? StreamMessageListView(
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
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.attach_file),
                                onPressed: () async {
                                  FilePickerResult? result = await FilePicker
                                      .platform
                                      .pickFiles();

                                  if (result != null &&
                                      result.files.single.path != null) {
                                    final filePath = result.files.single.path!;

                                    // Send the file as attachment
                                    await state.channel!.sendMessage(
                                      Message(
                                        attachments: [
                                          Attachment(
                                            type: 'file',
                                            file: AttachmentFile(
                                              path: filePath,
                                              name: result.files.single.name,
                                              size: result.files.single.size,
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
                                    if (text.trim().isEmpty) return;
                                    await state.channel!.sendMessage(
                                      Message(text: text.trim()),
                                    );
                                    _messageController.clear();
                                  },
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.send),
                                onPressed: () async {
                                  final text = _messageController.text.trim();
                                  if (text.isEmpty) return;
                                  await state.channel!.sendMessage(
                                    Message(text: text),
                                  );
                                  _messageController.clear();
                                },
                              ),
                            ],
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
                                  columns: 7,
                                  emojiSizeMax: 32,
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
            );
          } else {
            return Scaffold(
              appBar: AppBar(
                title: Row(
                  children: [
                    CircleAvatar(
                      child: Text(
                        widget.other.name.isNotEmpty
                            ? widget.other.name[0]
                            : '?',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.other.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          widget.other.phone ?? '',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              body: Center(
                child: state.conectingInProgress
                    ? CircularProgressIndicator()
                    : state.connectingFailure
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        spacing: 10,
                        children: [
                          Text("Connection error, check internt and try again"),
                          ElevatedButton(
                            onPressed: () {
                              context
                                  .read<ChatConnectionCubit>()
                                  .makeConnection(
                                    widget.currentUser,
                                    widget.other,
                                    widget.streamService,
                                  );
                            },
                            child: Text("Retry"),
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
  }
}
