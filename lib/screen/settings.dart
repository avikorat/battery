import 'dart:convert';
import 'dart:math';

import 'package:battery/bloc/loading/loading_bloc.dart';
import 'package:battery/bloc/loading/loading_event.dart';
import 'package:battery/screen/setup.dart';
import 'package:battery/utils/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:hive/hive.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("Settings", style: TextStyle(color: Colors.white)),
          centerTitle: true),
      backgroundColor: Color.fromARGB(96, 228, 227, 227),
      body: BlocBuilder<LoadingBloc, bool>(
        builder: (context, state) => state
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Column(
                children: [
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () async {
                        context.read<LoadingBloc>().add(Loading(true));
                        var box = await Hive.openBox(SETUP);
                        if (box.isNotEmpty) {
                          var data = box.get(SETUP);
                          print(data);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Setup(data: data),
                              ));
                          context.read<LoadingBloc>().add(Loading(false));
                        } else {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Setup(data: []),
                              ));
                          context.read<LoadingBloc>().add(Loading(false));
                        }
                      },
                      child: const Material(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                        elevation: 10,
                        child: ListTile(
                          title: Text("Setup"),
                        ),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Material(
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                      elevation: 10,
                      child: ListTile(
                        title: Text("Utilities"),
                      ),
                    ),
                  )
                ],
              ),
      ),
    );
  }
}
