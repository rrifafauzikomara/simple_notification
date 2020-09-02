import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:simple_notification/ui/detail_page.dart';
import 'package:simple_notification/ui/home_page.dart';
import 'package:simple_notification/utils/notification_helper.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
