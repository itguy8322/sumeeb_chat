import 'package:flutter/material.dart';
import '../models/user_model.dart';

class ContactTile extends StatelessWidget {
  final AppUser user;
  final void Function(AppUser) onTap;
  const ContactTile({super.key, required this.user, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(child: Text(user.name.isNotEmpty ? user.name[0] : '?')),
      title: Text(user.name),
      subtitle: Text(user.phone ?? ''),
      onTap: () => onTap(user),
    );
  }
}
