// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:isar/isar.dart';
import 'package:sumeeb_chat/data/cubits/story-cubit/story_state.dart';
import 'package:sumeeb_chat/data/isar-models/viewed-story/iviewed_story.dart';
import 'package:sumeeb_chat/data/models/story-model/story_model.dart';
import 'package:sumeeb_chat/data/models/user/user_model.dart';
import 'package:sumeeb_chat/data/repositories/file_upload_repository.dart/file_upload_repository.dart';
import 'package:sumeeb_chat/data/repositories/firestore/firestore_repository.dart';
import 'package:sumeeb_chat/styles/story_colors.dart';

class StoryCubit extends Cubit<StoryState> {
  final FirestoreRepository firestore;
  final FileUploadRepository fileUpload;
  final Isar isar;
  StoryCubit(this.firestore, this.isar, this.fileUpload)
    : super(StoryState.initial());
  reset() {
    emit(state.reset());
  }

  setNewStoryUpdateToTrue() {
    emit(state.copyWith(hasNewStory: true));
  }

  setNewStoryUpdateToFalse() {
    emit(state.copyWith(hasNewStory: false));
  }

  loadStories(List<AppUser> contacts, AppUser currentUSer) async {
    // print("###################### ############### ###########################");
    // print("###################### LOADING STORIES ###########################");
    // print("###################### ############### ###########################");
    Map<String, List<StoryModel>>? _stories = {};
    List<StoryModel> myStories = [];

    emit(
      state.copyWith(
        loadingInProgress: true,
        loadingSuccess: false,
        loadingFailure: false,
        uploadingFailure: false,
        uploadingInProgress: false,
        uploadingSuccess: false,
      ),
    );

    try {
      // 1. Load stories from contacts
      for (AppUser user in contacts) {
        final stories = await firestore.loadStory(user.id);
        if (stories.isNotEmpty) {
          _stories[user.id] = stories;
        }
      }

      // 2. Load current user's stories
      myStories = await firestore.loadStory(currentUSer.id);

      // 3. Load viewed story IDs from Isar
      final viewedStoryIds = await isar.iviewedStorys.where().findAll();
      final storyIds = viewedStoryIds
          .map((id) => id.storyId.toString())
          .toList();

      // 4. Separate stories into viewed and unviewed
      final Map<String, List<StoryModel>> viewedStories =
          Map<String, List<StoryModel>>.from(state.viewedStories);
      final Map<String, List<StoryModel>> updateStories = {};

      _stories.forEach((userId, stories) {
        final unviewed = stories
            .where((story) => !storyIds.contains(story.storyId))
            .toList();

        if (unviewed.isEmpty) {
          viewedStories[userId] = stories; // all viewed
        } else {
          updateStories[userId] = unviewed; // still some unviewed
        }
      });

      // 5. Emit final state
      emit(
        state.copyWith(
          viewedStories: viewedStories,
          myStories: myStories,
          stories: updateStories,
          viewedStoryIds: storyIds,
          loadingInProgress: false,
          loadingSuccess: true,
          loadingFailure: false,
          uploadingFailure: false,
          uploadingInProgress: false,
          uploadingSuccess: false,
        ),
      );
    } catch (e) {
      print("####################### ERROR $e");
      emit(
        state.copyWith(
          loadingInProgress: false,
          loadingSuccess: false,
          loadingFailure: true,
          uploadingFailure: false,
          uploadingInProgress: false,
          uploadingSuccess: false,
        ),
      );
    }
  }

  filterViewedStories(List<String> vd) {
    // print("==========######### FILTERING");
    Map<String, List<StoryModel>> stories = Map<String, List<StoryModel>>.from(
      state.stories,
    );

    Map<String, List<StoryModel>> _stories = Map<String, List<StoryModel>>.from(
      state.stories,
    );

    Map<String, List<StoryModel>> viewedStories =
        Map<String, List<StoryModel>>.from(state.viewedStories);

    _stories.forEach((k, v) {
      List<StoryModel> vd = List<StoryModel>.from(v);
      vd.removeWhere((story) => state.viewedStoryIds!.contains(story.storyId));
      if (vd.isEmpty) {
        print("EMPTY");
        viewedStories[k] = v;
        stories.remove(k);
      }
      // print("==========######### AFTER FILTERING");
      // print(vd);
      // print(viewedStories);
      // print("==========######### AFTER FILTERING");
    });
    emit(
      state.copyWith(
        viewedStoryIds: vd,
        stories: stories,
        viewedStories: viewedStories,
      ),
    );
  }

