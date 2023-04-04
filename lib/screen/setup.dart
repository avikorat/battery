import 'package:flutter/material.dart';

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
  String? _minBatteryVoltage;
  String? _maxChargingTime;
  String? _batteryRecovery;

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
        body: SafeArea(
            child: SingleChildScrollView(
                child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Form(
              key: _formKey,
              child: Column(children: [
// charging mode dropdown

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
                          borderRadius: BorderRadius.all(Radius.circular(6)))),
                  items: <String>['Boost', 'Normal', 'Economy', 'Maintainer']
                      .map<DropdownMenuItem<String>>((String value) {
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
                          borderRadius: BorderRadius.all(Radius.circular(6)))),
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
                          borderRadius: BorderRadius.all(Radius.circular(6)))),
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
                          borderRadius: BorderRadius.all(Radius.circular(6)))),
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
                          borderRadius: BorderRadius.all(Radius.circular(6)))),
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
                TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: 'Minimum Battery Voltage (V)',
                      focusColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(6)))),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a minimum battery voltage';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    _minBatteryVoltage = value;
                  },
                ),
                _spacing(),
                TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: 'Maximum Charging Time (Hours)',
                      focusColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(6)))),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a maximum charging time';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    _maxChargingTime = value;
                  },
                ),
                _spacing(),
                DropdownButtonFormField<String>(
                  value: _batteryRecovery,
                  onChanged: (value) {
                    setState(() {
                      _batteryRecovery = value;
                    });
                  },
                  decoration: const InputDecoration(
                      labelText: 'Battery Recovery',
                      focusColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(6)))),
                  items: <String>["On", "Off"]
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a battery recovery option.';
                    }
                    return null;
                  },
                ),
                _spacing(),
                MaterialButton(
                    color: Colors.blue,
                    textColor: Colors.white,
                    child: Center(child: Text("Save")),
                    onPressed: (() {
                      if (_formKey.currentState!.validate()) {
                        // Do something with the data
                        print('Battery Charging Mode: $_chargingMode');
                        print('Battery Chemistry: $_batteryChemistry');
                        print('Battery Capacity: $_batteryCapacity Ah');
                        print(
                            'Maximum Charging Current: $_maxChargingCurrent Ampere');
                        print(
                            'Maximum Battery Voltage: $_maxBatteryVoltage Volts');
                        print(
                            'Minimum Battery Voltage: $_minBatteryVoltage Volts');
                        print('Maximum Charging Time: $_maxChargingTime hours');
                        print('Battery Recovery: $_batteryRecovery');
                      }
                    }))
              ])),
        ))));
  }
}




// final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

// final TextEditingController _batteryCapacityController = TextEditingController();
// final TextEditingController _maxChargingCurrentController = TextEditingController();
// final TextEditingController _maxBatteryVoltageController = TextEditingController();
// final TextEditingController _minBatteryVoltageController = TextEditingController();
// final TextEditingController _maxChargingTimeController = TextEditingController();

// String _batteryChargingModeValue;
// String _batteryChemistryValue;
// String _batteryRecoveryValue;


// }
