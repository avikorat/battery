import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'setting_event.dart';
part 'setting_state.dart';

class SettingBloc extends Bloc<SettingEvent, dynamic> {
  SettingBloc() : super([]) {
    on<UpdateSettingData>((event, emit) {
      emit(event.setting);
    });
  }
}
