// ignore_for_file: library_private_types_in_public_api

import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:story_view/story_view.dart';
import 'package:sumeeb_chat/data/cubits/contacts-cubit/contacts_cubit.dart';
import 'package:sumeeb_chat/data/cubits/sidebar-manager/sider_manager_cubit.dart';
import 'package:sumeeb_chat/data/cubits/story-cubit/story_cubit.dart';
import 'package:sumeeb_chat/data/cubits/view-story-cubit/view_story_cubit.dart';
import 'package:sumeeb_chat/data/cubits/view-story-cubit/view_story_state.dart';
import 'package:sumeeb_chat/data/models/story-model/story_model.dart';
import 'package:sumeeb_chat/data/models/user/user_model.dart';
import 'package:sumeeb_chat/styles/story_colors.dart';

class ViewStoryPage extends StatelessWidget {
  final AppUser user;
  final String userId;
  final List<StoryModel> stories;
  ViewStoryPage({
    super.key,
    required this.user,
    required this.userId,
    required this.stories,
  });

  final StoryController _controller = StoryController();

  @override
  Widget build(BuildContext context) {
    context.read<ViewStoryCubit>().reset();
    return Scaffold(
      body: Stack(
        children: [
          StoryView(
            storyItems: List.generate(stories.length, (index) {
              return stories[index].type == 'text'
                  ? StoryItem.text(
                      title: stories[index].text ?? '',
                      backgroundColor:
                          storyColors[stories[index].color] ?? Colors.blue,
                      duration: const Duration(seconds: 2),
                      textStyle: const TextStyle(fontSize: 34),
                    )
                  : stories[index].type == 'photo'
                  ? StoryItem.pageImage(
                      url: "${stories[index].photoUrl}",
                      controller: _controller,
                      imageFit: BoxFit.contain,
                      caption: Text(stories[index].caption ?? ''),
                    )
                  : StoryItem.pageVideo(
                      "${stories[index].videoUrl}",
                      controller: _controller,
                      caption: Text(stories[index].caption ?? ''),
                    );
            }),
            controller: _controller,
            onStoryShow: (storyItem, index) {
              context.read<ViewStoryCubit>().onStoryChanged(stories[index]);

              print("@@@@@@@@@@@@@@ VIEWING STORY NOW");
              final mappedContacts = context
                  .read<ContactsCubit>()
                  .state
                  .mappedContacts;
              if (mappedContacts.containsKey(userId)) {
                print(
                  "##################### THIS ONE OF MINE ##########>>>>>>",
                );
                context.read<StoryCubit>().onViewedStory(userId, index, user);
              }
            },
            onComplete: () {
              if (Platform.isWindows) {
                context.read<SiderManagerCubit>().resetToDefaultPage();
              } else {
                Navigator.pop(context);
              }
            },
            progressPosition: ProgressPosition.top,
            repeat: false,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: BlocBuilder<ViewStoryCubit, ViewStoryState>(
                builder: (context, state) {
                  return IconButton(
                    onPressed: () {
                      _controller.pause();
                      context.read<ViewStoryCubit>().onToggleShowViewers();
                    },
                    icon: Text("${state.currentStory!.views!.length} Views"),
                  );
                },
              ),
            ),
          ),
          BlocBuilder<ViewStoryCubit, ViewStoryState>(
            builder: (context, state) {
              final story = state.currentStory;
              final views = story?.views ?? [];

              if (!state.showViewers) {
                return const SizedBox();
              }

              return Positioned(
                bottom: 0,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.5,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(50),
                      topRight: Radius.circular(50),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      IconButton(
                        onPressed: () {
                          _controller.play();
                          context.read<ViewStoryCubit>().onToggleShowViewers();
                        },
                        icon: const Icon(Icons.cancel_rounded),
                      ),
                      Expanded(
                        child: views.isEmpty
                            ? const Center(child: Text("No views"))
                            : ListView.builder(
                                itemCount: views.length,
                                itemBuilder: (context, index) {
                                  final viewer = views[index];
                                  final contacts = context
                                      .read<ContactsCubit>()
                                      .state
                                      .mappedContacts;
                                  AppUser? userData = contacts[viewer.userId];

                                  userData ??= AppUser(
                                    id: viewer.userId,
                                    name: viewer.userId,
                                    disPlayName: viewer.userId,
                                    phone: viewer.userId,
                                    profilePhoto: '',
                                  );

                                  return ListTile(
                                    leading: CircleAvatar(
                                      child:
                                          (userData.profilePhoto != null &&
                                              userData.profilePhoto!.isNotEmpty)
                                          ? ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(70),
                                              child: Image.network(
                                                userData.profilePhoto!,
                                              ),
                                            )
                                          : Text(
                                              userData.name[0],
                                              style: TextStyle(
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.surface,
                                                fontSize: 22,
                                              ),
                                            ),
                                    ),
                                    title: Text(
                                      userData.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Text(
                                      userData.phone ?? "",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
