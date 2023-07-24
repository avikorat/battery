import 'dart:io';

import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:battery/bloc/charastric/charasterics_bloc.dart';
import 'package:battery/bloc/loading/loading_bloc.dart';
import 'package:battery/bloc/parse_data/parse_data_bloc.dart';
import 'package:battery/bloc/service/service_bloc.dart';
import 'package:battery/bloc/setting/setting_bloc.dart';
import 'package:battery/bloc/tab/tab_service_bloc.dart';
import 'package:battery/screen/home_screen.dart';
import 'package:battery/utils/constants.dart';
import 'package:battery/utils/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var appDocumentDirectory = await getApplicationDocumentsDirectory();
  var path = appDocumentDirectory.path;
  Hive.init(path);
  BOX = await Hive.openBox(SETUP);
  await Hive.openBox("configBox");
  runApp(MultiBlocProvider(providers: [
    BlocProvider<TabServiceBloc>(
        create: (BuildContext context) => TabServiceBloc()),
    BlocProvider<ServiceBloc>(create: (BuildContext context) => ServiceBloc()),
    BlocProvider<ParseDataBloc>(
        create: (BuildContext context) => ParseDataBloc()),
    BlocProvider<LoadingBloc>(create: (BuildContext context) => LoadingBloc()),
    BlocProvider<CharastericsBloc>(
        create: (BuildContext context) => CharastericsBloc()),
    BlocProvider<SettingBloc>(create: (BuildContext context) => SettingBloc()),
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
      ),
      debugShowCheckedModeBanner: false,
      home: AnimatedSplashScreen(
        backgroundColor: Colors.white,
        splash: "assets/companyLogo.png",
        nextScreen: HomeScreen(),
        centered: true,
        splashIconSize: 100,
      ),
    );
  }
}
