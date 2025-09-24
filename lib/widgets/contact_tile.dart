import 'package:flutter/material.dart';
import '../data/models/user/user_model.dart';

class ContactTile extends StatelessWidget {
  final AppUser user;
  final void Function(AppUser) onTap;
  const ContactTile({super.key, required this.user, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
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
      title: Text(user.disPlayName.isNotEmpty ? user.disPlayName : user.name),
      subtitle: Text(user.phone ?? ''),
      onTap: () => onTap(user),
    );
  }
}
