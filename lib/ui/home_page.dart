import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:simple_notification/model/received_notification.dart';
import 'package:simple_notification/ui/detail_page.dart';
import 'package:simple_notification/main.dart';
import 'package:simple_notification/utils/notification_helper.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Click handling on notification
  void _configureSelectNotificationSubject() {
    print('Rifa --> Select');
    selectNotificationSubject.stream.listen((String payload) async {
      await Navigator.pushNamed(context, DetailPage.routeName,
          arguments: Arguments(payload));
    });
  }

  void _configureDidReceiveLocalNotificationSubject() {
    print('Rifa --> Did Receive');
    didReceiveLocalNotificationSubject.stream
        .listen((ReceivedNotification receivedNotification) async {
      await showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: receivedNotification.title != null
              ? Text(receivedNotification.title)
              : null,
          content: receivedNotification.body != null
              ? Text(receivedNotification.body)
              : null,
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              child: Text('Ok'),
              onPressed: () async {
                Navigator.of(context, rootNavigator: true).pop();
                await Navigator.pushNamed(context, DetailPage.routeName,
                    arguments: Arguments(receivedNotification.title));
              },
            )
          ],
        ),
      );
    });
  }

  @override
  void initState() {
    super.initState();
    _configureDidReceiveLocalNotificationSubject();
    _configureSelectNotificationSubject();
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
