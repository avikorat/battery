import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:battery/bloc/charastric/charasterics_bloc.dart';
import 'package:battery/bloc/connection/connection_bloc.dart';
import 'package:battery/bloc/connection/connection_event.dart';
import 'package:battery/bloc/loading/loading_bloc.dart';
import 'package:battery/bloc/loading/loading_event.dart';
import 'package:battery/bloc/parse_data/parse_data_bloc.dart';
import 'package:battery/bloc/parse_data/parse_data_event.dart';
import 'package:battery/bloc/service/service_bloc.dart';
import 'package:battery/bloc/setting/setting_bloc.dart';
import 'package:battery/screen/configuration_screen.dart';
import 'package:battery/screen/home_screen.dart';
import 'package:battery/utils/circular_border.dart';
import 'package:battery/utils/constants.dart';
import 'package:battery/utils/dialog_utils.dart';
import 'package:battery/utils/file_utils.dart';
import 'package:battery/utils/utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:wave/config.dart';
import 'package:wave/wave.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

bool sendDataExecuted = false;
bool isShown = false;


class _MainScreenState extends State<MainScreen> {
  List<String> _packates = [];
  List<String> _finalParsedData = [];
  List<String> _finalSortedData = [];
  List<double> _voltage = [];
  List<int> _current = [];
  List<int> _capacity = [];
  String _parsedPackates = '';
  BluetoothService? _service;
  BluetoothCharacteristic? _characteristic;
  FlutterBluePlus flutterBlue = FlutterBluePlus.instance;

  final List<String> _names = [
    "Battery Capacity",
    "Profile",
    "Charging Status",
    "Charging Voltage",
    "Charging Time",
    "Charging Current"
  ];

  String? chemistryValue;
  String? batteryStatus;
  String? voltage;
  String? current;
  String? chargeTime;
  String? batteryCapacity;
// Parsing data according to the need of the UI and add the stream of data into bloc

