// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:sumeeb_chat/data/cubits/chat-connection/chat_connection_cubit.dart';
import 'package:sumeeb_chat/data/cubits/chat-connection/chat_connection_state.dart';
import 'package:sumeeb_chat/data/cubits/contacts-cubit/contacts_cubit.dart';
import 'package:sumeeb_chat/data/cubits/recent-chats-cubit/recent_chat_cubit.dart';
import 'package:sumeeb_chat/data/cubits/sidebar-manager/sider_manager_cubit.dart';
import 'package:sumeeb_chat/data/cubits/user-cubit/user_cubit.dart';
import 'package:sumeeb_chat/pages/chatroom/image_atttachment.dart';
import 'package:sumeeb_chat/pages/chatroom/reply_message.dart';
import 'package:sumeeb_chat/pages/chatroom/reply_preview.dart';
import 'package:sumeeb_chat/pages/chatroom/view_profile_photo.dart';
import 'package:sumeeb_chat/pages/chatroom/voicenote_attachment.dart';
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

  // Replace 'AudioRecorder()' with the actual concrete implementation of Record, or remove if not used
  final AudioRecorder _recorder = AudioRecorder();
  Timer? recodeTimer;
  bool _isRecording = false;
  String? _filePath;
  int _recordDuration = 0;
  bool isReplyMessage = false;
  Message? replyMessage;
  final Map<String, GlobalKey> messageKeys = {};

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

  void startRecordTimer() async {
    recodeTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _recordDuration++;
      });
      // timer.tick
    });
  }

  Future<void> _toggleRecord() async {
    try {
      final hasPermission = await _recorder.hasPermission();
      if (!hasPermission) {
        return;
      }
      final status = await Permission.microphone.request();
      if (!status.isGranted) {
        return;
      }
      if (!_isRecording) {
        // Start recording

        final dir = await getApplicationDocumentsDirectory();
        final path =
            '${dir.path}/voice_note_${DateTime.now().millisecondsSinceEpoch}.m4a';

        await _recorder.start(path: path, RecordConfig());
        startRecordTimer();
        setState(() {
          _isRecording = true;
          _filePath = path;
        });
      } else {
        // Stop recording
        final path = await _recorder.stop();
        setState(() {
          _isRecording = false;
          _filePath = path;
          _recordDuration = 0;
          recodeTimer?.cancel();
        });

        if (path != null) {
          final file = File(path);
          if (await file.exists()) {
            final length = await file.length();
            final state = context.read<ChatConnectionCubit>().state;
            final channel = state.channel;
            if (channel == null) return;
            // final serialNo = Random().nextInt(9999999);
            await channel.sendMessage(
              Message(
                attachments: [
                  Attachment(
                    type: 'audio',
                    file: AttachmentFile(
                      path: path,
                      name: "VOICE_NOTE.mp3",
                      size: File(path).lengthSync(),
                    ),
                  ),
                ],
              ),
            );
          } else {}
        }
      }
    } catch (e, st) {}
  }

  void cancelRecording() async {
    if (_isRecording) {
      await _recorder.stop();
      recodeTimer?.cancel();
      setState(() {
        _isRecording = false;
        _filePath = null;
        _recordDuration = 0;
      });
    }
  }

  String formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return "$minutes:$secs";
  }

  final GlobalKey _attachmentButton = GlobalKey();
  void _showAttachmentTypes() async {
    final RenderBox button =
        _attachmentButton.currentContext!.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final Offset position = button.localToGlobal(
      Offset.zero,
      ancestor: overlay,
    );
    final other = context.read<ChatConnectionCubit>().state.otherUser;

    final selected = await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy + button.size.height,
        position.dx + button.size.width,
        position.dy,
      ),
      items: [
        PopupMenuItem(
          value: '',
          child: SizedBox(
            width: 300,
            height: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    IconButton(
                      icon: Icon(Icons.image, size: 40, color: Colors.blue),
                      onPressed: () async {
                        Navigator.pop(context, 'image');
                        FilePickerResult? result = await FilePicker.platform
                            .pickFiles(
                              type: FileType.image,
                              allowMultiple: true,
                            );

                        if (result != null) {
                          final files = result.files
                              .map((file) => file)
                              .toList();
                          if (files.isEmpty) return;
                          final state = context
                              .read<ChatConnectionCubit>()
                              .state;
                          final channel = state.channel;
                          if (channel == null) return;
                          context.read<RecentChatCubit>().addChatToHistory(
                            other!,
                            _messageController.text.trim().isEmpty
                                ? "Photo"
                                : _messageController.text.trim(),
                            'image',
                          );
                          await state.channel!.sendMessage(
                            Message(
                              text: _messageController.text,
                              attachments: List.generate(
                                files.length,
                                (index) => Attachment(
                                  type: 'image',
                                  file: AttachmentFile(
                                    path: files[index].path,
                                    name: files[index].name,
                                    size: files[index].size,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                      },
                    ),
                    Text("Photos"),
                  ],
                ),
                Column(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.videocam_sharp,
                        size: 40,
                        color: Colors.purple,
                      ),
                      onPressed: () async {
                        Navigator.pop(context, 'video');
                        FilePickerResult? result = await FilePicker.platform
                            .pickFiles(
                              type: FileType.video,
                              allowMultiple: true,
                            );

                        if (result != null) {
                          final files = result.files
                              .map((file) => file)
                              .toList();
                          if (files.isEmpty) return;
                          final state = context
                              .read<ChatConnectionCubit>()
                              .state;
                          final channel = state.channel;
                          if (channel == null) return;

                          context.read<RecentChatCubit>().addChatToHistory(
                            other!,
                            _messageController.text.trim().isEmpty
                                ? "Video"
                                : _messageController.text.trim(),
                            'video',
                          );
                          await state.channel!.sendMessage(
                            Message(
                              text: _messageController.text,
                              attachments: List.generate(
                                files.length,
                                (index) => Attachment(
                                  type: 'video',
                                  file: AttachmentFile(
                                    path: files[index].path,
                                    name: files[index].name,
                                    size: files[index].size,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                      },
                    ),
                    Text("Videos"),
                  ],
                ),
                Column(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.insert_drive_file,
                        size: 40,
                        color: Colors.grey,
                      ),
                      onPressed: () async {
                        Navigator.pop(context, 'document');
                        FilePickerResult? result = await FilePicker.platform
                            .pickFiles(type: FileType.any, allowMultiple: true);

                        if (result != null) {
                          final files = result.files
                              .map((file) => file)
                              .toList();
                          if (files.isEmpty) return;
                          final state = context
                              .read<ChatConnectionCubit>()
                              .state;
                          final channel = state.channel;
                          if (channel == null) return;
                          context.read<RecentChatCubit>().addChatToHistory(
                            other!,
                            _messageController.text.trim().isEmpty
                                ? "File"
                                : _messageController.text.trim(),
                            'file',
                          );
                          await state.channel!.sendMessage(
                            Message(
                              text: _messageController.text,
                              attachments: List.generate(
                                files.length,
                                (index) => Attachment(
                                  type: 'file',
                                  file: AttachmentFile(
                                    path: files[index].path,
                                    name: files[index].name,
                                    size: files[index].size,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                      },
                    ),
                    Text("Documents"),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );

    if (selected != null) {}
  }

  void scrollToQuotedMessage(String messageId) {
    final key = messageKeys[messageId];
    if (key == null) return;

    final ctx = key.currentContext;
    if (ctx == null) return;

    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 400),
      alignment: 0.3, // bring it near center
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<UserCubit>().state.user!;
    // print("##############################");
    final other = context.read<ChatConnectionCubit>().state.otherUser;
    // print("##############################");

    return BlocBuilder<ChatConnectionCubit, ChatConnectionState>(
      builder: (context, conn) {
        return MaterialApp(
          theme: ThemeData(colorScheme: myColorScheme),
          builder: (context, child) {
            // print(
            //   "########### ${widget.streamService} #################>>>>>>>>>>>",
            // );
            return StreamChat(
              client: widget.streamService.client,
              child: child,
            );
          },
          home: BlocBuilder<ChatConnectionCubit, ChatConnectionState>(
            builder: (context, state) {
              if (state.channel != null) {
                return StreamChannel(
                  channel: state.channel!,
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
                                    onMessageTap: (p0) {
                                      print("WHO GOOOOOOOO");
                                    },
                                    messageBuilder: (context, details, messages, defaultMessage) {
                                      final message = details.message;
                                      final currentUser = StreamChat.of(
                                        context,
                                      ).currentUser;
                                      final key = GlobalKey();
                                      messageKeys[message.id] = key;
                                      final Map<String, dynamic>? replyTo =
                                          message.extraData['reply_to'] != null
                                          ? message.extraData['reply_to']
                                                as Map<String, dynamic>
                                          : null;
                                      // if (replyTo != null) {
                                      //   print(
                                      //     "+${replyTo["user"]} == ${currentUser!.id}",
                                      //   );
                                      // }
                                      if (message.user!.id != currentUser!.id) {
                                        // Receiver’s message → custom avatar + bubble
                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            replyTo != null &&
                                                    !message.isDeleted
                                                ? InkWell(
                                                    onTap: () {
                                                      final messageId =
                                                          replyTo['id'];
                                                      if (messageId != null) {
                                                        scrollToQuotedMessage(
                                                          messageId!,
                                                        );
                                                      }
                                                    },
                                                    child: ReplyMessage(
                                                      currentUser: currentUser,
                                                      replyTo: replyTo,
                                                    ),
                                                  )
                                                : SizedBox(),
                                            GestureDetector(
                                              key: key,
                                              onPanStart: (details) {},
                                              onPanUpdate: (details) {
                                                // Check horizontal movement (swipe right)
                                                if (details.delta.dx > 10) {
                                                  setState(() {
                                                    isReplyMessage = true;
                                                    replyMessage = message;
                                                  });
                                                }
                                              },
                                              onPanEnd: (details) {
                                                if (isReplyMessage) {}
                                              },
                                              child: Stack(
                                                children: [
                                                  defaultMessage.copyWith(
                                                    attachmentBuilders: [
                                                      AudioAttachmentBuilder(),
                                                    ],
                                                  ),
                                                  Positioned(
                                                    bottom: 0,
                                                    left: 5,
                                                    child: CircleAvatar(
                                                      radius: 18,

                                                      child: other != null
                                                          ? other.profilePhoto !=
                                                                    null
                                                                ? other
                                                                          .profilePhoto!
                                                                          .isNotEmpty
                                                                      ? ClipRRect(
                                                                          borderRadius: BorderRadius.circular(
                                                                            70,
                                                                          ),
                                                                          child: Image.network(
                                                                            other.profilePhoto!,
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
                                                                    other
                                                                        .name[0],
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
                                            ),
                                          ],
                                        );
                                      }

                                      // Sender’s (my own) message → just bubble
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          replyTo != null && !message.isDeleted
                                              ? InkWell(
                                                  onTap: () {
                                                    final messageId =
                                                        replyTo['id'];
                                                    if (messageId != null) {
                                                      scrollToQuotedMessage(
                                                        messageId!,
                                                      );
                                                    }
                                                  },
                                                  child: ReplyMessage(
                                                    currentUser: currentUser,
                                                    replyTo: replyTo,
                                                  ),
                                                )
                                              : SizedBox(),
                                          GestureDetector(
                                            key: key,
                                            onPanStart: (details) {},
                                            onPanUpdate: (details) {
                                              // Check horizontal movement (swipe right)
                                              if (details.delta.dx > 10) {
                                                setState(() {
                                                  isReplyMessage = true;
                                                  replyMessage = message;
                                                });
                                              }
                                            },
                                            onPanEnd: (details) {
                                              if (isReplyMessage) {}
                                            },
                                            child: defaultMessage.copyWith(
                                              showDeleteMessage: true,
                                              showReplyMessage: true,
                                              showReactionPicker: true,
                                              // onMessageLongPress: (p0) {},
                                              attachmentBuilders: [
                                                AudioAttachmentBuilder(),
                                              ],
                                            ),
                                          ),
                                        ],
                                      );
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
                              if (_isRecording)
                                (Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    8,
                                    0,
                                    20,
                                    0,
                                  ),
                                  child: Row(
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          cancelRecording();
                                        },
                                        icon: Icon(Icons.cancel_outlined),
                                      ),
                                      Text("Recording..."),
                                      Spacer(),
                                      Text(formatTime(_recordDuration)),
                                    ],
                                  ),
                                ))
                              else
                                SizedBox(),
                              isReplyMessage
                                  ? ReplyPreview(
                                      currentUser: currentUser,
                                      replyMessage: replyMessage!,
                                      onClose: () {
                                        setState(() {
                                          isReplyMessage = false;
                                          replyMessage = null;
                                        });
                                      },
                                    )
                                  : SizedBox(),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  18.0,
                                  2,
                                  18,
                                  18,
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Color.fromARGB(255, 7, 0, 41),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      IconButton(
                                        key: _attachmentButton,
                                        icon: Icon(Icons.attach_file),
                                        onPressed: () async {
                                          _showAttachmentTypes();
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

                                            // final message_id = "message-id-${currentUser.id}-${DateTime.now()
                                            //     .microsecondsSinceEpoch}";
                                            // if (replyMessage != null){
                                            //   context.read<ChatConnectionCubit>().addRepyMessage(message_id, replyMessage!);
                                            // }
                                            final type = replyMessage
                                                ?.attachments
                                                .first
                                                .type
                                                ?.rawType;
                                            context
                                                .read<RecentChatCubit>()
                                                .addChatToHistory(
                                                  other,
                                                  text.trim(),
                                                  type ?? 'regular',
                                                );
                                            await state.channel!.sendMessage(
                                              Message(
                                                // id: message_id,
                                                text: text.trim(),

                                                extraData: {
                                                  'reply_to':
                                                      replyMessage == null
                                                      ? null
                                                      : {
                                                          'id':
                                                              replyMessage!.id,
                                                          'text': replyMessage!
                                                              .text,
                                                          'user': replyMessage!
                                                              .user
                                                              ?.name,
                                                          'type': type,
                                                          'attachments':
                                                              type == 'image'
                                                              ? List.generate(
                                                                  replyMessage!
                                                                      .attachments
                                                                      .length,
                                                                  (
                                                                    index,
                                                                  ) => replyMessage!
                                                                      .attachments[index]
                                                                      .imageUrl,
                                                                )
                                                              : List.generate(
                                                                  replyMessage!
                                                                      .attachments
                                                                      .length,
                                                                  (
                                                                    index,
                                                                  ) => replyMessage!
                                                                      .attachments[index]
                                                                      .assetUrl,
                                                                ),
                                                        },
                                                  'sender_id': currentUser.id,
                                                  'sender_name':
                                                      currentUser.name,
                                                },
                                              ),
                                            );
                                            _messageController.clear();
                                            setState(() {
                                              replyMessage = null;
                                              isReplyMessage = false;
                                            });
                                          },
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          _isRecording ? Icons.stop : Icons.mic,
                                          color: Colors.red,
                                        ),
                                        onPressed: () {
                                          // Implement voice note recording and sending
                                          _toggleRecord();
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.send),
                                        onPressed: () async {
                                          final text = _messageController.text
                                              .trim();
                                          if (text.isEmpty || other == null) {
                                            return;
                                          }

                                          final type = replyMessage
                                              ?.attachments
                                              .first
                                              .type
                                              ?.rawType;
                                          context
                                              .read<RecentChatCubit>()
                                              .addChatToHistory(
                                                other,
                                                text,
                                                type ?? 'regular',
                                              );
                                          await state.channel!.sendMessage(
                                            Message(
                                              text: text,
                                              extraData: {
                                                'reply_to': replyMessage == null
                                                    ? null
                                                    : {
                                                        'id': replyMessage!.id,
                                                        'text':
                                                            replyMessage!.text,
                                                        'user': replyMessage!
                                                            .user
                                                            ?.name,
                                                        'type': type,
                                                        'attachments':
                                                            type == 'image'
                                                            ? List.generate(
                                                                replyMessage!
                                                                    .attachments
                                                                    .length,
                                                                (
                                                                  index,
                                                                ) => replyMessage!
                                                                    .attachments[index]
                                                                    .imageUrl,
                                                              )
                                                            : List.generate(
                                                                replyMessage!
                                                                    .attachments
                                                                    .length,
                                                                (
                                                                  index,
                                                                ) => replyMessage!
                                                                    .attachments[index]
                                                                    .assetUrl,
                                                              ),
                                                      },
                                                'sender_id': currentUser.id,
                                                'sender_name': currentUser.name,
                                              },
                                            ),
                                          );
                                          _messageController.clear();
                                          setState(() {
                                            replyMessage = null;
                                            isReplyMessage = false;
                                          });
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

class AudioAttachmentBuilder extends StreamAttachmentWidgetBuilder {
  @override
  bool isSupported(Attachment attachment) {
    return attachment.type == 'audio' ||
        attachment.mimeType?.startsWith('audio') == true;
  }

  @override
  Widget build(
    BuildContext context,
    Message message,
    Map<String, List<Attachment>> attachments,
  ) {
    // Find audio attachments from the map
    final audioAttachments = attachments['audio'];
    if (audioAttachments != null && audioAttachments.isNotEmpty) {
      final attachment = audioAttachments.first;
      final url = attachment.assetUrl ?? attachment.file?.path;
      return VoiceNoteAttachment(attachment: attachment, audioUrl: url);
    }
    // Fallback if no audio attachment found
    return SizedBox.shrink();
  }

  @override
  bool canHandle(Message message, Map<String, List<Attachment>> attachments) {
    final attachment = message.attachments.isNotEmpty
        ? message.attachments.first
        : null;
    return attachment!.type == 'audio' ||
        (attachment.assetUrl?.endsWith('.m4a') ?? false) ||
        (attachment.assetUrl?.endsWith('.mp3') ?? false);
  }
}
