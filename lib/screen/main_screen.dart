import 'dart:convert';
import 'dart:math';

import 'package:battery/bloc/parse_data/parse_data_bloc.dart';
import 'package:battery/bloc/parse_data/parse_data_event.dart';
import 'package:battery/bloc/service/service_bloc.dart';
import 'package:battery/models/data_model.dart';
import 'package:battery/screen/bluetooth_off_screen.dart';
import 'package:battery/utils/constants.dart';
import 'package:battery/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<String> _packates = [];
  List<String> _finalParsedData = [];
  String _parsedPackates = '';
  BluetoothService? _service;
  BluetoothCharacteristic? _characteristic;

  final List<String> _names = [
    "Battery Chemistry",
    "Status",
    "Voltage",
    "Time",
    "Current"
  ];

  _convertDataToModelClass(List<String> data) {
    String? chemistryValue;
    String? batteryStatus;
    String? voltage;
    String? current;
    String? chargeTime;

    for (var dataElem in data) {
      List<String> values = dataElem.split(":");

      if (values.any((element) => element == "")) {
        int index = values.indexOf("");
        values[index] = "0";
      }
// 1 for chemistry of battery
      if (values.length < 3) {
        print("issue");
      } else if (values[1] == "1") {
        int _chem = int.parse(values[2]);
        if (_chem == 0) {
          chemistryValue = "AGM";
        } else if (_chem == 1) {
          chemistryValue = "ATB";
        } else if (_chem == 2) {
          chemistryValue = "GEL";
        } else if (_chem == 3) {
          chemistryValue = "LiTh";
        } else if (_chem == 4) {
          chemistryValue = "WET";
        }

// 2 for charge time
      } else if (values[1] == "2") {
        int _chargeTimeFlag = int.parse(values[2]);
        int _hours = (_chargeTimeFlag / 60).toInt();
        int _mins = (_chargeTimeFlag % 60).toInt();
        chargeTime =
            '${_hours.toString().padLeft(2, '0')}:${_mins.toString().padLeft(2, '0')}';

// 3 for battery status
      } else if (values[1] == "3") {
        if (values[2] == "") {
          print("status issue");
        } else {
          int _batteryVal = int.parse(values[2]);
          if (_batteryVal == 0) {
            batteryStatus = "No Battery";
          } else if (_batteryVal > 0 && _batteryVal < 7) {
            batteryStatus = "Charging";
          } else if (_batteryVal == 7) {
            batteryStatus = "Charged";
          }
          
        }

// 8 for current
      } else if (values[1] == "8") {
        int _currentFlag = int.parse(values[2]);
        current = "${_currentFlag / 100} Amp";

// 7 for voltage
      } else if (values[1] == "7") {
        int _voltageFlag = int.parse(values[2]);
        if (_voltageFlag == 0) {
          voltage = "0.00";
        } else {
          voltage = (_voltageFlag / 100).toString();
        }
      }
    }

    List<String> d = [
      chemistryValue ?? "",
      batteryStatus ?? "No Battery",
      voltage ?? "0.00",
      chargeTime ?? "00:00",
      current ?? "0.0 Amp"
    ];

    if (mounted) {
      context.read<ParseDataBloc>().add(ParsingList(d));
    }
  }

  _decodeData(List<int> notificationData) {
    _packates.add(String.fromCharCodes(notificationData));
    _parsedPackates = _packates.join();

    _parsedPackates.split('\n').forEach((element) {
      if (element.startsWith('L:')) {
        _finalParsedData.add(element);
        _parsedPackates = "";
        _packates = [];
      } else if (_finalParsedData.isNotEmpty) {
        _finalParsedData.last += element;
        _parsedPackates = "";
        _packates = [];
      }

      if (_finalParsedData.isNotEmpty &&
          (_finalParsedData.last.contains('L:50') ||
              _finalParsedData.last.contains('L:31'))) {
        List<String> temp = _finalParsedData;
        _convertDataToModelClass(_finalParsedData);
        _finalParsedData = [];
      }
    });
  }

  _gettingData(List<BluetoothService> state) {
    if (state.isNotEmpty) {
      for (var element in state) {
        if (convertUUID(element.uuid.toString()) == SERVICE) {
          _service = element;
        }
      }

      var char = _service!.characteristics.forEach(
        (element) {
          if (convertUUID(element.uuid.toString()) == CHARACTERISTIC) {
            _characteristic = element;
          }
        },
      );

      _characteristic!.setNotifyValue(true);
      _characteristic!.value.listen((notificationData) {
        //   print(String.fromCharCodes(notificationData));
        _decodeData(notificationData);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<ServiceBloc, List<BluetoothService>>(
          builder: (context, state) {
        _gettingData(state);
        return BlocBuilder<ParseDataBloc, List<dynamic>>(
          builder: (context, data) {
            print(data);
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
              ),
              itemCount: data.length,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: Material(
                      color: Colors.blueAccent,
                      shadowColor: Colors.red,
                      elevation: 15,
                      child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(colors: [
                              Colors.blue,
                              Color.fromARGB(255, 52, 50, 184)
                            ]),
                          ),
                          child: Center(
                              child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _names[index],
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16),
                              ),
                              SizedBox(height: 16),
                              Text(
                                data[index],
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16),
                              ),
                            ],
                          ))),
                    ),
                  ),
                );
              },
            );
          },
        );
      }),
    );
  }
}
