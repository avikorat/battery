import 'package:battery/screen/home_screen.dart';
import 'package:battery/screen/main_screen.dart';
import 'package:battery/screen/settings.dart';
import 'package:flutter/material.dart';

var customRoutes = <String, WidgetBuilder>{
  '/home': (context) => HomeScreen(),
  '/settings': (context) => Settings(),
  '/mainScreen': (context) => MainScreen(),
};
