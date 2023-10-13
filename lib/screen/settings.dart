import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:battery/bloc/charastric/charasterics_bloc.dart';
import 'package:battery/bloc/loading/loading_bloc.dart';
import 'package:battery/bloc/loading/loading_event.dart';
import 'package:battery/bloc/setting/setting_bloc.dart';
import 'package:battery/bloc/setting/setting_data.dart';
import 'package:battery/bloc/tab/tab_service_bloc.dart';
import 'package:battery/bloc/tab/tab_service_events.dart';
import 'package:battery/screen/home_screen.dart';
import 'package:battery/utils/constants.dart';
import 'package:battery/utils/file_utils.dart';
import 'package:battery/utils/utils.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
// import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final _formKey = GlobalKey<FormState>();
  late StreamSubscription<List<int>> subscript;
  String? _selectedKey;
  String? fileDataaa = "";
  // String? _batteryRecovery;

  List<String> items = <String>["AGM", "ATB", "GEL", "LiTh", "WET"];
  List<String> batteryMode = <String>[
    'Boost',
    'Normal',
    'Economy',
    'Maintainer'
  ];

  //         "C:0:$_chemVal;C:1:$_batteryVal;C:2:$batteryCapacity;C:3:$maxBatteryVoltage;C:4:$maxChargingCurrent;C:50:$total;C:55:0";
  List<String> fileData = [];
  List<String> _keyOfFileData = [];
  List<String> _valuesOfFileData = [];

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
    context.read<LoadingBloc>().add(Loading(true));
    super.initState();
  }

  @override
  void dispose() {
    subscript.cancel();
    super.dispose();
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
                    : BlocBuilder<SettingBloc, SettingData>(
                        builder: (context, settingData) {
                          if (settingData.fileData.split("\n").length < 2) {
                            _keyOfFileData = [];
                            _valuesOfFileData = [];
                            return Center(
                                child:
                                    Text("There is no setting data available"));
                          } else if (settingData. fileData.split("\n").length >=
                              2) {
                            if (fileDataaa != settingData.fileData) {
                              fileDataaa = "";
                              fileDataaa = settingData.fileData;
                              _keyOfFileData = [];
                              _valuesOfFileData = [];
                              settingData.fileData
                                  .split("\n")
                                  .asMap()
                                  .forEach((index, element) {
                                if (index ==
                                    fileDataaa!.split('\n').length - 1) {
                                  CONFIG_FILE = element.split("=");
                                } else {
                                  fileData.add(element);

                                  List<String> splitedValues =
                                      element.split("=");
                                  String key = splitedValues[0].startsWith('_')
                                      ? splitedValues[0].substring(1)
                                      : splitedValues[0];

                                  _keyOfFileData.add(key.trim());
                                  _valuesOfFileData.add(splitedValues[1]);
                                }
                              });
                              context.read<LoadingBloc>().add(Loading(false));
                            }

                            return Form(
                                key: _formKey,
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        height:
                                            CONFIG_FILE[0].isNotEmpty ? 16 : 0,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "Last Updated",
                                            style: TextStyle(
                                                color: Colors.blue,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            CONFIG_FILE[1].isNotEmpty
                                                ? CONFIG_FILE[1].substring(0,
                                                    CONFIG_FILE[1].length - 10)
                                                : "",
                                            style: TextStyle(
                                                color: Colors.blue,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height:
                                            CONFIG_FILE[0].isNotEmpty ? 16 : 0,
                                      ),
                                      Text(
                                        "Selected Profile: ${settingData.batteryBrand}",
                                        style: TextStyle(
                                            color: Colors.blue,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(
                                        height:
                                            settingData.batteryBrand.length > 1
                                                ? 16
                                                : 0,
                                      ),
                                      DropdownButtonFormField<String>(
                                        value: settingData.batteryBrand.isEmpty
                                            ? _keyOfFileData[0]
                                            : settingData.batteryBrand,
                                        onChanged: (value) {
                                          _selectedKey = value;
                                        },
                                        decoration:
                                            _decoration('Profile selection'),
                                        items: _keyOfFileData
                                            .map<DropdownMenuItem<String>>(
                                                (String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value),
                                          );
                                        }).toList(),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please select battery options.';
                                          }
                                          return null;
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
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                          onPressed: (() async {
                                            if (_formKey.currentState!
                                                .validate()) {
                                              await _onSaveTapped(
                                                  _selectedKey!,
                                                  charData[0],
                                                  settingData.fileData);
                                            }
                                          }))
                                    ]));
                          }
                          return Container();
                        },
                      );
              });
            },
          ),
        ))));
  }

  Future<void> _onSaveTapped(String selectedKey,
      BluetoothCharacteristic charData, String fileData) async {
    try {
      context.read<LoadingBloc>().add(Loading(true));

      DialogBox(
        context: context,
        Title: "Saving Battery Parameters",
        widget:
            SizedBox(width: 20, height: 40, child: CircularProgressIndicator()),
      );

      int index = _keyOfFileData.indexOf(selectedKey);
      String data = _valuesOfFileData[index];
      List<String> elements = data.split(";");
// sending data to bluetooth

      for (int i = 0; i < elements.length - 1; i++) {
        // List<String> elm = elements[i].split(":");
        print(i);
        List<int> encodedDataaaaa = utf8.encode('${elements[i]}\r\n');
        await charData.write(encodedDataaaaa, withoutResponse: false);
        await Future.delayed(const Duration(milliseconds: 300));
      }

      // var box = await Hive.openBox(SETUP);
      // var setUpData = [selectedKey, data];

      // await box.put(SETUP, setUpData);

      // var dtaa = box.get(SETUP);

      // await box.close();
      fileData = fileData.replaceAll("_", "");
      fileData = fileData.replaceAll(selectedKey, "_$selectedKey");

      context.read<SettingBloc>().add(UpdateSettingData(SettingData(
          fileData: fileData,
          batteryBrand: selectedKey,
          batterySavedValue: data)));
      charData.setNotifyValue(true);
      notification = true;
      subscript = charData.value.listen((event) {
        List<String> _incomingData = [];
        _incomingData.add(String.fromCharCodes(event));
        String _parsedData = _incomingData.join();
        bool isDataComing = _parsedData.contains("L:");
        if (isDataComing) {
          FileUtils().writeToFile(fileData, BLUETOOTH_MAC);
          BRANDNAME = selectedKey;
          Navigator.pop(context);
          context.read<TabServiceBloc>().add(UpdateTabList(0));
          context.read<LoadingBloc>().add(Loading(false));
          subscript.cancel();
        }
      });
    } catch (e) {
      showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return SimpleDialog(
                // key: key,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                backgroundColor: Colors.red,
                children: <Widget>[
                  Center(
                    child: Column(children: [
                      const SizedBox(
                        height: 10,
                      ),
                      const CircularProgressIndicator(color: Colors.white),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        "There might be something wrong!!",
                        style: const TextStyle(color: Colors.white),
                      ),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white),
                          child: Text("Clear"),
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pop(context);
                            charData.setNotifyValue(true);
                            context
                                .read<TabServiceBloc>()
                                .add(UpdateTabList(0));
                            context.read<LoadingBloc>().add(Loading(false));
                            subscript.cancel();
                          })
                    ]),
                  )
                ]);
          });
    }
  }
}
