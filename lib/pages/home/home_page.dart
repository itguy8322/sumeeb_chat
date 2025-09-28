//
// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'dart:io';
import 'dart:ui';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sumeeb_chat/data/cubits/contacts-cubit/contacts_cubit.dart';
import 'package:sumeeb_chat/data/cubits/contacts-cubit/contacts_state.dart';
import 'package:sumeeb_chat/data/cubits/recent-chats-cubit/recent_chat_cubit.dart';
import 'package:sumeeb_chat/data/cubits/sidebar-manager/sidebar_manager_state.dart';
import 'package:sumeeb_chat/data/cubits/sidebar-manager/sider_manager_cubit.dart';
import 'package:sumeeb_chat/data/cubits/story-cubit/story_cubit.dart';
import 'package:sumeeb_chat/data/cubits/user-cubit/user_cubit.dart';
import 'package:sumeeb_chat/data/cubits/user-cubit/user_state.dart';
import 'package:sumeeb_chat/data/models/user/user_model.dart';
import 'package:sumeeb_chat/pages/chatroom/chatroom_page.dart';
import 'package:sumeeb_chat/pages/chatroom/view_profile_photo.dart';
import 'package:sumeeb_chat/pages/chats/chats.dart';
import 'package:sumeeb_chat/pages/contacts/contacts_page.dart';
import 'package:sumeeb_chat/pages/groups/grroups_page.dart';
import 'package:sumeeb_chat/pages/home/destop_default_page.dart';
import 'package:sumeeb_chat/pages/home/navigation_item.dart';
import 'package:sumeeb_chat/pages/settings/settings.dart';
import 'package:sumeeb_chat/pages/stories/media_story_form.dart';
import 'package:sumeeb_chat/pages/stories/stories_page.dart';
import 'package:sumeeb_chat/pages/stories/text_story_form.dart';
import 'package:sumeeb_chat/pages/stories/view_story_page.dart';
import 'package:sumeeb_chat/services/stream_service.dart';

class HomePage extends StatefulWidget {
  final StreamService streamService;
  const HomePage({super.key, required this.streamService});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int selected = 0;
  bool isListening = false;
  Stream<QuerySnapshot<Map<String, dynamic>>> prepareListenForStoryUpdates(
    List<String> contactIds,
  ) {
    final stream = FirebaseFirestore.instance
        .collection('stories')
        .where(
          'userId',
          whereIn: contactIds,
        ) // 👈 only my contacts// 👈 only new posts
        .snapshots();
    return stream;
  }

