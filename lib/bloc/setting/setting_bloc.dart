import 'dart:io';

import 'package:battery/bloc/setting/setting_data.dart';
import 'package:battery/screen/home_screen.dart';
import 'package:bloc/bloc.dart';
import 'package:path_provider/path_provider.dart';

part 'setting_event.dart';

class SettingBloc extends Bloc<SettingEvent, SettingData> {
  SettingBloc()
      : super(SettingData(
            batteryBrand: '', batterySavedValue: '', fileData: '')) {
    on<UpdateSettingData>((event, emit) {
      emit(event.data);
    });

    on<UploadSettingData>(
      (event, emit) async {
        final directory = await getApplicationDocumentsDirectory();
        final path = '${directory.path}/config_$BLUETOOTH_MAC.txt';
        final file = File(path);
        DateTime now = new DateTime.now();
        DateTime date = new DateTime(now.year, now.month, now.day);
        final exist = await file.exists();
        String data = "";
        if (exist) {
          await file.delete();
        }
        file.writeAsString("_${event.settingData}");
        emit(SettingData(
            fileData: "_${event.settingData}",
            batteryBrand: '',
            batterySavedValue: ''));
      },
    );

    on<UpdateOneProfile>(
      (event, emit) async {
        final directory = await getApplicationDocumentsDirectory();
        final path = '${directory.path}/config_$BLUETOOTH_MAC.txt';
        final file = File(path);
        final exist = await file.exists();
        String data = "";
        if (exist) {
          data = await file.readAsString();
          List<String> dataList = data.split("\n");
          dataList.insert(dataList.length - 1, event.settingData.trim());
          String updatedList = dataList.join("\n");
          file.writeAsStringSync(updatedList, mode: FileMode.write);
          data = await file.readAsString();
          print(data);
        } else {
          data ="_${event.settingData} \n   ";
          file.writeAsString(data);
        }
        emit(SettingData(
            fileData: event.settingData, batteryBrand: '', batterySavedValue: ''));
      },
    );
  }
}
