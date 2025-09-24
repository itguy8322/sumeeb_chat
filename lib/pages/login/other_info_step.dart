import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sumeeb_chat/data/cubits/basic-info/basic_info_cubit.dart';
import 'package:sumeeb_chat/data/cubits/basic-info/basic_info_state.dart';
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
  late final TextEditingController name;
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  OtherInfoStep({super.key}) {
    name = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserCubit, UserState>(
      builder: (context, state) {
        if (state.user!.name.isNotEmpty) {
          name.text = state.user!.name;
          context.read<BasicInfoCubit>().onSetName(name.text);
        }
        if (state.user!.profilePhoto != null) {
          if (state.user!.profilePhoto!.isNotEmpty) {
            context.read<BasicInfoCubit>().setProfilePhotoUrl(
              state.user!.profilePhoto!,
            );
          }
        }
        print(context.read<BasicInfoCubit>().state.profilePhoto);
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
                            BlocListener<BasicInfoCubit, BasicInfoState>(
                              listener: (context, info) {
                                ////print(state);

                                if (info.loadingSuccess) {
                                  final streamService = StreamService();

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
                        BlocBuilder<BasicInfoCubit, BasicInfoState>(
                          builder: (context, info) {
                            return InkWell(
                              onTap: info.uploadingPhotonInProgress
                                  ? null
                                  : () async {
                                      final pickedFile = await _picker
                                          .pickImage(
                                            source: ImageSource.gallery,
                                          );
                                      if (pickedFile != null) {
                                        (pickedFile.path);
                                        context
                                            .read<BasicInfoCubit>()
                                            .setProfilePhoto(pickedFile.path);
                                      }
                                    },
                              child: Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    CircleAvatar(
                                      radius: 70,
                                      child:
                                          info.profilePhoto!.isNotEmpty ||
                                              info.uploadingPhotonSuccess
                                          ? ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(70),
                                              child: Image.network(
                                                info.profilePhoto!,
                                              ),
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
                                    info.uploadingPhotonInProgress
                                        ? Center(
                                            child: CircularProgressIndicator(),
                                          )
                                        : SizedBox(),
                                  ],
                                ),
                              ),
                            );
                          },
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
                          onChanged: (value) {
                            context.read<BasicInfoCubit>().onSetName(value);
                          },
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.3,
                        ),
                        BlocBuilder<BasicInfoCubit, BasicInfoState>(
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
                              onPressed: info.loadingInProgress
                                  ? null
                                  : () {
                                      if (!_formKey.currentState!.validate()) {
                                        return;
                                      }
                                      context.read<StorageCubit>().setName(
                                        state.user!.id,
                                        name.text,
                                      );
                                      context
                                          .read<BasicInfoCubit>()
                                          .uploadBasicInfo(state.user!.id);
                                    },
                              child: info.loadingInProgress
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
