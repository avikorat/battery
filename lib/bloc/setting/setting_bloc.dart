import 'package:battery/bloc/setting/setting_data.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'setting_event.dart';

class SettingBloc extends Bloc<SettingEvent, SettingData> {
  SettingBloc() : super(SettingData(batteryBrand: '',batterySavedValue: '',fileData: '')) {
    on<UpdateSettingData>((event, emit) {
      emit(event.data);
    });
  }
}