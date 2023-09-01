import 'package:bloc/bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:meta/meta.dart';

import 'connection_event.dart';

class ConnectionBloc extends Bloc<ConnectionEvent, bool> implements StateStreamable<bool> {
  ConnectionBloc() : super(true) {
    on<ConnectedEvent>((event, emit) {
      if (event.device != null) {
        event.device!.state.listen((deviceState) {
          if (deviceState == BluetoothDeviceState.disconnected) {
            // Device disconnected, update UI here
            emit(false);
          } else if (deviceState == BluetoothDeviceState.connected) {
            emit(true);
          } else if (deviceState == BluetoothDeviceState.disconnecting) {
            emit(false);
          } else if (deviceState == BluetoothDeviceState.connecting) {
            emit(true);
          }
        });
      }
    });
  }
}
