import 'package:battery/bloc/setting/setting_bloc.dart';
import 'package:battery/bloc/setting/setting_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ConfigurationScsreen extends StatefulWidget {
  const ConfigurationScsreen({super.key});

  @override
  State<ConfigurationScsreen> createState() => _ConfigurationScsreenState();
}

class _ConfigurationScsreenState extends State<ConfigurationScsreen> {
  String? _selectedOption;

  List<String> _dropdownOptions = [
    'AGM',
    'ATB',
    'GEL',
    'Lithium',
    'WET',
  ];

  int? _selectedRadio;

  final _formKey = GlobalKey<FormState>();
  TextEditingController _profileNameController = TextEditingController();
  TextEditingController _capacityController = TextEditingController();
  TextEditingController _voltageController = TextEditingController();
  TextEditingController _currentController = TextEditingController();

  Widget dropdownFormField() {
    return FormField<String>(
      builder: (FormFieldState<String> field) {
        return Container(
          height: 60, // Increase the height of the dropdown
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: 'Select battery chemistry',
              errorText: field.errorText,
              contentPadding: EdgeInsets.symmetric(
                  vertical:
                      8), // Decrease the vertical padding of the form field
            ),
            isEmpty: _selectedOption == null,
            child: DropdownButtonFormField<String>(
              value: _selectedOption,
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.zero, // Remove padding inside the dropdown
              ),
              isDense: true,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedOption = newValue;
                  field.didChange(newValue);
                });
              },
              items: _dropdownOptions.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
        );
      },
      validator: (value) {
        if (_selectedOption == null) {
          return 'Please select an option';
        }
        return null;
      },
    );
  }

  @override
  void dispose() {
    _capacityController.dispose();
    _currentController.dispose();
    _voltageController.dispose();
    _profileNameController.dispose();
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
          //automaticallyImplyLeading: false,
          title: Text(
            "Configuration Screen",
            style: TextStyle(color: Colors.white),
          )),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    Text(
                      "Add configuration of your battery",
                      style: TextStyle(fontSize: 20),
                    ),
                    TextFormField(
                      controller: _profileNameController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        labelText: 'Profile Name',
                      ),
                      validator: (value) {
                        // You can add more complex email validation if needed
                        if (value!.isEmpty) {
                          return 'Please enter voltage of battery';
                        }
                        return null;
                      },
                    ),
                    dropdownFormField(),
                    TextFormField(
                      controller: _capacityController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Battery Capacity',
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter capacity of battery';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _voltageController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Voltage',
                      ),
                      validator: (value) {
                        // You can add more complex email validation if needed
                        if (value!.isEmpty) {
                          return 'Please enter voltage of battery';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _currentController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Current',
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter current of battery';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.0),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8))),
                      onPressed: () {
                        int current = 0;
                        int voltage = 0;
                        if (_formKey.currentState!.validate()) {
                          if (double.parse(_currentController.text) % 1 != 0) {
                            current =
                                (double.parse(_currentController.text) * 100)
                                    .toInt();
                          } else {
                            current = int.parse(_currentController.text);
                          }
                          if (double.parse(_voltageController.text) % 1 != 0) {
                            voltage =
                                (double.parse(_voltageController.text) * 100)
                                    .toInt();
                          } else {
                            voltage = int.parse(_voltageController.text);
                          }
                          int chem = _dropdownOptions.indexOf(_selectedOption!);
                          int capacityInt = int.parse(_capacityController.text);
                          int total = current + voltage + capacityInt + chem;

                          String interpolationStr =
                              "\n${_profileNameController.text} - $_selectedOption=C:0:$chem;C:1:0;C:2:$capacityInt;C:3:$voltage;C:4:$current;C:50:$total;C:55:0";
                          context
                              .read<SettingBloc>()
                              .add(UpdateOneProfile(interpolationStr));
                          _profileNameController.clear();
                          _capacityController.clear();
                          _voltageController.clear();
                          _currentController.clear();
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              backgroundColor: Colors.blue,
                              content: Text(
                                "Profile saved.",
                                style: TextStyle(color: Colors.white),
                              )));
                          Navigator.pop(context);
                        }
                      },
                      child: Text(
                        'Submit',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                  ],
                ),
              ),
              BlocBuilder<SettingBloc, SettingData>(
                builder: (context, state) {
                  List<bool> _selectedCheck = List.filled(
                      state.fileData.split('\n').length,
                      false); // Track the selected options
                  return StatefulBuilder(builder: (context, setInnerState) {
                    return Column(
                      children: [
                        ExpansionTile(
                          title: Text("Remove Profile"),
                          initiallyExpanded: true,
                          children: state.fileData.split('\n').map((element) {
                            final index =
                                state.fileData.split('\n').indexOf(element);
                            if (state.fileData.split('\n').last == element) {
                              return SizedBox();
                            }
                            return ListTile(
                              title: Text(element
                                  .split('=')[0]
                                  .split('-')[0]
                                  .replaceAll('_', '')),
                              leading: Checkbox(
                                value: _selectedCheck[index],
                                onChanged: (value) {
                                  setInnerState(() {
                                    _selectedCheck[index] =
                                        !_selectedCheck[index];
                                  });
                                },
                              ),
                            );
                          }).toList(),
                        ),
                        _selectedCheck.any((element) => element == true)
                            ? ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8))),
                                onPressed: () {
                                  List<String> configurationData = [];
                                  List<String> _serviceData =
                                      state.fileData.split('\n');

                                  List<int> trueIndexes = _selectedCheck
                                      .asMap()
                                      .entries
                                      .where((entry) => entry.value == true)
                                      .map((entry) => entry.key)
                                      .toList();

                                  trueIndexes.forEach((element) {
                                    configurationData
                                        .add(_serviceData[element]);
                                  });

                                  _serviceData.removeWhere((element) =>
                                      configurationData.contains(element));

                                  context.read<SettingBloc>().add(
                                      UploadSettingData(
                                          _serviceData
                                              .join('\n')
                                              .replaceAll("_", ""),
                                          state.fileData.split('/').last));

                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                          backgroundColor: Colors.red,
                                          content: Text(
                                            "Profile deleted.",
                                            style:
                                                TextStyle(color: Colors.white),
                                          )));
                                  Navigator.pop(context);
                                },
                                child: Text("Delete",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 20)),
                              )
                            : SizedBox(),
                      ],
                    );
                  });
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
