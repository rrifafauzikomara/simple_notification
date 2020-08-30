import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:simple_notification/ui/detail_page.dart';
import 'package:simple_notification/ui/home_page.dart';
import 'package:simple_notification/utils/notification_helper.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
NotificationAppLaunchDetails notificationAppLaunchDetails;

Future<void> main() async {
  // Needed if you intend to initialize in the `main` function
  WidgetsFlutterBinding.ensureInitialized();

  notificationAppLaunchDetails =
      await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  await NotificationHelper.initNotifications(flutterLocalNotificationsPlugin);
  NotificationHelper.requestIOSPermissions(flutterLocalNotificationsPlugin);

  runApp(
    MaterialApp(
      home: HomePage(),
      routes: {
        DetailPage.routeName: (context) => DetailPage(),
      },
    ),
  );
}
