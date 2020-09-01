import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:simple_notification/ui/detail_page.dart';
import 'package:simple_notification/main.dart';
import 'package:simple_notification/utils/notification_helper.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    NotificationHelper.configureSelectNotificationSubject(
        context, DetailPage.routeName);
    NotificationHelper.configureDidReceiveLocalNotificationSubject(
        context, DetailPage.routeName);
  }

  @override
  void dispose() {
    selectNotificationSubject.close();
    didReceiveLocalNotificationSubject.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Simple Notification'),
        ),
        body: Padding(
          padding: EdgeInsets.all(8.0),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                RaisedButton(
                  child: Text('Show plain notification with payload'),
                  onPressed: () async {
                    await NotificationHelper.showNotification(
                        flutterLocalNotificationsPlugin);
                  },
                ),
                SizedBox(height: 50),
                RaisedButton(
                  child: Text('Show schedule notification with payload'),
                  onPressed: () async {
                    await NotificationHelper.scheduleNotification(
                        flutterLocalNotificationsPlugin);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