  startListening(BuildContext context) {
    final contactIds = context
        .read<ContactsCubit>()
        .state
        .mappedContacts
        .keys
        .toList();
    final stream = prepareListenForStoryUpdates(contactIds);
    setState(() {
      isListening = true;
    });
    stream.listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        // at least one new story from contacts
        context.read<StoryCubit>().setNewStoryUpdateToTrue();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // This will be triggered when app state changes
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      // App is back from minimized (foreground again)
      print("///////////////// App Resumed /////////////////");
      context.read<RecentChatCubit>().getRecentChats();
    } else if (state == AppLifecycleState.paused) {
      // App is minimized (background)
      // _onAppPaused();
    }
  }

  @override
  Widget build(BuildContext context) {
    final contacts = context.read<ContactsCubit>().state.contacts;

    return BlocBuilder<UserCubit, UserState>(
      builder: (context, state) {
        context.read<StoryCubit>().loadStories(contacts, state.user!);
        return BlocListener<ContactsCubit, ContactsState>(
          listener: (context, s) {
            if (s.loadingSuccess && !isListening) {
              startListening(context);
            }
          },
          child: Platform.isWindows
              ? Builder(
                  builder: (context) {
                    return Row(
                      children: [
                        SizedBox(
                          width: 380,
                          child: Stack(
                            children: [
                              Builder(
                                builder: (context) {
                                  if (selected == 0) {
                                    return ChatsPage(
                                      streamService: widget.streamService,
                                    );
                                  } else if (selected == 1) {
                                    // Replace with your actual screen for index 1
                                    return ContactsPage(
                                      streamService: widget.streamService,
                                    );
                                  } else if (selected == 2) {
                                    // Replace with your actual screen for index 2
                                    return StoriesPage();
                                  } else {
                                    return SettingsPage();
                                  }
                                },
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                left: 0,
                                child: BlurBottomNavBar(
                                  currentUser: state.user!,
                                  width: 75,
                                  onSelected: (index) {
                                    setState(() {
                                      selected = index;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: MediaQuery.of(context).size.height,
                          width: 3,
                          color: Colors.amber,
                        ),
                        Expanded(
                          child:
                              BlocBuilder<
                                SiderManagerCubit,
                                SidebarManagerState
                              >(
                                builder: (context, sm) {
                                  if (sm.page == PageType.chatroom) {
                                    return ChatroomPage(
                                      streamService: widget.streamService,
                                    );
                                  } else if (sm.page == PageType.status) {
                                    return ViewStoryPage(
                                      user: sm.user!,
                                      userId: sm.userId,
                                      stories: sm.stories!,
                                    );
                                  } else if (sm.page == PageType.contacts) {
                                    return ContactsPage(
                                      streamService: widget.streamService,
                                    );
                                  } else if (sm.page == PageType.textStory) {
                                    return TextStoryForm(user: sm.user!);
                                  } else if (sm.page == PageType.mediaStory) {
                                    return MediaStoryForm(user: sm.user!);
                                  } else if (sm.page ==
                                      PageType.viewProfilePhoto) {
                                    return ViewProfilePhoto(
                                      user: sm.user!,
                                      isMe: sm.isMe,
                                    );
                                  }
                                  return DesktopDefaultPage();
                                },
                              ),
                        ),
                      ],
                    );
                  },
                )
              : Stack(
                  children: [
                    Builder(
                      builder: (context) {
                        if (selected == 0) {
                          return ChatsPage(streamService: widget.streamService);
                        } else if (selected == 1) {
                          // Replace with your actual screen for index 1
                          return ContactsPage(
                            streamService: widget.streamService,
                          );
                        } else if (selected == 2) {
                          // Replace with your actual screen for index 2
                          return StoriesPage();
                        } else {
                          return SettingsPage();
                        }
                      },
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      left: 0,
                      child: BlurBottomNavBar(
                        currentUser: state.user!,
                        onSelected: (index) {
                          setState(() {
                            selected = index;
                          });
                        },
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

// Action button widget

class BlurBottomNavBar extends StatefulWidget {
  final AppUser currentUser;
  final double? width;
  final Function(int index)? onSelected;
  BlurBottomNavBar({this.onSelected, required this.currentUser, this.width});
  @override
  _BlurBottomNavBarState createState() => _BlurBottomNavBarState();
}

class _BlurBottomNavBarState extends State<BlurBottomNavBar> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    print(index);
    setState(() {
      _selectedIndex = index;
      widget.onSelected!(_selectedIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 25,
        left: 20,
        right: 20,
      ), // lift it above screen edge
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            width: 250, // not full width
            height: 80,
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.surface.withOpacity(0.1), // frosted glass effect
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.3), // subtle border
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                BottomNavigationItem(
                  index: 0,
                  icon: Icons.chat_bubble_outline,
                  footer: "Chats",
                  active: _selectedIndex == 0,
                  width: widget.width,
                  onTap: (currentIndex) {
                    _onItemTapped(currentIndex);
                    context.read<RecentChatCubit>().getRecentChats();
                  },
                ),
                BottomNavigationItem(
                  index: 1,
                  icon: Icons.person_outlined,
                  footer: "Contacts",
                  active: _selectedIndex == 1,
                  width: widget.width,
                  onTap: (currentIndex) => _onItemTapped(currentIndex),
                ),
                BottomNavigationItem(
                  index: 2,
                  icon: Icons.track_changes_outlined,
                  footer: "Stories",
                  active: _selectedIndex == 2,
                  width: widget.width,
                  onTap: (currentIndex) {
                    _onItemTapped(currentIndex);
                    context.read<StoryCubit>().setNewStoryUpdateToFalse();
                    final contacts = context
                        .read<ContactsCubit>()
                        .state
                        .contacts;
                    context.read<StoryCubit>().loadStories(
                      contacts,
                      widget.currentUser,
                    );
                  },
                ),
                BottomNavigationItem(
                  index: 3,
                  icon: Icons.settings_outlined,
                  footer: "Settings",
                  active: _selectedIndex == 3,
                  width: widget.width,
                  onTap: (currentIndex) async {
                    _onItemTapped(currentIndex);
                  },
                ),
                // _buildNavItem('favorite-chart', 2),
                // _buildNavItem('empty-wallet', 3),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
