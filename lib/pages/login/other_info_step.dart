import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sumeeb_chat/data/cubits/chat-connection/chat_connection_cubit.dart';
import 'package:sumeeb_chat/data/cubits/storage/storage_cubit.dart';
import 'package:sumeeb_chat/data/cubits/user-cubit/user_cubit.dart';
import 'package:sumeeb_chat/data/cubits/user-cubit/user_state.dart';
import 'package:sumeeb_chat/data/models/user/user_model.dart';
import 'package:sumeeb_chat/pages/home/home_page.dart';
import 'package:sumeeb_chat/services/stream_service.dart';
import 'package:image_picker/image_picker.dart';

class OtherInfoStep extends StatelessWidget {
  // OtherInfoStep({super.key, required this.currentUser});
  final name = TextEditingController();
  final photoUrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  final streamService = StreamService();

  OtherInfoStep({super.key});

  Future<void> _ensureStreamConnected(BuildContext context) async {
    final user = context.read<UserCubit>().state.user!;
    print("=============== SPLASH SCREEN @ @ CONNECTING USER: ${user.id}");
    try {
      await streamService.connectUser(formatUserId(user.id), user.name);
    } catch (e) {
      // handle
      print('Stream connect error: $e');
    }
  }

  String formatUserId(String phoneNumber) {
    // remove '+' and any non-allowed characters
    return phoneNumber.replaceAll(RegExp(r'[^a-z0-9@_-]'), '');
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserCubit, UserState>(
      builder: (context, state) {
        if (state.user!.name.isNotEmpty) {
          name.text = state.user!.name;
        }

        return Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Form(
              key: _formKey,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 2,
                      children: [
                        MultiBlocListener(
                          listeners: [
                            BlocListener<UserCubit, UserState>(
                              listener: (context, user) {
                                ////print(state);

                                if (user.uploadingSuccess) {
                                  _ensureStreamConnected(context);
                                  context
                                      .read<ChatConnectionCubit>()
                                      .setStreamService(streamService);
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => HomePage(
                                        streamService: streamService,
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height * 0.12,
                          ),
                        ),
                        Text("Profile Info", style: TextStyle(fontSize: 24)),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.02,
                        ),
                        Text(
                          "Please provide your name and optional\nprofile photo",
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.08,
                        ),
                        InkWell(
                          onTap: state.uploadingInProgress
                              ? null
                              : () async {
                                  final pickedFile = await _picker.pickImage(
                                    source: ImageSource.gallery,
                                  );
                                  if (pickedFile != null) {
                                    context
                                        .read<UserCubit>()
                                        .setProfilePhotoUrl(pickedFile.path);
                                  }
                                },
                          child: Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(shape: BoxShape.circle),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 70,
                                  child: state.newProfilePhotoUrl.isNotEmpty
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            70,
                                          ),
                                          child: Image.file(
                                            File(state.newProfilePhotoUrl),
                                          ),
                                        )
                                      : state.user!.profilePhoto != null
                                      ? state.user!.profilePhoto!.isNotEmpty
                                            ? ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(70),
                                                child: Image.network(
                                                  state.user!.profilePhoto!,
                                                ),
                                              )
                                            : Icon(
                                                Icons.person,
                                                size: 110,
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.surface,
                                              )
                                      : Icon(
                                          Icons.person,
                                          size: 110,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.surface,
                                        ),
                                ),
                                Positioned(
                                  bottom: 2,
                                  right: 2,
                                  child: Container(
                                    padding: EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                    ),
                                    child: Icon(
                                      Icons.add_circle,
                                      size: 30,
                                      color: Colors.amber,
                                    ),
                                  ),
                                ),
                                state.uploadingInProgress
                                    ? Center(child: CircularProgressIndicator())
                                    : SizedBox(),
                              ],
                            ),
                          ),
                        ),

                        // CircleAvatar(
                        //   radius: 80,
                        //   child: Stack(
                        //     children: [

                        //       Positioned(bottom: 0, right: 0, child: Icon(Icons.image)),
                        //     ],
                        //   ),
                        // ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.02,
                        ),
                        TextFormField(
                          controller: name,
                          decoration: InputDecoration(
                            hintText: "Name/Nickname",
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Name required";
                            }
                            return null;
                          },
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.3,
                        ),
                        BlocBuilder<UserCubit, UserState>(
                          builder: (context, info) {
                            return ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber,
                                fixedSize: Size.fromWidth(
                                  MediaQuery.of(context).size.width,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: info.uploadingInProgress
                                  ? null
                                  : () {
                                      if (!_formKey.currentState!.validate()) {
                                        return;
                                      }
                                      context.read<StorageCubit>().setName(
                                        state.user!.id,
                                        name.text,
                                      );
                                      context.read<UserCubit>().uploadBasicInfo(
                                        state.user!.id,
                                        name.text,
                                      );
                                    },
                              child: info.uploadingInProgress
                                  ? CircularProgressIndicator()
                                  : Text(
                                      "Next",
                                      style: TextStyle(color: Colors.black),
                                    ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