  _convertDataToModelClass(List<String> data) {
    // String tempVolt = "0.00";
    final validCharacters = RegExp(r'^[a-zA-Z0-9]+$');
    isShown = true;
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
      } else if (values[1] == "3") {
        int _chargeTimeFlag = 0;
        values[2].replaceAll(RegExp(r'[^0-9]'), '');

        int _hours = (_chargeTimeFlag / 60).toInt();
        int _mins = (_chargeTimeFlag % 60).toInt();
        chargeTime =
            '${_hours.toString().padLeft(2, '0')}:${_mins.toString().padLeft(2, '0')} hh:mm';

// 3 for battery status
      } else if (values[1] == "4") {
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
      } else if (values[1] == "9") {
        int _currentFlag = 0;
        String currentValue = values[2].replaceAll(RegExp(r'[^0-9]'), '');

        if (currentValue.contains("L")) {
          currentValue = currentValue.replaceAll(RegExp(r'[L\n]'), '');
        }

        _currentFlag = int.parse(currentValue);
        _current.add(_currentFlag);

        if (_current.length > 5) {
          _current.removeAt(0); // Remove the oldest value
        }

        _currentFlag = _current
            .reduce((maxValue, value) => value > maxValue ? value : maxValue);

        current = _currentFlag == 0 ? "0 A" : "${_currentFlag / 100} A";

// 8 for voltage
      } else if (values[1] == "8") {
        try {
          int _voltageFlag = int.parse(values[2]);
          //  voltage = (_voltageFlag / 100).toString();
          if (_voltageFlag / 100 < 70) {
            _voltage.add(_voltageFlag / 100);
          }

          if (_voltage.length > 5) {
            _voltage.removeAt(0);
            // double sum = _voltage.fold(0, (p, c) => p + c);voltage = (sum / 5).toStringAsFixed(2);
          }
          voltage = _voltage
              .reduce((value, element) => value > element ? value : element)
              .toStringAsFixed(2);

          voltage = "$voltage V";
        } catch (e) {
          print(e);
        }

// 21 for battery capacity
      } else if (values[1] == '21') {
        try {
          int _batteryCapacity = 0;

          if (values[2].contains("L")) {
            _batteryCapacity =
                int.parse(values[2].replaceAll(RegExp(r'[L\n]'), ''));
          } else {
            _batteryCapacity = int.parse(values[2]);
          }

          _capacity.add(_batteryCapacity);

          if (_capacity.length > 5) {
            _capacity.removeAt(0);
          }

          batteryCapacity = _capacity
              .reduce((value, element) => value > element ? value : element)
              .toString();
        } catch (e) {
          print(e);
        }
      }
    }
    List<String> d = [
      batteryCapacity ?? '0.00',
      BRANDNAME,
      batteryStatus ?? "No Battery",
      voltage ?? "0.00 V",
      chargeTime ?? "00:00 hh:mm",
      current ?? "0.0 A"
    ];

    if (mounted) {
      context.read<LoadingBloc>().add(Loading(false));
      context.read<ParseDataBloc>().add(ParsingList(d));
    }
  }

  // incoming data parsing function

  _decodeData(List<int> notificationData) async {
    _packates.add(String.fromCharCodes(notificationData));
    _parsedPackates = _packates.join();

    final parsedLines = _parsedPackates.split('\n');

    for (String element in parsedLines) {
      if (element.startsWith("I:")) {
        if (element.contains("I:40")) {
          element.split('\n').forEach((splittedElement) async {
            if (splittedElement.contains("I:40")) {
              if (CRC == '' ||
                  int.parse(splittedElement.split(":")[2]) != int.parse(CRC)) {
                if (sendDataExecuted == false) {
                  sendDataExecuted = true;
                  await sendDataToCharger(fileSelectedData, _characteristic!);
                }
              }
            }
          });
        }
      }
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
          (_finalParsedData.last.contains('L:50'))) {
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
    }
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
        if (notificationData.isEmpty) {
          // context.read<ConnectionBloc>().add(ConnectedEvent(device));
        } else {
          _decodeData(notificationData);
        }
      });
    }
  }

  sendDataToCharger(String data, BluetoothCharacteristic charData) async {
    List<String> elements = data.split(";");
    for (int i = 0; i < elements.length - 1; i++) {
      // List<String> elm = elements[i].split(":");
      print(i);
      List<int> encodedDataaaaa = utf8.encode('${elements[i]}\r\n');
      await charData.write(encodedDataaaaa, withoutResponse: false);
      await Future.delayed(const Duration(milliseconds: 200));
    }

    await charData.setNotifyValue(true);

    charData.value.listen((event) {
      List<String> _incomingData = [];
      _incomingData.add(String.fromCharCodes(event));
      String _parsedData = _incomingData.join();
      bool isDataComing = _parsedData.contains("L:");
    });
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

// ******************* Dialog of configuration ****************
  Widget customDialog(onFileSelected) {
    File? fileSelected;
    String? fileName;
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return AlertDialog(
        title: Text('Upload Configuration file'),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            GestureDetector(
              onTap: () async {
                FilePickerResult? result =
                    await FilePicker.platform.pickFiles(type: FileType.any);

                if (result != null && result.files.isNotEmpty) {
                  fileSelected = File(result.files.first.path!);
                  fileName = fileSelected!.path.split('/').last;
                  setState(
                    () {},
                  );
                }
              },
              child: const CircularBorder(
                color: Colors.blue,
                size: 60,
                icon: Icon(Icons.upload),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Text(fileName ?? ''),
            SizedBox(
              height: fileName != null ? 20 : 0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: Text('Upload', style: TextStyle(color: Colors.white)),
                  onPressed: () async {
                    context.read<LoadingBloc>().add(Loading(true));
                    onFileSelected(fileSelected);
                    String content = await fileSelected!.readAsString();
                    String finalFileData =
                        "$content \n${fileSelected!.path.split('/').last} = ${DateTime.now()}";
                    await FileUtils()
                        .writeToFile("_$finalFileData", BLUETOOTH_MAC);

                    BRANDNAME = content.split("=")[0];
                    fileSelectedData = content.split("\n")[0];
                    // CRC = fileSelectedData
                    //     .split(';')
                    //     .where((element) => element.startsWith('C:50:'))
                    //     .first
                    //     .split(":")[2];
                    sendDataExecuted = false;
                    // dynamic configBox = await Hive.openBox('configBox');
                    // await configBox.delete('configData');
                    // CONFIG_FILE = [
                    //   fileSelected!.path.split('/').last,
                    //   DateTime.now().toString()
                    // ];
                    // await configBox.put("configData", CONFIG_FILE);

                    Navigator.of(context).pop();
                    context.read<LoadingBloc>().add(Loading(false));
                  },
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ConfigurationScsreen()));
              },
              child: Text(
                "Add or Remove configuration",
                style: TextStyle(
                    color: Colors.blue,
                    fontSize: 12,
                    fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
      );
    });
  }

  void _onFileSelected(File file) async {
    final contents = await file.readAsString();
    context.read<SettingBloc>().add(UploadSettingData(
        "$contents\n${file.path.split('/').last}=${DateTime.now()}",
        file.path.split('/').last));
  }

  Widget _gauge(String value) {
    double _convertedVal = double.parse(value);
    int socValue = _convertedVal.toInt();
    return Column(
      children: [
        Stack(
          children: [
            // Center(
            //   child: Image.asset("assets/companyLogo.png",
            //       opacity: AlwaysStoppedAnimation(0.2),
            //       height: 250,
            //       width: MediaQuery.of(context).size.width / 3),
            // ),
            SizedBox(
              height: 250,
              child: GestureDetector(
                  onLongPress: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return customDialog(_onFileSelected);
                      },
                    );
                  },
                  child: showUI(_convertedVal)
                  //showNewStatusUI(_convertedVal)
                  // SfRadialGauge(
                  //     enableLoadingAnimation: true,
                  //     animationDuration: 4500,
                  //     axes: <RadialAxis>[
                  //       RadialAxis(
                  //           minimum: 0,
                  //           maximum: 100,
                  //           axisLabelStyle: GaugeTextStyle(
                  //               fontSize: 10, fontWeight: FontWeight.bold),
                  //           showLastLabel: true,
                  //           ranges: <GaugeRange>[
                  //             GaugeRange(
                  //                 startValue: 0,
                  //                 endValue: 25,
                  //                 color: Colors.red,
                  //                 startWidth: 10,
                  //                 endWidth: 10),
                  //             GaugeRange(
                  //                 startValue: 25,
                  //                 endValue: 45,
                  //                 color: Colors.yellow,
                  //                 startWidth: 10,
                  //                 endWidth: 10),
                  //             GaugeRange(
                  //                 startValue: 45,
                  //                 endValue: 70,
                  //                 color: Colors.orange,
                  //                 startWidth: 10,
                  //                 endWidth: 10),
                  //             GaugeRange(
                  //                 startValue: 70,
                  //                 endValue: 100,
                  //                 color: Colors.green,
                  //                 startWidth: 10,
                  //                 endWidth: 10)
                  //           ],
                  //           pointers: <GaugePointer>[
                  //             NeedlePointer(
                  //               value: _convertedVal,
                  //               needleColor: Colors.blue,
                  //               needleLength: 0.6,
                  //               knobStyle: KnobStyle(
                  //                   color: Colors.blue, knobRadius: 0.05),
                  //               needleEndWidth: 6,
                  //             )
                  //           ],
                  //           annotations: <GaugeAnnotation>[
                  //             GaugeAnnotation(
                  //                 widget: Container(
                  //                     child: Text("SOC: $socValue %",
                  //                         style: TextStyle(
                  //                             fontSize: 20, color: Colors.blue))),
                  //                 angle: 90,
                  //                 positionFactor: 0.7)
                  //           ])
                  //     ]),
                  ),
            ),
          ],
        ),
        Text(
          "Connected Bluetooth: 2406SRD ${BLUETOOTH_MAC.substring(BLUETOOTH_MAC.length - 5).replaceAll(":", "")}",
          style: TextStyle(
              color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 20),
        )
      ],
    );
  }

  showUI(double soc) {
    if (soc >= 0 && soc < 25) {
      return showNewStatusUI(Icons.battery_0_bar, Colors.red, 20);
    } else if (soc >= 25 && soc < 45) {
      return showNewStatusUI(Icons.battery_2_bar, Colors.yellow, 40);
    } else if (soc >= 45 && soc < 70) {
      return showNewStatusUI(Icons.battery_4_bar, Colors.orange, 60);
    } else if (soc >= 70 && soc <= 99) {
      return showNewStatusUI(Icons.battery_6_bar, Colors.green, 90);
    } else if (soc >= 99) {
      return showNewStatusUI(Icons.battery_6_bar, Colors.green, 120);
    }
  }

  Widget showNewStatusUI(
      IconData selectedIcon, Color selectedColor, double soc) {
    int duration = 5000;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Center(
        child: SizedBox(
            height: 170,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Icon(
                  selectedIcon,
                  //Icons.battery_0_bar,
                  size: 200,
                  color: selectedColor,
                ),
                Container(
                  width: 50,
                  height: soc,
                  color: selectedColor,
                ),
              ],
            )),
      ),
    );
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
                    final currentContext = context;

                    Timer(Duration(seconds: 60), () {
                      if (!isShown) {
                        isShown = true;
                        showDialog(
                          context: currentContext,
                          builder: (BuildContext context) {
                            isShown = true;
                            return AlertDialog(
                              title: const Text("Error"),
                              content: Text(
                                  "There might be some issue with charger can you restart charger?"),
                              actions: [
                                TextButton(
                                  child: Text("Cancel"),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      }
                    });
                    return const Center(child: CircularProgressIndicator());
                  }

                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        ListView.builder(
                          itemCount: data.length,
                          shrinkWrap: true,
                          itemBuilder: (BuildContext context, int index) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: index == 0
                                  ? _gauge(data[index])
                                  : index == 1 && data[1].isEmpty
                                      ? Container()
                                      : _gridTiles(data, index),
                            );
                          },
                        ),
                        SizedBox(
                          height: 35,
                        ),
                        SizedBox(
                            width: MediaQuery.of(context).size.width / 1.5,
                            child: Image.asset("assets/companyLogo.png"))
                      ],
                    ),
                  );
                },
              );
            },
          );
        }));
  }
}
