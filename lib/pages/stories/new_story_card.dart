import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sumeeb_chat/data/models/story-model/story_model.dart';
import 'package:sumeeb_chat/data/models/user/user_model.dart';
import 'package:sumeeb_chat/pages/stories/generate_thumbnail.dart';
import 'package:sumeeb_chat/styles/story_colors.dart';

class NewStoryCard extends StatelessWidget {
  final bool isCurrentUser;
  final AppUser user;
  final StoryModel? story;
  const NewStoryCard({
    super.key,
    this.isCurrentUser = false,
    required this.user,
    this.story,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 210,
      width: 150,
      decoration: BoxDecoration(
        color: story != null
            ? story!.type == 'text'
                  ? storyColors[story!.color]
                  : Color.fromARGB(255, 7, 0, 41)
            : Color.fromARGB(255, 7, 0, 41),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        children: [
          isCurrentUser
              ? Center(child: Text("Add New Story"))
              : story != null
              ? story!.type == 'text'
                    ? Center(child: Text("${story!.text}"))
                    : story!.type == 'photo'
                    ? Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            story!.photoUrl!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    : FutureBuilder<File?>(
                        future: generateThumbnail(story!.videoUrl!),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child: const CircularProgressIndicator(),
                            );
                          }
                          if (snapshot.hasData && snapshot.data != null) {
                            return Positioned.fill(
                              child: Image.file(snapshot.data!),
                            );
                          }
                          return const Icon(Icons.videocam);
                        },
                      )
              : SizedBox(),
          Positioned(
            top: 10,
            left: 10,
            child: CircleAvatar(
              radius: 25,
              backgroundColor: Colors.amber,
              child: Padding(
                padding: EdgeInsets.all(4.0),
                child: user.profilePhoto != null
                    ? user.profilePhoto!.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(70),
                              child: Image.network(user.profilePhoto!),
                            )
                          : Text(
                              user.name[0],
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.surface,
                                fontSize: 22,
                              ),
                            )
                    : Text(
                        user.name[0],
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.surface,
                          fontSize: 22,
                        ),
                      ),
              ),
            ),
          ),
          story != null
              ? story!.type == 'video'
                    ? Positioned(
                        top: 0,
                        right: 0,
                        left: 0,
                        bottom: 0,
                        child: Icon(Icons.play_circle_outline, size: 40),
                      )
                    : SizedBox()
              : SizedBox(),
        ],
      ),
    );
  }
}
