import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../settings.dart';
import 'bloc/dark_mode_cubit.dart';

class DarkThemeSection extends StatelessWidget {
  const DarkThemeSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DarkModeCubit, bool>(
      builder: (context, isDarkModeOn) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle('Dark mode'),
            ListTile(
              leading: Icon(
                Icons.dark_mode,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: const Text('Dark Theme'),
              trailing: Switch(
                  onChanged: (_) =>
                      context.read<DarkModeCubit>().toggleDarkMode(),
                  value: isDarkModeOn),
            ),
            const Divider(),
          ],
        );
      },
    );
  }
}
