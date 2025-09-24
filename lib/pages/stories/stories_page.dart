import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sumeeb_chat/data/cubits/contacts-cubit/contacts_cubit.dart';
import 'package:sumeeb_chat/data/cubits/sidebar-manager/sidebar_manager_state.dart';
import 'package:sumeeb_chat/data/cubits/sidebar-manager/sider_manager_cubit.dart';
import 'package:sumeeb_chat/data/cubits/story-cubit/story_cubit.dart';
import 'package:sumeeb_chat/data/cubits/story-cubit/story_state.dart';
import 'package:sumeeb_chat/data/cubits/user-cubit/user_cubit.dart';
import 'package:sumeeb_chat/data/cubits/user-cubit/user_state.dart';
import 'package:sumeeb_chat/data/models/story-model/story_model.dart';
import 'package:sumeeb_chat/data/models/story-model/story_views_model.dart';
import 'package:sumeeb_chat/data/models/user/user_model.dart';
import 'package:sumeeb_chat/pages/stories/media_story_form.dart';
import 'package:sumeeb_chat/pages/stories/new_story_card.dart';
import 'package:sumeeb_chat/pages/stories/text_story_form.dart';
import 'package:sumeeb_chat/pages/stories/view_story_page.dart';
import 'package:sumeeb_chat/pages/stories/viewed_story_tile.dart';

class StoriesPage extends StatelessWidget {
  const StoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserCubit, UserState>(
      builder: (context, appUser) {
        final user = appUser.user!;
        return Scaffold(
          appBar: AppBar(
            leading: SizedBox(),
            leadingWidth: 0,
            title: Text("Stories"),
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BlocBuilder<StoryCubit, StoryState>(
                    builder: (context, story) {
                      final myStories = story.myStories;
                      // if (story.uploadingSuccess) {
                      //   final contacts = context
                      //       .read<ContactsCubit>()
                      //       .state
                      //       .contacts;
                      //   context.read<StoryCubit>().loadStories(contacts, user);
                      // }
                      int totalViews = 0;
                      print(
                        "#############   ############# STORIES ${myStories!.length}",
                      );
                      for (final story in myStories) {
                        print(
                          "#############   ############# VIEWS ${story.views!.length}",
                        );
                        totalViews += story.views!.length;
                      }

                      return ListTile(
                        onTap: () {
                          if (myStories != null && myStories.isNotEmpty) {
                            if (Platform.isWindows) {
                              context
                                  .read<SiderManagerCubit>()
                                  .onViewStatusPage(user, user.id, myStories);
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ViewStoryPage(
                                    user: user,
                                    userId: user.id,
                                    stories: myStories,
                                  ),
                                ),
                              );
                            }
                          }
                        },
                        leading: CircleAvatar(
                          child: user.profilePhoto != null
                              ? user.profilePhoto!.isNotEmpty
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(70),
                                        child: Image.network(
                                          user.profilePhoto!,
                                        ),
                                      )
                                    : Text(
                                        user.name[0],
                                        style: TextStyle(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.surface,
                                          fontSize: 22,
                                        ),
                                      )
                              : Text(
                                  user.name[0],
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.surface,
                                    fontSize: 22,
                                  ),
                                ),
                        ),
                        title: Text(user.name),
                        subtitle: Text(
                          "${myStories.length} stories - $totalViews views",
                        ),
                        trailing: story.uploadingInProgress
                            ? CircularProgressIndicator()
                            : IconButton(
                                onPressed: () {
                                  if (Platform.isWindows) {
                                    context
                                        .read<SiderManagerCubit>()
                                        .onViewTextStoryPage(user);
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            TextStoryForm(user: user),
                                      ),
                                    );
                                  }
                                },
                                icon: Icon(Icons.edit),
                              ),
                      );
                    },
                  ),
                  // BlocBuilder<StoryCubit, StoryState>(
                  //   builder: (context, state) {
                  //     if (state.showViews) {
                  //       if (state.myStories != null) {
                  //         if (state.myStories!.isEmpty) {
                  //           return SizedBox();
                  //         } else {
                  //           return SingleChildScrollView(
                  //             child: Column(
                  //               children: List.generate(
                  //                 state.myStories!.length,
                  //                 (index) => ListTile(
                  //                   title: Text(
                  //                     "${state.myStories![index].views!.length}",
                  //                   ),
                  //                 ),
                  //               ),
                  //             ),
                  //           );
                  //         }
                  //       } else {
                  //         return SizedBox();
                  //       }
                  //     } else {
                  //       return SizedBox();
                  //     }
                  //   },
                  // ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: BlocBuilder<StoryCubit, StoryState>(
                        builder: (context, s) {
                          final stories = Map<String, List<StoryModel>>.from(
                            s.stories,
                          );
                          // stories.remove(user.id);
                          final mappedContacts = context
                              .read<ContactsCubit>()
                              .state
                              .mappedContacts;
                          print("#############============ $mappedContacts");
                          return s.loadingInProgress
                              ? CircularProgressIndicator()
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  spacing: 10,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        if (Platform.isWindows) {
                                          context
                                              .read<SiderManagerCubit>()
                                              .onViewMediaStoryPage(user);
                                        } else {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  MediaStoryForm(user: user),
                                            ),
                                          );
                                        }
                                      },
                                      child: NewStoryCard(
                                        isCurrentUser: true,
                                        user: user,
                                      ),
                                    ),
                                    for (String userId in stories.keys)
                                      (InkWell(
                                        onTap: () {
                                          if (Platform.isWindows) {
                                            context
                                                .read<SiderManagerCubit>()
                                                .onViewStatusPage(
                                                  user,
                                                  userId,
                                                  stories[userId]!,
                                                );
                                          } else {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ViewStoryPage(
                                                      user: user,
                                                      userId: userId,
                                                      stories: stories[userId]!,
                                                    ),
                                              ),
                                            );
                                          }
                                        },
                                        child: NewStoryCard(
                                          user: mappedContacts[userId]!,
                                          story: stories[userId]![0],
                                        ),
                                      )),
                                    // NewStoryCard(),
                                    // NewStoryCard(),
                                    // NewStoryCard(),
                                  ],
                                );
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 5),
                  Text("Viewed"),
                  Divider(),
                  SingleChildScrollView(
                    child: BlocBuilder<StoryCubit, StoryState>(
                      builder: (context, state) {
                        // final viewedStories = state.viewedStories;
                        final viewedStories =
                            Map<String, List<StoryModel>>.from(
                              state.viewedStories,
                            );
                        viewedStories.remove(user.id);
                        final mappedContacts = context
                            .read<ContactsCubit>()
                            .state
                            .mappedContacts;
                        print(viewedStories);
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            viewedStories.isEmpty
                                ? Center(child: Text("No Viewed"))
                                : SizedBox(),
                            for (String userId in viewedStories.keys)
                              (InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ViewStoryPage(
                                        user: user,
                                        userId: userId,
                                        stories: viewedStories[userId]!,
                                      ),
                                    ),
                                  );
                                },
                                child: ViewedStoryTile(userId: userId),
                              )),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
