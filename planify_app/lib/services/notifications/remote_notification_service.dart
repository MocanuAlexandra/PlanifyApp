import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';

import '../database_helper_service.dart';
import 'package:http/http.dart' as http;
import '../../helpers/app_config.dart' as config;
import 'local_notification_service.dart';

class RemoteNotificationService {
  static void initialize() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  static void setListeners() {
    //Handle the notification coming from firebase messaging
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        LocalNotificationService.createNotificationForSharedUser(notification);
      }
    });
  }

  static Future<bool> sendNotificationAboutNewTaskToUsers(
      String userToken, String taskTitle) async {
    //get the current user email
    String? userEmail = await DBHelper.getCurrentUserEmail();
    String fcmApiKey = config.FCM_API_KEY;

    const postUrl = 'https://fcm.googleapis.com/fcm/send';
    final data = {
      "to": userToken,
      "priority": "high",
      "notification": {
        "title": 'You have a new shared task',
        "body": '''$taskTitle, shared by $userEmail''',
      },
      "data": {"type": "msj"}
    };

    final headers = {
      'content-type': 'application/json',
      'Authorization': 'key=$fcmApiKey'
    };

    final response = await http.post(Uri.parse(postUrl),
        body: json.encode(data),
        encoding: Encoding.getByName('utf-8'),
        headers: headers);

    if (response.statusCode == 200) {
      // on success do sth
      print('test ok push CFM');
      return true;
    } else {
      print(' CFM error');
      // on failure do sth
      return false;
    }
  }

  static Future<bool> sendNotificationAboutEditTaskToUsers(
      String userToken, String taskTitle) async {
    //get the current user email
    String? userEmail = await DBHelper.getCurrentUserEmail();
    String fcmApiKey = config.FCM_API_KEY;

    const postUrl = 'https://fcm.googleapis.com/fcm/send';
    final data = {
      "to": userToken,
      "priority": "high",
      "notification": {
        "title": 'Your shared task has been updated',
        "body": '''$taskTitle, shared by $userEmail''',
      },
      "data": {"type": "msj"}
    };

    final headers = {
      'content-type': 'application/json',
      'Authorization': 'key=$fcmApiKey'
    };

    final response = await http.post(Uri.parse(postUrl),
        body: json.encode(data),
        encoding: Encoding.getByName('utf-8'),
        headers: headers);

    if (response.statusCode == 200) {
      // on success do sth
      print('test ok push CFM');
      return true;
    } else {
      print(' CFM error');
      // on failure do sth
      return false;
    }
  }
}
