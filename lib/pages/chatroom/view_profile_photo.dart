import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sumeeb_chat/data/cubits/sidebar-manager/sider_manager_cubit.dart';
import 'package:sumeeb_chat/data/cubits/user-cubit/user_cubit.dart';
import 'package:sumeeb_chat/data/cubits/user-cubit/user_state.dart';
import 'package:sumeeb_chat/data/models/user/user_model.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class ViewProfilePhoto extends StatelessWidget {
  final AppUser user;
  final bool isMe;
  ViewProfilePhoto({super.key, required this.user, required this.isMe});
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return isMe
        ? Scaffold(
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
              title: Text(user.name),
            ),
            body: BlocBuilder<UserCubit, UserState>(
              builder: (context, info) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Stack(
                      children: [
                        BlocListener<UserCubit, UserState>(
                          listener: (context, state) {
                            if (state.uploadingFailure) {
                              showTopSnackBar(
                                Overlay.of(context),
                                CustomSnackBar.error(
                                  message: "Failed to upload photo",
                                ),
                              );
                            } else if (state.uploadingSuccess) {
                              showTopSnackBar(
                                Overlay.of(context),
                                CustomSnackBar.success(
                                  message: "Photo updated successfully",
                                ),
                              );
                            }
                          },
                          child: SizedBox(),
                        ),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 420),
                          child: Center(
                            child: info.newProfilePhotoUrl.isNotEmpty
                                ? Image.file(File(info.newProfilePhotoUrl))
                                : info.user!.profilePhoto == null ||
                                      info.user!.profilePhoto!.isEmpty
                                ? Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: 420,
                                    color: Colors.white,
                                    child: Icon(
                                      Icons.person,
                                      size: 110,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.surface,
                                    ),
                                  )
                                : Image.network(info.user!.profilePhoto!),
                            // : Image.network(user.profilePhoto!),
                          ),
                        ),
                        info.uploadingInProgress
                            ? Positioned(
                                top: 0,
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            : SizedBox(),
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 20,
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                            maximumSize: Size.fromWidth(200),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),

                          onPressed: info.uploadingInProgress
                              ? null
                              : () {
                                  context.read<UserCubit>().removeProfilePhoto(
                                    user.id,
                                  );
                                },
                          label: Text(
                            "Remove",
                            style: TextStyle(color: Colors.black),
                          ),
                          icon: Icon(Icons.cancel, color: Colors.black),
                        ),

                        ElevatedButton.icon(
                          onPressed: info.uploadingInProgress
                              ? null
                              : () async {
                                  if (info.newProfilePhotoUrl.isEmpty) {
                                    final pickedFile = await _picker.pickImage(
                                      source: ImageSource.gallery,
                                    );
                                    if (pickedFile != null) {
                                      (pickedFile.path);
                                      context
                                          .read<UserCubit>()
                                          .setProfilePhotoUrl(pickedFile.path);
                                    }
                                  } else {
                                    print(
                                      "############### CHANGING ##############",
                                    );
                                    context
                                        .read<UserCubit>()
                                        .uploadProfilePhoto();
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                            maximumSize: Size.fromWidth(200),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          label: Text(
                            info.newProfilePhotoUrl.isEmpty
                                ? "Change photo"
                                : "Save Photo",
                            style: TextStyle(color: Colors.black),
                          ),
                          icon: Icon(Icons.image, color: Colors.black),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          )
        : Scaffold(
            appBar: AppBar(
              leading: IconButton(
                onPressed: () {
                  if (Platform.isWindows) {
                    context.read<SiderManagerCubit>().onViewChatroomPage();
                  } else {
                    Navigator.pop(context);
                  }
                },
                icon: Icon(Icons.arrow_back_ios),
              ),
              title: Text(user.name),
            ),
            body: Center(
              child: user.profilePhoto != null
                  ? Image.network(user.profilePhoto!)
                  : Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.width,
                      color: Colors.white,
                      child: Icon(
                        Icons.person,
                        size: 110,
                        color: Theme.of(context).colorScheme.surface,
                      ),
                    ),
            ),
          );
  }
}
