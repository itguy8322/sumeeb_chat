import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sumeeb_chat/data/cubits/basic-info/basic_info_cubit.dart';
import 'package:sumeeb_chat/data/cubits/basic-info/basic_info_state.dart';
import 'package:sumeeb_chat/data/cubits/sidebar-manager/sider_manager_cubit.dart';
import 'package:sumeeb_chat/data/cubits/user-cubit/user_cubit.dart';
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
    context.read<BasicInfoCubit>().reset();
    if (isMe) {
      context.read<BasicInfoCubit>().onSetName(user.name);
    }
    return isMe
        ? Scaffold(
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
            body: BlocBuilder<BasicInfoCubit, BasicInfoState>(
              builder: (context, info) {
                if (info.loadingSuccess) {
                  context.read<UserCubit>().loadUser(user.id);
                }
                return Stack(
                  children: [
                    BlocListener<BasicInfoCubit, BasicInfoState>(
                      listener: (context, state) {
                        if (state.uploadingPhotonFailure) {
                          showTopSnackBar(
                            Overlay.of(context),
                            CustomSnackBar.error(
                              message: "Failed to upload photo",
                            ),
                          );
                        } else if (state.loadingSuccess) {
                          showTopSnackBar(
                            Overlay.of(context),
                            CustomSnackBar.success(
                              message: "Photo updated successfully",
                            ),
                          );
                          context.read<UserCubit>().loadUser(user.id);
                        }
                      },
                      child: SizedBox(),
                    ),
                    Center(
                      child: user.profilePhoto == null
                          ? info.profilePhoto == null
                                ? Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: MediaQuery.of(context).size.width,
                                    color: Colors.white,
                                    child: Icon(
                                      Icons.person,
                                      size: 110,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.surface,
                                    ),
                                  )
                                : Image.network(info.profilePhoto!)
                          : Image.network(user.profilePhoto!),
                    ),
                    info.uploadingPhotonInProgress || info.loadingInProgress
                        ? Center(child: CircularProgressIndicator())
                        : SizedBox(),
                    Positioned(
                      bottom: 30,
                      right: 0,
                      left: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber,
                              fixedSize: Size.fromWidth(
                                MediaQuery.of(context).size.width * 0.38,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),

                            onPressed: () {
                              context.read<BasicInfoCubit>().removeProfilePhoto(
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
                            onPressed: () async {
                              if (info.profilePhoto == null) {
                                final pickedFile = await _picker.pickImage(
                                  source: ImageSource.gallery,
                                );
                                if (pickedFile != null) {
                                  (pickedFile.path);
                                  context
                                      .read<BasicInfoCubit>()
                                      .setProfilePhoto(pickedFile.path);
                                }
                              } else {
                                print(
                                  "############### CHANGING ##############",
                                );
                                context.read<BasicInfoCubit>().uploadBasicInfo(
                                  user.id,
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber,
                              fixedSize: Size.fromWidth(
                                MediaQuery.of(context).size.width * 0.38,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            label: Text(
                              info.profilePhoto == null
                                  ? "Change photo"
                                  : "Save Photo",
                              style: TextStyle(color: Colors.black),
                            ),
                            icon: Icon(Icons.image, color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          )
        : Scaffold(
            appBar: AppBar(
              leading: IconButton(
                onPressed: () => Navigator.pop(context),
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
    ;
  }
}
