import 'package:battery/bloc/service/service_bloc.dart';
import 'package:battery/screen/bluetooth_off_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<ServiceBloc, List<BluetoothService>>(
        builder: (context, state) {

var characteristicUuid = Guid("0XFFE1");
var characteristic = state
    .map((service) => service.characteristics)
    .expand((characteristics) => characteristics)
    .singleWhere((characteristic) => characteristic.uuid == characteristicUuid);


          print(state.first.uuid);
          return Container();
        }
      ),
    );
  }
}