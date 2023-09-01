import 'package:flutter_blue_plus/flutter_blue_plus.dart';

abstract class ConnectionEvent {}

class ConnectedEvent extends ConnectionEvent {
  BluetoothDevice? device;

  ConnectedEvent(this.device);
}
