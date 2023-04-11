import 'package:bloc/bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:meta/meta.dart';

part 'charasterics_event.dart';
part 'charasterics_state.dart';

class CharastericsBloc extends Bloc<CharastericsEvent, List<BluetoothCharacteristic>> {
  CharastericsBloc() : super([]) {
    on<CharastericsEventData>((event, emit) {
      emit(event.incomingData);
    });
  }
}
