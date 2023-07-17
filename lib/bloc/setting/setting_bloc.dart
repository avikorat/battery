import 'dart:io';

import 'package:battery/bloc/setting/setting_data.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
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
        final path = '${directory.path}/profile.txt';
        final file = File(path);
        final exist = await file.exists();
        String data = "";
        if (exist) {
          await file.delete();
        }
        file.writeAsString(event.settingData);
        emit(SettingData(
            fileData: event.settingData,
            batteryBrand: '',
            batterySavedValue: ''));
      },
    );

    on<UpdateOneProfile>(
      (event, emit) async {
        final directory = await getApplicationDocumentsDirectory();
        final path = '${directory.path}/profile.txt';
        final file = File(path);
        final exist = await file.exists();
        String data = "";
        if (exist) {
          file.writeAsStringSync(event.settingData, mode: FileMode.append);
          data = await file.readAsString();
          print(data);
        }
        emit(SettingData(
            fileData: data, batteryBrand: '', batterySavedValue: ''));
      },
    );
  }
}
