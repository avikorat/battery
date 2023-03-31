import 'dart:io';

import 'package:battery/bloc/service/service_bloc.dart';
import 'package:battery/bloc/service/service_event.dart';
import 'package:battery/bloc/tab/tab_service_bloc.dart';
import 'package:battery/bloc/tab/tab_service_events.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothOffScreen extends StatefulWidget {
  const BluetoothOffScreen({Key? key, this.state}) : super(key: key);

  final BluetoothState? state;

  @override
  State<BluetoothOffScreen> createState() => _BluetoothOffScreenState();
}

class _BluetoothOffScreenState extends State<BluetoothOffScreen> {
// **************  BLUETOOTH OFF WIDGET ****************
  _bluetoothOffWidget() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(
            Icons.bluetooth_disabled,
            size: 200.0,
            color: Colors.white54,
          ),
          Text(
            'Bluetooth Adapter is ${widget.state != null ? widget.state.toString().substring(15) : 'not available'}.',
            style: Theme.of(context)
                .primaryTextTheme
                .subtitle2
                ?.copyWith(color: Colors.white),
          ),
          ElevatedButton(
            child: const Text('TURN ON'),
            onPressed: Platform.isAndroid
                ? () {
                    FlutterBluePlus.instance.turnOn();
                    FlutterBluePlus.instance
                        .scan(timeout: const Duration(seconds: 10));
                  }
                : null,
          ),
        ],
      ),
    );
  }

  // **************  BLUETOOTH LISTING WIDGET ****************

  _bluetoothListingWidget() {
    return RefreshIndicator(
      onRefresh: () => FlutterBluePlus.instance
          .startScan(timeout: const Duration(seconds: 4)),
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            StreamBuilder<List<BluetoothDevice>>(
              stream: Stream.periodic(const Duration(seconds: 2))
                  .asyncMap((_) => FlutterBluePlus.instance.connectedDevices),
              initialData: const [],
              builder: (c, snapshot) => Column(
                children:
                    snapshot.data!.map((d) => _alredyConnectedTile(d)).toList(),
              ),
            ),
            StreamBuilder<List<ScanResult>>(
              stream: FlutterBluePlus.instance.scanResults,
              initialData: const [],
              builder: (c, snapshot) => Column(
                children: snapshot.data!
                    .map(
                      (r) => r.device.name.isNotEmpty
                          ? _scanTile(
                              r,
                              () async {
                                await r.device.connect();
                                FlutterBluePlus.instance.stopScan();
                                List<BluetoothService> services =
                                    await r.device.discoverServices();
                                context
                                    .read<ServiceBloc>()
                                    .add(UpdateServiceList(services));
                                context
                                    .read<TabServiceBloc>()
                                    .add(UpdateTabList(0));
                              },
                            )
                          : Container(),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // **************  BLUETOOTH LISTING TILE WIDGET ****************

  Widget _scanTile(ScanResult blueToothList, VoidCallback onTap) {
    return ListTile(
      tileColor: Colors.white,
      title: Text(blueToothList.device.name.toString()),
      trailing: IconButton(icon: Icon(Icons.bluetooth_sharp), onPressed: onTap),
    );
  }

  // **************  BLUETOOTH ALREADY CONNECTED TILE WIDGET ****************

  Widget _alredyConnectedTile(BluetoothDevice d) {
    return ListTile(
      title: Text(d.name),
      subtitle: Text(d.id.toString()),
      trailing: StreamBuilder<BluetoothDeviceState>(
        stream: d.state,
        initialData: BluetoothDeviceState.disconnected,
        builder: (c, snapshot) {
          if (snapshot.data == BluetoothDeviceState.connected) {
            return ElevatedButton(
              child: const Text('OPEN'),
              onPressed: () async {
                FlutterBluePlus.instance.stopScan();
                List<BluetoothService> services = await d.discoverServices();
                context.read<ServiceBloc>().add(UpdateServiceList(services));
                context.read<TabServiceBloc>().add(UpdateTabList(0));

                //    Navigator.pushNamed(context, '/mainScreen');
              },
            );
          }
          return Text(snapshot.data.toString());
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue,
      appBar: AppBar(
        title: Text('Bluetooth'),
      ),
      body: StreamBuilder<BluetoothState>(
          stream: FlutterBluePlus.instance.state,
          builder: (context, snapShot) {
            if (snapShot.data == BluetoothState.on) {
              FlutterBluePlus.instance.startScan(
                  scanMode: ScanMode.lowPower, timeout: Duration(seconds: 10));
            }
            return snapShot.data == BluetoothState.off
                ? _bluetoothOffWidget()
                : _bluetoothListingWidget();
          }),
    );
  }
}
