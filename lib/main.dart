import 'package:battery/bloc/service/service_bloc.dart';
import 'package:battery/bloc/tab/tab_service_bloc.dart';
import 'package:battery/screen/bluetooth_off_screen.dart';
import 'package:battery/screen/home_screen.dart';
import 'package:battery/utils/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

void main() {
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<TabServiceBloc>(
          create: (BuildContext context) => TabServiceBloc()),
        BlocProvider<ServiceBloc>(
          create: (BuildContext context) => ServiceBloc()),
      ],
      child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: customRoutes,
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
      ),
      initialRoute: '/',
    );
  }
}
