import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:auto_size_text_field/auto_size_text_field.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sumeeb_chat/data/cubits/sidebar-manager/sider_manager_cubit.dart';
import 'package:sumeeb_chat/data/cubits/story-cubit/story_cubit.dart';
import 'package:sumeeb_chat/data/cubits/story-cubit/story_state.dart';
import 'package:sumeeb_chat/data/models/user/user_model.dart';
import 'package:sumeeb_chat/styles/story_colors.dart';

class TextStoryForm extends StatefulWidget {
  final AppUser user;
  const TextStoryForm({super.key, required this.user});

  @override
  State<TextStoryForm> createState() => _TextStoryFormState();
}

class _TextStoryFormState extends State<TextStoryForm> {
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
    context.read<StoryCubit>().onTypeChanged('text');
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    return BlocBuilder<StoryCubit, StoryState>(
      builder: (context, story) {
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
            backgroundColor: storyColors[story.colorIndex],
          ),
          backgroundColor: storyColors[story.colorIndex],
          body: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: AutoSizeTextField(
                  minFontSize: 18,
                  maxFontSize: 45,
                  maxLines: 8,
                  minLines: 1,
                  controller: _messageController,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 45),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Type a story",
                  ),
                  onChanged: (value) {
                    context.read<StoryCubit>().onTextChanged(value);
                  },
                ),
              ),
              _showEmojiPicker || keyboardHeight > 0
                  ? SizedBox()
                  : SizedBox(height: MediaQuery.of(context).size.height * 0.35),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    spacing: 20,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        // spacing: 20,
                        children: [
                          IconButton(
                            onPressed: _toggleEmojiPicker,
                            icon: Icon(Icons.emoji_emotions),
                          ),
                          InkWell(
                            onTap: () {},
                            child: Text(
                              "T",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          InkWell(
                            onTap: () {
                              context.read<StoryCubit>().onColorChanged();
                            },
                            child: Image.asset("assets/icon/painting.png"),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () {
                          context.read<StoryCubit>().uploadStory(
                            user: widget.user,
                            storyText: _messageController.text,
                          );
                          if (!Platform.isWindows) {
                            Navigator.pop(context);
                          } else {
                            context
                                .read<SiderManagerCubit>()
                                .resetToDefaultPage();
                          }
                        },
                        icon: Icon(Icons.send),
                      ),
                    ],
                  ),
                  Offstage(
                    offstage: !_showEmojiPicker,
                    child: SizedBox(
                      height: 300,
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
              // SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}
