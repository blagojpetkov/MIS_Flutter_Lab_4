import 'package:flutter/material.dart';
import 'exam.dart';


class User{
  String username;
  String password;
  List<Exam> exams = [];
  User({this.username, this.password});
}