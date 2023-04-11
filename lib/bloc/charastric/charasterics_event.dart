part of 'charasterics_bloc.dart';

@immutable
abstract class CharastericsEvent {}

class CharastericsEventData extends CharastericsEvent{
  final List<BluetoothCharacteristic> incomingData;

  CharastericsEventData(this.incomingData);
}