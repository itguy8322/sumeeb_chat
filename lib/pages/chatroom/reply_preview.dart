import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:sumeeb_chat/data/cubits/contacts-cubit/contacts_cubit.dart';
import 'package:sumeeb_chat/data/models/user/user_model.dart';

class ReplyPreview extends StatelessWidget {
  final AppUser currentUser;
  final Message replyMessage;
  final Function onClose;
  const ReplyPreview({
    super.key,
    required this.currentUser,
    required this.replyMessage,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final contacts = context.read<ContactsCubit>().state.mappedContacts;
    final messageData = replyMessage.extraData as Map<String, dynamic>;
    print(
      "((((((((((((((((((((${messageData['sender_id']}))))))))))))))))))))",
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(18.0, 0, 18, 0),
      child: Container(
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 7, 0, 41),
          borderRadius: BorderRadius.circular(12),
        ),

        child: Row(
          children: [
            replyMessage != null
                ? replyMessage.attachments.isNotEmpty
                      ? replyMessage.attachments[0].type!.rawType == 'image'
                            ? ClipRRect(
                                borderRadius: BorderRadiusGeometry.circular(12),
                                child: Image.network(
                                  width: 50,
                                  height: 50,
                                  replyMessage!.attachments[0].imageUrl!,
                                ),
                              )
                            : replyMessage.attachments[0].type!.rawType ==
                                  'video'
                            ? Icon(Icons.camera, size: 40)
                            : replyMessage.attachments[0].type!.rawType ==
                                  'audio'
                            ? Icon(Icons.mic, size: 40)
                            : Icon(Icons.insert_drive_file, size: 40)
                      : SizedBox()
                : SizedBox(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    messageData['sender_id'] != null
                        ? messageData['sender_id'] == currentUser.id
                              ? "You"
                              : contacts[messageData['sender_id']]!
                                        .disPlayName ??
                                    contacts[messageData['sender_id']]!.name ??
                                    messageData['sender_id']
                        : '',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  replyMessage != null
                      ? Text("${replyMessage!.text}")
                      : SizedBox(),
                ],
              ),
            ),

            Spacer(),
            IconButton(onPressed: () => onClose(), icon: Icon(Icons.cancel)),
          ],
        ),
      ),
    );
  }
}
