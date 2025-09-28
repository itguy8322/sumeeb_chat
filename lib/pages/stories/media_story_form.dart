// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:io';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sumeeb_chat/data/cubits/sidebar-manager/sider_manager_cubit.dart';
import 'package:sumeeb_chat/data/cubits/story-cubit/story_cubit.dart';
import 'package:sumeeb_chat/data/cubits/story-cubit/story_state.dart';
import 'package:sumeeb_chat/data/models/user/user_model.dart';
import 'package:sumeeb_chat/pages/stories/generate_thumbnail.dart';

class MediaStoryForm extends StatefulWidget {
  final AppUser user;
  MediaStoryForm({super.key, required this.user});

  @override
  State<MediaStoryForm> createState() => _MediaStoryFormState();
}

class _MediaStoryFormState extends State<MediaStoryForm> {
  final ImagePicker _picker = ImagePicker();
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
    context.read<StoryCubit>().reset();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            if (Platform.isWindows) {
              context.read<SiderManagerCubit>().resetToDefaultPage();
            } else {
              Navigator.pop(context);
            }
          },
          icon: Icon(Icons.arrow_back_ios),
        ),
        title: Text("Add Story"),
      ),
      body: Padding(
        padding: EdgeInsets.all(17.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: BlocBuilder<StoryCubit, StoryState>(
                builder: (context, state) {
                  return Center(
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.3,
                      width: MediaQuery.of(context).size.width * 0.7,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white.withOpacity(0.3),
                      ),
                      child: state.type == 'photo'
                          ? state.photoUrl != null && state.photoUrl!.isNotEmpty
                                ? Image.file(File(state.photoUrl!))
                                : SizedBox()
                          : state.type == 'video'
                          ? FutureBuilder<File?>(
                              future: generateThumbnail(state.videoUrl!),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                    child: const CircularProgressIndicator(),
                                  );
                                }
                                if (snapshot.hasData && snapshot.data != null) {
                                  return Image.file(snapshot.data!);
                                }
                                return const Icon(
                                  Icons.play_circle_outline,
                                  size: 50,
                                );
                              },
                            )
                          : SizedBox(),
                    ),
                  );
                },
              ),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
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
                            icon: Icon(Icons.emoji_emotions),
                            onPressed: _toggleEmojiPicker,
                          ),
                          Expanded(
                            child: TextField(
                              controller: _messageController,
                              decoration: InputDecoration(
                                hintText: 'Add caption',
                                border: InputBorder.none,
                              ),

                              onChanged: (text) async {
                                if (text.trim().isEmpty) return;

                                context.read<StoryCubit>().onCaptionChanged(
                                  text.trim(),
                                );
                                // await state.channel!.sendMessage(
                                //   Message(text: text.trim()),
                                // );
                                // _messageController.clear();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                BlocBuilder<StoryCubit, StoryState>(
                  builder: (context, state) {
                    return Row(
                      children: [
                        InkWell(
                          onTap: () async {
                            context.read<StoryCubit>().onTypeChanged('photo');
                            final pickedFile = await _picker.pickImage(
                              source: ImageSource.gallery,
                            );
                            if (pickedFile != null) {
                              (pickedFile.path);
                              context.read<StoryCubit>().setPhotoUrl(
                                pickedFile.path,
                              );
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10.0),
                            decoration: BoxDecoration(
                              color: state.type == 'photo'
                                  ? Colors.amber
                                  : null,
                              borderRadius: BorderRadius.circular(20),
                            ),

                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.image,
                                  color: state.type == 'photo'
                                      ? Theme.of(context).colorScheme.surface
                                      : null,
                                ),
                                Text(
                                  "Photo",
                                  style: TextStyle(
                                    color: state.type == 'photo'
                                        ? Theme.of(context).colorScheme.surface
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () async {
                            context.read<StoryCubit>().onTypeChanged('video');
                            FilePickerResult? result = await FilePicker.platform
                                .pickFiles();

                            if (result != null &&
                                result.files.single.path != null) {
                              final filePath = result.files.single.path!;
                              context.read<StoryCubit>().setVideoUrl(filePath);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10.0),
                            decoration: BoxDecoration(
                              color: state.type == 'video'
                                  ? Colors.amber
                                  : null,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.movie,
                                  color: state.type == 'video'
                                      ? Theme.of(context).colorScheme.surface
                                      : null,
                                ),
                                Text(
                                  "Video",
                                  style: TextStyle(
                                    color: state.type == 'video'
                                        ? Theme.of(context).colorScheme.surface
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                BlocBuilder<StoryCubit, StoryState>(
                  builder: (context, state) {
                    return IconButton(
                      onPressed: () {
                        if (state.type.isNotEmpty &&
                                state.photoUrl!.isNotEmpty ||
                            state.videoUrl!.isNotEmpty) {
                          context.read<StoryCubit>().uploadStory(
                            user: widget.user,
                          );
                          if (!Platform.isWindows) {
                            Navigator.pop(context);
                          } else {
                            context
                                .read<SiderManagerCubit>()
                                .resetToDefaultPage();
                          }
                          print("There is file");
                        } else {
                          print("No file");
                        }
                      },
                      icon: Icon(Icons.send),
                    );
                  },
                ),
              ],
            ),
            Offstage(
              offstage: !_showEmojiPicker,
              child: SizedBox(
                height: 260,
                child: EmojiPicker(
                  onEmojiSelected: _onEmojiSelected,
                  config: Config(
                    emojiViewConfig: EmojiViewConfig(
                      // backgroundColor: Theme.of(context).colorScheme.surface,
                      columns: Platform.isAndroid ? 10 : 13,
                      emojiSizeMax: Platform.isAndroid ? 32 : 28,
                      // buttonMode: ButtonMode.NONE,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
