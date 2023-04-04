import 'package:battery/screen/setup.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Settings")),
      body: Column(
        children:  [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => Setup(),));
              },
              child: Material(
                borderRadius: BorderRadius.all(Radius.circular(5)),
                elevation: 10,
                child: ListTile(
                  title: Text("Setup"),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
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
    );
  }
}
