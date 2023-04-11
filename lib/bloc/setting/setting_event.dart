part of 'setting_bloc.dart';

@immutable
abstract class SettingEvent {}

class UpdateSettingData extends SettingEvent {
  final dynamic setting;

  UpdateSettingData(this.setting);
}