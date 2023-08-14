// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'package:battery/bloc/loading/loading_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../bloc/loading/loading_bloc.dart';

String convertUUID(String data) {
  return '0x${data.toUpperCase().substring(4, 8)}';
}

DialogBox(
    {required BuildContext context,
    required String Title,
    required Widget widget}) {
  return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return SimpleDialog(
            // key: key,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            backgroundColor: Colors.blueAccent,
            children: <Widget>[
              Center(
                child: Column(children: [
                  const SizedBox(
                    height: 15,
                  ),
                  const CircularProgressIndicator(color: Colors.white),
                  const SizedBox(
                    height: 40,
                  ),
                  Text(
                    Title,
                    style: const TextStyle(color: Colors.white),
                  )
                ]),
              )
            ]);
      });
}
