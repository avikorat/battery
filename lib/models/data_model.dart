import 'package:flutter/material.dart';

class DataModel {
  String? chemistryValue;
  String? batteryStatus;
  String? voltage = "0.00";
  String? current;
  String? chargeTime;

  DataModel(
      {this.chemistryValue,
      this.batteryStatus,
      this.voltage,
      this.current,
      this.chargeTime});
}