  onViewedStory(String id, int index, AppUser user) async {
    // print("IDDDDDDDDD $id index: $index");
    List<String> vd = List<String>.from(state.viewedStoryIds!);
    // print(vd);
    // print("IDDDDDDDDD $id ${state.stories}");
    if (state.stories.isNotEmpty) {
      final story = state.stories[id]![index];
      vd.add(story.storyId);
      // print(vd);
      final status = await firestore.addViewToStory(story.storyId, user);
      if (status) {
        // print("####### STATUS: $status ###########");
        final s = IviewedStory(storyId: story.storyId);
        await isar.writeTxn(() async {
          await isar.iviewedStorys.put(s); // insert or update
          // print("============= ADDING HISTORY =============");
        });
      }

      emit(state.copyWith(viewedStoryIds: vd));

      filterViewedStories(vd);
    }
  }

  loadViewedStories() async {}

  onTypeChanged(String type) {
    emit(state.copyWith(type: type));
  }

  onTextChanged(String text) {
    emit(state.copyWith(text: text));
  }

  onCaptionChanged(String text) {
    emit(state.copyWith(caption: text, uploadingSuccess: false));
  }

  onColorChanged() {
    if (state.colorIndex >= storyColors.length - 1) {
      emit(state.copyWith(colorIndex: 0));
    } else {
      final index = state.colorIndex + 1;
      emit(state.copyWith(colorIndex: index));
    }
  }

  uploadPhoto(String path) async {
    emit(
      state.copyWith(
        uploadingInProgress: true,
        uploadingSuccess: false,
        uploadingFailure: false,
      ),
    );
    try {
      final url = await fileUpload.uploadFile(path);
      emit(
        state.copyWith(
          photoUrl: url,
          type: 'photo',
          uploadingInProgress: false,
          uploadingSuccess: true,
          uploadingFailure: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          uploadingInProgress: false,
          uploadingSuccess: false,
          uploadingFailure: true,
        ),
      );
    }
  }

  uploadVideo(String path) async {
    emit(
      state.copyWith(
        uploadingInProgress: true,
        uploadingSuccess: false,
        uploadingFailure: false,
      ),
    );
    try {
      final url = await fileUpload.uploadFile(path);
      emit(
        state.copyWith(
          type: 'video',
          videoUrl: url,
          uploadingInProgress: false,
          uploadingSuccess: true,
          uploadingFailure: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          uploadingInProgress: false,
          uploadingSuccess: false,
          uploadingFailure: true,
        ),
      );
    }
  }

  uploadStory({required AppUser user, String? storyText}) async {
    // debugPrint("############### $storyText #################");
    // debugPrint("############### ########## #################");
    final now = DateTime.now();
    final expiresAt = now.add(Duration(hours: 24));

    final story = {
      "userId": user.id,
      "storyId": "story_${generateUniqueId()}",
      "type": state.type,
      "text": storyText ?? '',
      "color": state.colorIndex,
      "caption": state.caption,
      "photoUrl": state.photoUrl,
      "videoUrl": state.videoUrl,
      "timestamp": FieldValue.serverTimestamp(),
      "expiresAt": expiresAt,
    };
    emit(
      state.copyWith(
        uploadingInProgress: true,
        uploadingSuccess: false,
        uploadingFailure: false,
      ),
    );

    try {
      await firestore.uploadStory('stories', story);
      emit(
        state.copyWith(
          uploadingInProgress: false,
          uploadingSuccess: true,
          uploadingFailure: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          uploadingInProgress: false,
          uploadingSuccess: false,
          uploadingFailure: true,
        ),
      );
    }
  }

  onToggleShowViews() {
    emit(state.copyWith(showViews: !state.showViews));
  }
}

String generateUniqueId() {
  // final timestamp = DateTime.now().millisecondsSinceEpoch;
  final random = Random().nextInt(99999); // up to 6 digits
  return "$random";
}
