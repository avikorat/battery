import 'dart:io';
import 'package:path_provider/path_provider.dart';

class FileUtils {
  Future<void> writeToFile(String text, String id) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String fileName = 'config_$id.txt';
    final File file = File('${directory.path}/$fileName');

    try {
      await file.writeAsString(text);
    } catch (e) {
      throw 'Error writing to file: $e';
    }
  }

  Future<bool> searchFile(String id) async {
    try {
      final String fileName = 'config_$id.txt';
      final Directory appDocumentsDirectory =
          await getApplicationDocumentsDirectory();
      final String filePath = '${appDocumentsDirectory.path}/$fileName';
      final File file = File(filePath);

      return await file.exists();
    } catch (e) {
      throw 'Error searching for file: $e';
    }
  }

  Future<String> readFile(String id) async {
    try {
      final String fileName = 'config_$id.txt';
      final Directory appDocumentsDirectory =
          await getApplicationDocumentsDirectory();
      final String filePath = '${appDocumentsDirectory.path}/$fileName';
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

  Future<void> updateFile(String newText, String id) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String fileName = 'config_$id.txt';
    final File file = File('${directory.path}/$fileName');

    try {
      if (await file.exists()) {
        await file.writeAsString(newText);
      } else {
        throw 'File not found';
      }
    } catch (e) {
      throw 'Error updating file: $e';
    }
  }
}
