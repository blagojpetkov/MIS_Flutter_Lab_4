import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


import '../Model/exam.dart';
import '../Model/user.dart';
import '../main.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class Auth with ChangeNotifier{
  String username;
  String password;

  User authenticatedUser;

  List<User> existingUsers = [];



  bool get isAuth {
    return username != null && password != null;
  }




  bool signup(String email, String password) {
    
    var filter = existingUsers.where((user) => user.username == email);
    if(!filter.isEmpty) return false;
    
    var user = User(username: email, password: password);

    this.username = email;
    this.password = password;
    this.authenticatedUser = user;

    existingUsers.add(user);
    scheduleNotificationsForLoggedInUser();
    notifyListeners();
    return true;
  }

  bool login(String email, String password) {
      var filter = existingUsers.where((user) => user.username == email);
      User user;
      if(filter.isEmpty) return false;

      user = filter.first;
      if(user.password == password){
        username = email;
        password = password;
        this.authenticatedUser = user;
        scheduleNotificationsForLoggedInUser();
        return true;
      }

      return false;
  }

  
  void logout() {
    username = null;
    password = null;
    authenticatedUser = null;
    notifyListeners();
    cancelAllNotifications();
  }


   void scheduleExamNotification(Exam exam) async {
    var scheduledNotificationDateTime = exam.dateTime.subtract(Duration(minutes: 15));

    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'exam_notification_channel',
      'Exam Notifications',
      channelDescription: 'Notifications for upcoming exams',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
    );
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.schedule(
      Random().nextInt(100000),
      'You have an exam in less than 15 minutes!',
      '${exam.name} will start at ${DateFormat('dd MMM, y HH:mm').format(exam.dateTime)}',
      scheduledNotificationDateTime,
      platformChannelSpecifics,
    );
  }

  void cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }


  void scheduleNotificationsForLoggedInUser() {
    if (authenticatedUser != null) {
      for (var exam in authenticatedUser.exams) {
        scheduleExamNotification(exam);
      }
    }
  }







}
