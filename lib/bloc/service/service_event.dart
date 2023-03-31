
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

abstract class ServiceEvent  {
}

class UpdateServiceList extends ServiceEvent {
  final List<BluetoothService> services;

  UpdateServiceList(this.services);
}

class ServiceId extends ServiceEvent{
   final List<BluetoothService> services;

  ServiceId(this.services);
}
