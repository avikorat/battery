import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<void> writeToFile(String text, String id) async {
  final Directory directory = await getApplicationDocumentsDirectory();
  final String fileName = 'config_$id.txt';
  final File file = File('${directory.path}/files/$fileName');

  try {
    await file.writeAsString(text);
  } catch (e) {
    throw 'Error writing to file: $e';
  }
}

Future<bool> searchFile(String id) async {
  try {
    final String fileName = 'config_$id.txt';
    final Directory appDocumentsDirectory = await getApplicationDocumentsDirectory();
    final String filePath = '${appDocumentsDirectory.path}/files/$fileName';
    final File file = File(filePath);
    
    return await file.exists();
  } catch (e) {
    throw 'Error searching for file: $e';
  }
}

Future<String> readFile(String id) async {
  try {
    final String fileName = 'config_$id.txt';
    final Directory appDocumentsDirectory = await getApplicationDocumentsDirectory();
    final String filePath = '${appDocumentsDirectory.path}/files/$fileName';
    final File file = File(filePath);

    if (await file.exists()) {
      return await file.readAsString();
    } else {
      throw 'File not found';
    }
  } catch (e) {
    throw 'Error reading file: $e';
  }
}
