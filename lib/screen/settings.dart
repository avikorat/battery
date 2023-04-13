import 'dart:convert';

import 'package:battery/bloc/charastric/charasterics_bloc.dart';
import 'package:battery/bloc/loading/loading_bloc.dart';
import 'package:battery/bloc/loading/loading_event.dart';
import 'package:battery/bloc/setting/setting_bloc.dart';
import 'package:battery/bloc/tab/tab_service_bloc.dart';
import 'package:battery/bloc/tab/tab_service_events.dart';
import 'package:battery/utils/constants.dart';
import 'package:battery/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:hive/hive.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final _formKey = GlobalKey<FormState>();

  String? _chargingMode;
  String? _batteryChemistry;
  String? _batteryCapacity;
  String? _maxChargingCurrent;
  String? _maxBatteryVoltage;
  String? _maxChargingTime;
  // String? _batteryRecovery;

  List<String> items = <String>["AGM", "ATB", "GEL", "LiTh", "WET"];
  List<String> batteryMode = <String>[
    'Boost',
    'Normal',
    'Economy',
    'Maintainer'
  ];

  Widget _spacing() {
    return const SizedBox(
      height: 16,
    );
  }

  _decoration(String lable) {
    return InputDecoration(
        labelText: lable,
        focusColor: Colors.white,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(6))));
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            iconTheme: IconThemeData(
              color: Colors.white, //change your color here
            ),
            centerTitle: true,
            automaticallyImplyLeading: false,
            title: const Text(
              "Set up",
              style: TextStyle(color: Colors.white),
            )),
        body: SafeArea(
            child: SingleChildScrollView(
                child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: BlocBuilder<CharastericsBloc, List<BluetoothCharacteristic>>(
            builder: (context, charData) {
              return BlocBuilder<LoadingBloc, bool>(builder: (context, state) {
                return state
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : BlocBuilder<SettingBloc, dynamic>(
                        builder: (context, settingData) {
                          if (settingData.length > 0) {
                            _chargingMode = settingData[0];
                            _batteryChemistry = settingData[1];
                            _batteryCapacity = settingData[2];
                            _maxChargingCurrent = settingData[3];
                            _maxBatteryVoltage = settingData[4];
                          } else {
                            _chargingMode = "Normal";
                            _batteryChemistry = "AGM";
                          }

                          return Form(
                              key: _formKey,
                              child: Column(children: [
                                DropdownButtonFormField<String>(
                                  value: _chargingMode ?? 'Normal',
                                  onChanged: (value) {
                                    setState(() {
                                      _chargingMode = value;
                                    });
                                  },
                                  decoration:
                                      _decoration('Battery Charging Mode'),
                                  items: <String>[
                                    'Boost',
                                    'Normal',
                                    'Economy',
                                    'Maintainer'
                                  ].map<DropdownMenuItem<String>>(
                                      (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please select a charging mode';
                                    }
                                    return null;
                                  },
                                ),
                                _spacing(),
                                DropdownButtonFormField<String>(
                                  value: _batteryChemistry ?? "AGM",
                                  onChanged: (value) {
                                    setState(() {
                                      _batteryChemistry = value;
                                    });
                                  },
                                  decoration: _decoration('Battery Chemistry'),
                                  items: <String>[
                                    "AGM",
                                    "ATB",
                                    "GEL",
                                    "LiTh",
                                    "WET"
                                  ].map<DropdownMenuItem<String>>(
                                      (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please select a battery chemistry';
                                    }
                                    return null;
                                  },
                                ),
                                _spacing(),
                                TextFormField(
                                  keyboardType: TextInputType.number,
                                  initialValue: _batteryCapacity ?? '',
                                  decoration:
                                      _decoration('Battery Capacity (Ah)'),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter a battery capacity';
                                    }
                                    return null;
                                  },
                                  onChanged: (value) {
                                    _batteryCapacity = value;
                                  },
                                ),
                                _spacing(),
                                TextFormField(
                                  keyboardType: TextInputType.number,
                                  initialValue: _maxChargingCurrent ?? '',
                                  decoration: _decoration(
                                      'Maximum Charging Current (A)'),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter a maximum charging current';
                                    }
                                    return null;
                                  },
                                  onChanged: (value) {
                                    _maxChargingCurrent = value;
                                  },
                                ),
                                _spacing(),
                                TextFormField(
                                  keyboardType: TextInputType.number,
                                  initialValue: _maxBatteryVoltage ?? '',
                                  decoration: _decoration(
                                      'Maximum Battery Voltage (V)'),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter a maximum battery voltage';
                                    }
                                    return null;
                                  },
                                  onChanged: (value) {
                                    _maxBatteryVoltage = value;
                                  },
                                ),
                                _spacing(),
                                MaterialButton(
                                    color: Colors.blue,
                                    textColor: Colors.white,
                                    child: Center(
                                        child: Text(
                                      "Save",
                                      style: TextStyle(fontSize: 20),
                                    )),
                                    height: 50,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                    onPressed: (() {
                                      if (_formKey.currentState!.validate()) {
                                        _onSaveTapped(
                                            batteryCapacity: _batteryCapacity!,
                                            batteryChemistry:
                                                _batteryChemistry!,
                                            chargingMode: _chargingMode!,
                                            maxBatteryVoltage:
                                                _maxBatteryVoltage!,
                                            maxChargingCurrent:
                                                _maxChargingCurrent!,
                                            characteristic: charData[0]);
                                      }
                                    }))
                              ]));
                        },
                      );
              });
            },
          ),
        ))));
  }

  void _onSaveTapped(
      {required String batteryChemistry,
      required String chargingMode,
      required String batteryCapacity,
      required String maxBatteryVoltage,
      required String maxChargingCurrent,
      required BluetoothCharacteristic characteristic}) async {
// loading state on
    context.read<LoadingBloc>().add(Loading(true));

// showing dialog box
    DialogBox(
      context: context,
      Title: "Saving Battery Parameters",
      widget:
          SizedBox(width: 20, height: 40, child: CircularProgressIndicator()),
    );

// sorting and setting data for the bluetooth
    int _chemVal = items.indexOf(batteryChemistry);
    int _batteryVal = batteryMode.indexOf(chargingMode);
    double _batteryCapa = double.parse(batteryCapacity);
    double _maxVolt = double.parse(maxBatteryVoltage);
    double _curr = double.parse(maxChargingCurrent);

    double total = _chemVal + _batteryVal + _batteryCapa + _maxVolt + _curr;
    String incomingData =
        "C:0:$_chemVal;C:1:$_batteryVal;C:2:$batteryCapacity;C:3:$maxBatteryVoltage;C:4:$maxChargingCurrent;C:50:$total;C:55:0";
    List<String> elements = incomingData.split(";");

// sending data to bluetooth
    try {
      for (int i = 0; i < elements.length; i++) {
        List<String> elm = elements[i].split(":");
        String processedData = "${elm[0]}:${elm[1]}:";
        await characteristic.write(utf8.encode(processedData),
            withoutResponse: false);
        await characteristic.write(utf8.encode(elm[2]), withoutResponse: false);
        await characteristic.write(utf8.encode("\r\n"), withoutResponse: false);
      }
      var box = await Hive.openBox(SETUP);
      var setUpData = [
        chargingMode,
        batteryChemistry,
        batteryCapacity,
        maxChargingCurrent,
        maxBatteryVoltage
      ];

// adding data to hive
      await box.put(SETUP, setUpData);
      var dtaa = box.get(SETUP);
// loader stop
      context.read<LoadingBloc>().add(Loading(false));
      context.read<SettingBloc>().add(UpdateSettingData(dtaa));
      Navigator.pop(context);
      context.read<TabServiceBloc>().add(UpdateTabList(0));
    } catch (e) {
      print(e);
    }
  }
}
