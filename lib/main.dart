import 'dart:io';

import 'package:battery/bloc/loading/loading_bloc.dart';
import 'package:battery/bloc/parse_data/parse_data_bloc.dart';
import 'package:battery/bloc/service/service_bloc.dart';
import 'package:battery/bloc/tab/tab_service_bloc.dart';
import 'package:battery/utils/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

void main() async {
  var path = Directory.current.path;
   Hive.init(path);
  runApp(MultiBlocProvider(providers: [
    BlocProvider<TabServiceBloc>(
        create: (BuildContext context) => TabServiceBloc()),
    BlocProvider<ServiceBloc>(create: (BuildContext context) => ServiceBloc()),
    BlocProvider<ParseDataBloc>(
        create: (BuildContext context) => ParseDataBloc()),
        BlocProvider<LoadingBloc>(create: (BuildContext context) => LoadingBloc())
  ], child: const MyApp()));
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
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
    );
  }
}
