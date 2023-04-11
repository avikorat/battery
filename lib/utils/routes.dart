import 'package:battery/screen/bluetooth_off_screen.dart';
import 'package:battery/screen/home_screen.dart';
import 'package:battery/screen/main_screen.dart';
import 'package:battery/screen/settings.dart';
import 'package:battery/screen/setup.dart';
import 'package:flutter/material.dart';

var customRoutes = <String, WidgetBuilder>{
  '/': (context) => HomeScreen(),
  '/bluetooth': (context) => BluetoothOffScreen(),
  '/settings': (context) => Settings(),
  '/mainScreen': (context) => MainScreen(),
  '/setup': (context) => Setup(data: []),
};
