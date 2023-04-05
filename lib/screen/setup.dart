import 'dart:convert';
import 'package:battery/bloc/loading/loading_bloc.dart';
import 'package:battery/bloc/loading/loading_event.dart';
import 'package:battery/bloc/tab/tab_service_bloc.dart';
import 'package:battery/bloc/tab/tab_service_events.dart';
import 'package:battery/screen/main_screen.dart';
import 'package:battery/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

class Setup extends StatefulWidget {
  const Setup({Key? key}) : super(key: key);

  @override
  State<Setup> createState() => _SetupState();
}

class _SetupState extends State<Setup> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            iconTheme: IconThemeData(
              color: Colors.white, //change your color here
            ),
            centerTitle: true,
            title: const Text(
              "Set up",
              style: TextStyle(color: Colors.white),
            )),
        backgroundColor: Color.fromARGB(218, 255, 251, 251),
        body: SafeArea(
            child: SingleChildScrollView(
                child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: BlocBuilder<LoadingBloc, bool>(builder: (context, state) {
            return state
                ? Center(
                    child: Material(
                      elevation: 10,
                      shape: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12))),
                      child: SizedBox(
                          height: 50,
                          child: Column(
                            children: [
                              Text("Saving Battery Parameters"),
                              CircularProgressIndicator(),
                            ],
                          )),
                    ),
                  )
                : Form(
                    key: _formKey,
                    child: Column(children: [
                      DropdownButtonFormField<String>(
                        value: _chargingMode,
                        onChanged: (value) {
                          setState(() {
                            _chargingMode = value;
                          });
                        },
                        decoration: const InputDecoration(
                            labelText: 'Battery Charging Mode',
                            focusColor: Colors.white,
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(6)))),
                        items: <String>[
                          'Boost',
                          'Normal',
                          'Economy',
                          'Maintainer'
                        ].map<DropdownMenuItem<String>>((String value) {
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
                        value: _batteryChemistry,
                        onChanged: (value) {
                          setState(() {
                            _batteryChemistry = value;
                          });
                        },
                        decoration: const InputDecoration(
                            labelText: 'Battery Chemistry',
                            focusColor: Colors.white,
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(6)))),
                        items: <String>["AGM", "ATB", "GEL", "LiTh", "WET"]
                            .map<DropdownMenuItem<String>>((String value) {
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
                        decoration: const InputDecoration(
                            labelText: 'Battery Capacity (Ah)',
                            focusColor: Colors.white,
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(6)))),
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
                        decoration: const InputDecoration(
                            labelText: 'Maximum Charging Current (A)',
                            focusColor: Colors.white,
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(6)))),
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
                        decoration: const InputDecoration(
                            labelText: 'Maximum Battery Voltage (V)',
                            focusColor: Colors.white,
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(6)))),
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

                      // _spacing(),
                      // TextFormField(
                      //   keyboardType: TextInputType.number,
                      //   decoration: const InputDecoration(
                      //       labelText: 'Maximum Charging Time (Hours)',
                      //       focusColor: Colors.white,
                      //       border: OutlineInputBorder(
                      //           borderRadius: BorderRadius.all(Radius.circular(6)))),
                      //   validator: (value) {
                      //     if (value == null || value.isEmpty) {
                      //       return 'Please enter a maximum charging time';
                      //     }
                      //     return null;
                      //   },
                      //   onChanged: (value) {
                      //     _maxChargingTime = value;
                      //   },
                      // ),
                      // _spacing(),
                      // DropdownButtonFormField<String>(
                      //   value: _batteryRecovery,
                      //   onChanged: (value) {
                      //     setState(() {
                      //       _batteryRecovery = value;
                      //     });
                      //   },
                      //   decoration: const InputDecoration(
                      //       labelText: 'Battery Recovery',
                      //       focusColor: Colors.white,
                      //       border: OutlineInputBorder(
                      //           borderRadius: BorderRadius.all(Radius.circular(6)))),
                      //   items: <String>["On", "Off"]
                      //       .map<DropdownMenuItem<String>>((String value) {
                      //     return DropdownMenuItem<String>(
                      //       value: value,
                      //       child: Text(value),
                      //     );
                      //   }).toList(),
                      //   validator: (value) {
                      //     if (value == null || value.isEmpty) {
                      //       return 'Please select a battery recovery option.';
                      //     }
                      //     return null;
                      //   },
                      // ),
                      _spacing(),
                      MaterialButton(
                          color: Colors.blue,
                          textColor: Colors.white,
                          child: Center(child: Text("Save")),
                          onPressed: (() {
                            if (_formKey.currentState!.validate()) {
                              _onSaveTapped(
                                  batteryCapacity: _batteryCapacity!,
                                  batteryChemistry: _batteryChemistry!,
                                  chargingMode: _chargingMode!,
                                  maxBatteryVoltage: _maxBatteryVoltage!,
                                  maxChargingCurrent: _maxChargingCurrent!);
                            }
                          }))
                    ]));
          }),
        ))));
  }

  void _onSaveTapped(
      {required String batteryChemistry,
      required String chargingMode,
      required String batteryCapacity,
      required String maxBatteryVoltage,
      required String maxChargingCurrent}) async {
    context.read<LoadingBloc>().add(Loading(true));
    int _chemVal = items.indexOf(batteryChemistry);
    int _batteryVal = batteryMode.indexOf(chargingMode);
    double _batteryCapa = double.parse(batteryCapacity);
    double _maxVolt = double.parse(maxBatteryVoltage);
    double _curr = double.parse(maxChargingCurrent);

    double total = _chemVal + _batteryVal + _batteryCapa + _maxVolt + _curr;
    String incomingData =
        "C:0:$_chemVal;C:1:$_batteryVal;C:2:$batteryCapacity;C:3:$maxBatteryVoltage;C:4:$maxChargingCurrent;C:50:$total;C:55:0";
    List<String> elements = incomingData.split(";");

    try {
      for (int i = 0; i < elements.length; i++) {
        List<String> elm = elements[i].split(":");
        String processedData = "${elm[0]}:${elm[1]}:";
        await CHARACTERISTICS!
            .write(utf8.encode(processedData), withoutResponse: false);
        await CHARACTERISTICS!
            .write(utf8.encode(elm[2]), withoutResponse: false);
        await CHARACTERISTICS!
            .write(utf8.encode("\r\n"), withoutResponse: false);
      }
      var box = await Hive.openBox(SETUP);
      var setUpData = [
        chargingMode,
        batteryChemistry,
        batteryCapacity,
        maxChargingCurrent,
        maxBatteryVoltage
      ];
      await box.put(SETUP, setUpData);
      var dtaa = box.get(SETUP);
      context.read<LoadingBloc>().add(Loading(false));
      context.read<TabServiceBloc>().add(UpdateTabList(0));
      Navigator.pop(context);
    } catch (e) {
      print(e);
    }
  }
}
