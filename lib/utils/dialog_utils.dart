import 'package:flutter/material.dart';

class DialogUtils {
  static DialogUtils _instance = new DialogUtils.internal();

  DialogUtils.internal();

  factory DialogUtils() => _instance;

  static void showCustomDialog(
    BuildContext context, {
    required String title,
    required Widget alertWidget,
    required VoidCallback actionCall,
    required String buttonText,
  }) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 10,
                ),
                CircularProgressIndicator(),
                SizedBox(
                  height: 30,
                ),
                alertWidget,
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: actionCall,
                style: ElevatedButton.styleFrom(
                  primary: Colors.blueAccent
                ),
                child: Text(buttonText),
              )
            ],
          );
        });
  }
}
