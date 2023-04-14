part of 'setting_bloc.dart';

@immutable
abstract class SettingEvent {}

class UpdateSettingData extends SettingEvent {
  SettingData data;

  UpdateSettingData(this.data);
}