import 'dart:async';

import 'package:battery/bloc/charastric/charasterics_bloc.dart';
import 'package:battery/bloc/loading/loading_bloc.dart';
import 'package:battery/bloc/loading/loading_event.dart';
import 'package:battery/bloc/parse_data/parse_data_bloc.dart';
import 'package:battery/bloc/parse_data/parse_data_event.dart';
import 'package:battery/bloc/service/service_bloc.dart';
import 'package:battery/utils/constants.dart';
import 'package:battery/utils/dialog_utils.dart';
import 'package:battery/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<String> _packates = [];
  List<String> _finalParsedData = [];
  List<String> _finalSortedData = [];
  String _parsedPackates = '';
  BluetoothService? _service;
  BluetoothCharacteristic? _characteristic;

  final List<String> _names = [
    "Battery Capacity",
    "Battery Type",
    "Charging Status",
    "Charging Voltage",
    "Charging Time",
    "Charging Current"
  ];

// Parsing data according to the need of the UI and add the stream of data into bloc

  _convertDataToModelClass(List<String> data) {
    String? chemistryValue;
    String? batteryStatus;
    String? voltage;
    String? current;
    String? chargeTime;
    String? batteryCapacity;
    for (var dataElem in data) {
      dataElem = dataElem.replaceAll("\n", "");
      List<String> values = dataElem.split(":");
      values[2] = values[2].trim();
      if (values[2] == "") {
        values[2] = "0";
      }
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
          chemistryValue = "Lithium";
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
          try {
            int _batteryVal = int.parse(values[2]);
            if (_batteryVal == 0) {
              batteryStatus = "No Battery";
            } else if (_batteryVal > 0 && _batteryVal < 7) {
              batteryStatus = "Charging";
            } else if (_batteryVal == 7) {
              batteryStatus = "Charged";
            }
          } catch (e) {
            print(e);
          }
        }

// 8 for current
      } else if (values[1] == "8") {
        int _currentFlag = int.parse(values[2]);
        current = "${_currentFlag / 100} Amp";

// 7 for voltage
      } else if (values[1] == "7") {
        try {
          int _voltageFlag = int.parse(values[2]);
          if (_voltageFlag == 0) {
            voltage = "0.00";
          } else {
            voltage = (_voltageFlag / 100).toString();
          }
        } catch (e) {
          print(e);
        }

// 21 for battery capacity
      } else if (values[1] == '21') {
        try {
          int _batteryCapacity = int.parse(values[2]);
          if (_batteryCapacity == 0) {
            batteryCapacity = "0.00";
          } else {
            batteryCapacity = _batteryCapacity.toString();
          }
        } catch (e) {
          print(e);
        }
      }
    }
    List<String> d = [
      batteryCapacity ?? '0.00',
      chemistryValue ?? "",
      batteryStatus ?? "No Battery",
      voltage ?? "0.00",
      chargeTime ?? "00:00",
      current ?? "0.0 Amp"
    ];

    if (mounted) {
      context.read<LoadingBloc>().add(Loading(false));
      context.read<ParseDataBloc>().add(ParsingList(d));
    }
  }

  // incoming data parsing function

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
        if (_finalParsedData.length > 5) {
          for (int i = 0; i < _finalParsedData.length; i++) {
            List<String> splittedData = _finalParsedData[i].split(":");
            if (splittedData.length == 3) {
              _finalSortedData.add(_finalParsedData[i]);
            }
          }

          _convertDataToModelClass(_finalSortedData.toSet().toList());
        }
        _finalParsedData = [];
        _finalSortedData = [];
      }
    });
  }

// Fetching data from the bluetooth and passing to decode function
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
            context
                .read<CharastericsBloc>()
                .add(CharastericsEventData([element]));
          }
        },
      );
      if (!notification) {
        _characteristic!.setNotifyValue(true);
        notification = false;
      }

      _characteristic!.value.listen((notificationData) {
        _decodeData(notificationData);
      });
    }
  }

  // Grid tile widget
  Widget _gridTiles(List<dynamic> data, int index) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Material(
        color: Colors.blueAccent,
        shadowColor: Colors.red,
        elevation: 15,
        child: Container(
            height: 60,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: [Colors.blue, Color.fromARGB(255, 52, 50, 184)]),
            ),
            child: Center(
                child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              ),
            ))),
      ),
    );
  }

  Widget _gauge(String value) {
    double _convertedVal = double.parse(value);
    int socValue = int.parse(value);
    return Stack(
      children: [
        Center(
          child: Image.asset("assets/companyLogo.png",
              opacity: AlwaysStoppedAnimation(0.2),
              height: 250,
              width: MediaQuery.of(context).size.width / 3),
        ),
        SizedBox(
          height: 250,
          child: SfRadialGauge(
              enableLoadingAnimation: true,
              animationDuration: 4500,
              axes: <RadialAxis>[
                RadialAxis(
                    minimum: 0,
                    maximum: 100,
                    axisLabelStyle: GaugeTextStyle(
                        fontSize: 10, fontWeight: FontWeight.bold),
                    showLastLabel: true,
                    ranges: <GaugeRange>[
                      GaugeRange(
                          startValue: 0,
                          endValue: 25,
                          color: Colors.red,
                          startWidth: 10,
                          endWidth: 10),
                      GaugeRange(
                          startValue: 25,
                          endValue: 45,
                          color: Colors.yellow,
                          startWidth: 10,
                          endWidth: 10),
                      GaugeRange(
                          startValue: 45,
                          endValue: 70,
                          color: Colors.orange,
                          startWidth: 10,
                          endWidth: 10),
                      GaugeRange(
                          startValue: 70,
                          endValue: 100,
                          color: Colors.green,
                          startWidth: 10,
                          endWidth: 10)
                    ],
                    pointers: <GaugePointer>[
                      NeedlePointer(
                        value: _convertedVal,
                        needleColor: Colors.blue,
                        needleLength: 0.6,
                        knobStyle:
                            KnobStyle(color: Colors.blue, knobRadius: 0.05),
                        needleEndWidth: 6,
                      )
                    ],
                    annotations: <GaugeAnnotation>[
                      GaugeAnnotation(
                          widget: Container(
                              child: Text("SOC: $socValue",
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.blue))),
                          angle: 90,
                          positionFactor: 0.7)
                    ])
              ]),
        ),
      ],
    );
  }

  _notConnectionWidget() {
    return Center(child: MaterialButton(onPressed: () {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromARGB(96, 228, 227, 227),
        body: BlocBuilder<ServiceBloc, List<BluetoothService>>(
            builder: (context, state) {
          _gettingData(state);
          return BlocBuilder<ParseDataBloc, List<dynamic>>(
            builder: (context, data) {
              return BlocBuilder<LoadingBloc, bool>(
                builder: (context, loadingState) {
                  if (loadingState) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  return Column(
                    children: [
                      ListView.builder(
                        itemCount: data.length,
                        shrinkWrap: true,
                        itemBuilder: (BuildContext context, int index) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: index == 0
                                ? _gauge(data[index])
                                : _gridTiles(data, index),
                          );
                        },
                      ),
                      SizedBox(height: 40,),
                      SizedBox(
                          width: MediaQuery.of(context).size.width / 1.5,
                          child: Image.asset("assets/companyLogo.png"))
                    ],
                  );
                },
              );
            },
          );
        }));
  }
}
