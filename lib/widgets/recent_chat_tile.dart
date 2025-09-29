import 'package:flutter/material.dart';
import 'package:sumeeb_chat/data/models/recent-chat/recent_chat.dart';
import '../data/models/user/user_model.dart';

class RecentChatTile extends StatelessWidget {
  final RecentChatModel recentChat;
  final void Function(AppUser) onTap;
  const RecentChatTile({
    super.key,
    required this.recentChat,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    print("MESSAGE COUNT: ${recentChat.messageCount}");
    return ListTile(
      leading: CircleAvatar(
        child: recentChat.user.profilePhoto != null
            ? recentChat.user.profilePhoto!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(70),
                      child: Image.network(recentChat.user.profilePhoto!),
                    )
                  : Text(
                      recentChat.user.name[0],
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.surface,
                      ),
                    )
            : Text(
                recentChat.user.name[0],
                style: TextStyle(
                  color: Theme.of(context).colorScheme.surface,
                  fontSize: 22,
                ),
              ),
      ),
      title: Text(
        recentChat.user.disPlayName.isNotEmpty
            ? recentChat.user.disPlayName
            : recentChat.user.name,
      ),
      subtitle: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            recentChat.status == 'sent'
                ? recentChat.type == 'photo'
                      ? "✔ 🖼️ ${recentChat.message.isEmpty ? 'Photo' : recentChat.message}"
                      : recentChat.type == 'video'
                      ? "✔ 🎬 ${recentChat.message.isEmpty ? 'Video' : recentChat.message}"
                      : recentChat.type == 'file'
                      ? "✔ 📄 ${recentChat.message.isEmpty ? 'File' : recentChat.message}"
                      : recentChat.type == 'audio'
                      ? "✔ 🎙️ ${recentChat.message.isEmpty ? 'Voice note' : recentChat.message}"
                      : "✔ ${recentChat.message}"
                : recentChat.message,
          ),
          Text(recentChat.date.split('.')[0]),
        ],
      ),
      trailing: recentChat.status == 'sent'
          ? SizedBox()
          : recentChat.messageCount != "0"
          ? Container(
              // padding: EdgeInsets.all(1),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.amber,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  recentChat.messageCount,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          : SizedBox(),

      onTap: () => onTap(recentChat.user),
    );
  }
}
