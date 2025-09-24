import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sumeeb_chat/pages/settings/notifications/bloc/notification_cubit.dart';
import 'package:sumeeb_chat/pages/settings/settings.dart';
// import 'package:yieldex_monitoring_app/features/settings/notifications/bloc/notification_cubit.dart';
// import 'package:yieldex_monitoring_app/features/settings/settings.dart';

class NotificationPermissionAccess extends StatelessWidget {
  const NotificationPermissionAccess({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationsPreferenceCubit, bool>(
      builder: (context, isNotificationsOn) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle('Notification'),
            ListTile(
              title: const Text('Allow notifications'),
              trailing: Checkbox(
                onChanged: (val) {
                  context
                      .read<NotificationsPreferenceCubit>()
                      .toggleNotification(val!);
                },
                value: isNotificationsOn,
              ),
            ),
            ListTile(
              title: const Text('Turn off notifications'),
              trailing: Checkbox(
                onChanged: (val) {
                  context
                      .read<NotificationsPreferenceCubit>()
                      .toggleNotification(!val!);
                },
                value: !isNotificationsOn,
              ),
            ),
          ],
        );
      },
    );
  }
}
