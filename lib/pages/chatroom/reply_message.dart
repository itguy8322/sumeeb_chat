import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:sumeeb_chat/data/cubits/contacts-cubit/contacts_cubit.dart';
import 'package:sumeeb_chat/data/models/user/user_model.dart';

class ReplyMessage extends StatelessWidget {
  final Map<String, dynamic> replyTo;
  final User currentUser;
  const ReplyMessage({
    super.key,
    required this.currentUser,
    required this.replyTo,
  });

  @override
  Widget build(BuildContext context) {
    final contacts = context.read<ContactsCubit>().state.mappedContacts;
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color.fromARGB(201, 238, 238, 238),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 3, height: 40, color: Colors.blueAccent),
          const SizedBox(width: 2),
          replyTo['attachments'] != null && replyTo['attachments'].isNotEmpty
              ? replyTo['type'] == 'image'
                    ? ClipRRect(
                        borderRadius: BorderRadiusGeometry.circular(12),
                        child: Image.network(
                          width: 50,
                          height: 50,
                          replyTo['attachments'][0],
                        ),
                      )
                    : replyTo['type'] == 'video'
                    ? Icon(
                        Icons.camera,
                        size: 40,
                        color: Theme.of(context).colorScheme.surface,
                      )
                    : replyTo['type'] == 'audio'
                    ? Icon(
                        Icons.mic,
                        size: 40,
                        color: Theme.of(context).colorScheme.surface,
                      )
                    : Icon(
                        Icons.insert_drive_file,
                        size: 40,
                        color: Theme.of(context).colorScheme.surface,
                      )
              : SizedBox(),
          SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${replyTo["user"]}" == currentUser.id
                    ? "You"
                    : contacts["+${replyTo["user"].toString()}"]!.disPlayName ??
                          contacts["+${replyTo["user"].toString()}"]!.name ??
                          "+${replyTo["user"].toString()}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
              Text(
                replyTo["text"].isNotEmpty ? replyTo["text"] : '[Attachment]',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
