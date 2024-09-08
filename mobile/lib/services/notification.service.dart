import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:toucant/constants/context.dart';
import 'package:go_router/go_router.dart';
import 'package:toucant/extensions/build_context_extensions.dart';

class NotificationService {
  /// Use this method to detect when a new notification or a schedule is created
  @pragma("vm:entry-point")
  static Future<void> onNotificationCreatedMethod(ReceivedNotification receivedNotification) async {
    // Your code goes here
  }

  /// Use this method to detect every time that a new notification is displayed
  @pragma("vm:entry-point")
  static Future<void> onNotificationDisplayedMethod(ReceivedNotification receivedNotification) async {
    await AwesomeNotifications().incrementGlobalBadgeCounter();
  }

  /// Use this method to detect if the user dismissed a notification
  @pragma("vm:entry-point")
  static Future<void> onDismissActionReceivedMethod(ReceivedAction receivedAction) async {
    // Your code goes here
  }

  /// Use this method to detect when the user taps on a notification or action button
  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(ReceivedAction receivedAction) async {
    await AwesomeNotifications().decrementGlobalBadgeCounter();
    kNavigatorKey.currentContext?.replace("/");
  }

  /// Creates a scheduled notification that should be run daily at 10:00 AM
  Future<bool> createScheduledNotifications(BuildContext context) async {
    // Check if permission is granted
    if (!await AwesomeNotifications().isNotificationAllowed()) {
      final res = await AwesomeNotifications().requestPermissionToSendNotifications();
      if (!res) return false;
    }
    if (!context.mounted) return false;
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 10,
        channelKey: 'basic_channel',
        category: NotificationCategory.Reminder,
        title: "${context.l10n.notifications_new_content} ${Emojis.animals_parrot}",
        body: context.l10n.notifications_new_content_description,
      ),
      schedule: NotificationAndroidCrontab.daily(referenceDateTime: DateTime(2024, 1, 1, 12, 0, 0)),
    );
    return true;
  }

  void removeScheduledNotifications() async {
    await AwesomeNotifications().cancelSchedule(10);
    debugPrint('Scheduled notifications removed');
  }
}
