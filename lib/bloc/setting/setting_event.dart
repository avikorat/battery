part of 'setting_bloc.dart';

abstract class SettingEvent {}

class UpdateSettingData extends SettingEvent {
  SettingData data;

  UpdateSettingData(this.data);
}

class UploadSettingData extends SettingEvent {
  String settingData;

  UploadSettingData(this.settingData);
}

class UpdateOneProfile extends SettingEvent {
  String settingData;

  UpdateOneProfile(this.settingData);
}
