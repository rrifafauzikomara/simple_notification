import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/subjects.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:simple_notification/utils/received_notification.dart';

final selectNotificationSubject = BehaviorSubject<String>();
final didReceiveLocalNotificationSubject =
    BehaviorSubject<ReceivedNotification>();

class NotificationHelper {
  static Future<void> initNotifications(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    var initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');

    var initializationSettingsIOS = IOSInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
        onDidReceiveLocalNotification:
            (int id, String title, String body, String payload) async {
          didReceiveLocalNotificationSubject.add(ReceivedNotification(
              id: id, title: title, body: body, payload: payload));
        });

    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String payload) async {
      if (payload != null) {
        print('notification payload: ' + payload);
      }
      selectNotificationSubject.add(payload);
    });
  }

  static void requestIOSPermissions(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  static Future<void> showNotification(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        importance: Importance.Max, priority: Priority.High, ticker: 'ticker');

    var iOSPlatformChannelSpecifics = IOSNotificationDetails();

    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        0, 'plain title', 'plain body', platformChannelSpecifics,
        payload: 'plain notification');
  }

  static Future<void> showNotificationWithNoBody(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        importance: Importance.Max, priority: Priority.High, ticker: 'ticker');
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        0, 'plain title', null, platformChannelSpecifics,
        payload: 'item x');
  }

  static Future<void> scheduleNotification(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    var scheduledNotificationDateTime =
        DateTime.now().add(Duration(seconds: 5));
    var vibrationPattern = Int64List(4);
    vibrationPattern[0] = 0;
    vibrationPattern[1] = 1000;
    vibrationPattern[2] = 5000;
    vibrationPattern[3] = 2000;

    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'your other channel id',
        'your other channel name',
        'your other channel description',
        icon: 'secondary_icon',
        sound: RawResourceAndroidNotificationSound('slow_spring_board'),
        largeIcon: DrawableResourceAndroidBitmap('sample_large_icon'),
        vibrationPattern: vibrationPattern,
        enableLights: true,
        color: const Color.fromARGB(255, 255, 0, 0),
        ledColor: const Color.fromARGB(255, 255, 0, 0),
        ledOnMs: 1000,
        ledOffMs: 500);
    var iOSPlatformChannelSpecifics =
        IOSNotificationDetails(sound: 'slow_spring_board.aiff');
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.schedule(
      0,
      'scheduled title',
      'scheduled body',
      scheduledNotificationDateTime,
      platformChannelSpecifics,
      payload: 'scheduled notification',
    );
  }

  static Future<void> showTimeoutNotification(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'silent channel id',
        'silent channel name',
        'silent channel description',
        timeoutAfter: 3000,
        styleInformation: DefaultStyleInformation(true, true));
    var iOSPlatformChannelSpecifics =
        IOSNotificationDetails(presentSound: false);
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(0, 'timeout notification',
        'Times out after 3 seconds', platformChannelSpecifics);
  }

  static Future<void> showGroupedNotifications(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    var groupKey = 'com.android.example.WORK_EMAIL';
    var groupChannelId = 'grouped channel id';
    var groupChannelName = 'grouped channel name';
    var groupChannelDescription = 'grouped channel description';

    var firstNotificationAndroidSpecifics = AndroidNotificationDetails(
        groupChannelId, groupChannelName, groupChannelDescription,
        importance: Importance.Max,
        priority: Priority.High,
        groupKey: groupKey);
    var firstNotificationPlatformSpecifics =
        NotificationDetails(firstNotificationAndroidSpecifics, null);
    await flutterLocalNotificationsPlugin.show(1, 'Alex Faarborg',
        'You will not believe...', firstNotificationPlatformSpecifics);
    var secondNotificationAndroidSpecifics = AndroidNotificationDetails(
        groupChannelId, groupChannelName, groupChannelDescription,
        importance: Importance.Max,
        priority: Priority.High,
        groupKey: groupKey);
    var secondNotificationPlatformSpecifics =
        NotificationDetails(secondNotificationAndroidSpecifics, null);
    await flutterLocalNotificationsPlugin.show(
        2,
        'Jeff Chang',
        'Please join us to celebrate the...',
        secondNotificationPlatformSpecifics);

    var lines = List<String>();
    lines.add('Alex Faarborg  Check this out');
    lines.add('Jeff Chang    Launch Party');
    var inboxStyleInformation = InboxStyleInformation(lines,
        contentTitle: '2 messages', summaryText: 'janedoe@example.com');
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        groupChannelId, groupChannelName, groupChannelDescription,
        styleInformation: inboxStyleInformation,
        groupKey: groupKey,
        setAsGroupSummary: true);
    var platformChannelSpecifics =
        NotificationDetails(androidPlatformChannelSpecifics, null);
    await flutterLocalNotificationsPlugin.show(
        3, 'Attention', 'Two messages', platformChannelSpecifics);
  }

  static Future<void> showProgressNotification(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    var maxProgress = 5;
    for (var i = 0; i <= maxProgress; i++) {
      await Future.delayed(Duration(seconds: 1), () async {
        var androidPlatformChannelSpecifics = AndroidNotificationDetails(
            'progress channel',
            'progress channel',
            'progress channel description',
            channelShowBadge: false,
            importance: Importance.Max,
            priority: Priority.High,
            onlyAlertOnce: true,
            showProgress: true,
            maxProgress: maxProgress,
            progress: i);
        var iOSPlatformChannelSpecifics = IOSNotificationDetails();
        var platformChannelSpecifics = NotificationDetails(
            androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
        await flutterLocalNotificationsPlugin.show(
            0,
            'progress notification title',
            'progress notification body',
            platformChannelSpecifics,
            payload: 'item x');
      });
    }
  }

  static Future<String> _downloadAndSaveFile(
      String url, String fileName) async {
    var directory = await getApplicationDocumentsDirectory();
    var filePath = '${directory.path}/$fileName';
    var response = await http.get(url);
    var file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }

  static Future<void> showBigPictureNotification(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    var largeIconPath = await _downloadAndSaveFile(
        'http://via.placeholder.com/48x48', 'largeIcon');
    var bigPicturePath = await _downloadAndSaveFile(
        'http://via.placeholder.com/400x800', 'bigPicture');
    var bigPictureStyleInformation = BigPictureStyleInformation(
        FilePathAndroidBitmap(bigPicturePath),
        largeIcon: FilePathAndroidBitmap(largeIconPath),
        contentTitle: 'overridden <b>big</b> content title',
        htmlFormatContentTitle: true,
        summaryText: 'summary <i>text</i>',
        htmlFormatSummaryText: true);
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'big text channel id',
        'big text channel name',
        'big text channel description',
        styleInformation: bigPictureStyleInformation);
    var platformChannelSpecifics =
        NotificationDetails(androidPlatformChannelSpecifics, null);
    await flutterLocalNotificationsPlugin.show(
        0, 'big text title', 'silent body', platformChannelSpecifics);
  }

  static Future<void> showNotificationWithAttachment(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    var bigPicturePath = await _downloadAndSaveFile(
        'http://via.placeholder.com/600x200', 'bigPicture.jpg');
    var iOSPlatformChannelSpecifics = IOSNotificationDetails(
        attachments: [IOSNotificationAttachment(bigPicturePath)]);
    var bigPictureAndroidStyle =
        BigPictureStyleInformation(FilePathAndroidBitmap(bigPicturePath));
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        importance: Importance.High,
        priority: Priority.High,
        styleInformation: bigPictureAndroidStyle);
    var notificationDetails = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        0,
        'notification with attachment title',
        'notification with attachment body',
        notificationDetails);
  }

  static Future<void> showInboxNotification(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    var lines = List<String>();
    lines.add('line <b>1</b>');
    lines.add('line <i>2</i>');
    var inboxStyleInformation = InboxStyleInformation(lines,
        htmlFormatLines: true,
        contentTitle: 'overridden <b>inbox</b> context title',
        htmlFormatContentTitle: true,
        summaryText: 'summary <i>text</i>',
        htmlFormatSummaryText: true);
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'inbox channel id', 'inboxchannel name', 'inbox channel description',
        styleInformation: inboxStyleInformation);
    var platformChannelSpecifics =
        NotificationDetails(androidPlatformChannelSpecifics, null);
    await flutterLocalNotificationsPlugin.show(
        0, 'inbox title', 'inbox body', platformChannelSpecifics);
  }

  static Future<void> deleteNotificationChannel(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
      BuildContext context) async {
    const channelId = 'your channel id 2';
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.deleteNotificationChannel(channelId);

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text('Channel with id \"$channelId\" deleted'),
          actions: [
            FlatButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  static Future<void> cancelNotification(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    await flutterLocalNotificationsPlugin.cancel(0);
  }

  static Future<void> cancelAllNotifications(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  static void configureSelectNotificationSubject(
      BuildContext context, String route) {
    selectNotificationSubject.stream.listen((String payload) async {
      await Navigator.pushNamed(context, route,
          arguments: ReceivedNotification(payload: payload));
    });
  }

  static void configureDidReceiveLocalNotificationSubject(
      BuildContext context, String route) {
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
                await Navigator.pushNamed(context, route,
                    arguments: receivedNotification);
              },
            )
          ],
        ),
      );
    });
  }
}
