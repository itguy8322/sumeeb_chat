import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sumeeb_chat/data/cubits/contacts-cubit/contacts_cubit.dart';
import 'package:sumeeb_chat/data/cubits/story-cubit/story_cubit.dart';

class ViewedStoryTile extends StatelessWidget {
  final String userId;
  const ViewedStoryTile({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final user = context.read<ContactsCubit>().state.mappedContacts[userId];
    final stories = context.read<StoryCubit>().state.viewedStories[userId];
    return ListTile(
      leading: CircleAvatar(
        child: user!.profilePhoto != null
            ? user.profilePhoto!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(70),
                      child: Image.network(user.profilePhoto!),
                    )
                  : Text(
                      user.name[0],
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.surface,
                        fontSize: 22,
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
      title: Text(user.name),
      trailing: Text("${stories != null ? stories.length : 1} Stories"),
    );
  }
}
