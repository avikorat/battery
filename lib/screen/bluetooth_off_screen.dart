import 'dart:io';

import 'package:battery/bloc/loading/loading_bloc.dart';
import 'package:battery/bloc/loading/loading_event.dart';
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

BluetoothDevice? DEVICE;

class _BluetoothOffScreenState extends State<BluetoothOffScreen> {
// **************  BLUETOOTH OFF WIDGET ****************
  _bluetoothOffWidget(bool state) {
    return state
        ? Center(
            child: CircularProgressIndicator(),
          )
        : Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Icon(
                  Icons.bluetooth_disabled,
                  size: 200.0,
                  color: Colors.blue,
                ),
                Text(
                  'Bluetooth Adapter is ${widget.state != null ? widget.state.toString().substring(15) : 'not available'}.',
                  style: Theme.of(context)
                      .primaryTextTheme
                      .subtitle2
                      ?.copyWith(color: Colors.black),
                ),
                ElevatedButton(
                  child: const Text(
                    'TURN ON',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: Platform.isAndroid
                      ? () {
                          context.read<LoadingBloc>().add(Loading(true));
                          FlutterBluePlus.instance.turnOn();
                          FlutterBluePlus.instance
                              .scan(timeout: const Duration(seconds: 10));
                          context.read<LoadingBloc>().add(Loading(false));
                        }
                      : null,
                ),
              ],
            ),
          );
  }

  // **************  BLUETOOTH LISTING WIDGET ****************

  _bluetoothListingWidget(bool state) {
    return state
        ? Center(
            child: CircularProgressIndicator(),
          )
        : RefreshIndicator(
            onRefresh: () => FlutterBluePlus.instance
                .startScan(timeout: const Duration(seconds: 4)),
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  StreamBuilder<List<BluetoothDevice>>(
                    stream: Stream.periodic(const Duration(seconds: 2))
                        .asyncMap(
                            (_) => FlutterBluePlus.instance.connectedDevices),
                    initialData: const [],
                    builder: (c, snapshot) => Column(
                      children: snapshot.data!
                          .map((d) => _alredyConnectedTile(d))
                          .toList(),
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
                                      context
                                          .read<LoadingBloc>()
                                          .add(Loading(true));
                                      await r.device.connect();
                                      FlutterBluePlus.instance.stopScan();
                                      List<BluetoothService> services =
                                          await r.device.discoverServices();
                                      DEVICE = r.device;
                                      if (mounted) {
                                        context
                                            .read<ServiceBloc>()
                                            .add(UpdateServiceList(services));
                                        context
                                            .read<TabServiceBloc>()
                                            .add(UpdateTabList(0));
                                        context
                                            .read<LoadingBloc>()
                                            .add(Loading(false));
                                      }
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Material(
          elevation: 10,
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          child: ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            tileColor: Colors.white,
            title: Text(blueToothList.device.name.toString()),
            trailing: IconButton(
                icon: const Icon(Icons.bluetooth_sharp), onPressed: onTap),
          ),
        ),
      ),
    );
  }

  // **************  BLUETOOTH ALREADY CONNECTED TILE WIDGET ****************

  Widget _alredyConnectedTile(BluetoothDevice d) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Material(
        elevation: 10,
        borderRadius: BorderRadius.all(Radius.circular(10)),
        child: ListTile(
          title: Text(d.name),
          trailing: StreamBuilder<BluetoothDeviceState>(
            stream: d.state,
            initialData: BluetoothDeviceState.disconnected,
            builder: (c, snapshot) {
              if (snapshot.data == BluetoothDeviceState.connected) {
                return ElevatedButton(
                  child: const Text('OPEN'),
                  onPressed: () async {
                    context.read<LoadingBloc>().add(Loading(true));
                    FlutterBluePlus.instance.stopScan();
                    DEVICE = d;
                    List<BluetoothService> services =
                        await d.discoverServices();

                    context
                        .read<ServiceBloc>()
                        .add(UpdateServiceList(services));
                    context.read<TabServiceBloc>().add(UpdateTabList(0));
                    context.read<LoadingBloc>().add(Loading(false));
                  },
                );
              }
              return Text(snapshot.data.toString());
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bluetooth', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      backgroundColor: Color.fromARGB(96, 228, 227, 227),
      body: BlocBuilder<LoadingBloc, bool>(builder: (context, state) {
        return StreamBuilder<BluetoothState>(
            stream: FlutterBluePlus.instance.state,
            builder: (context, snapShot) {
              if (snapShot.data == BluetoothState.on) {
                FlutterBluePlus.instance.startScan(
                    scanMode: ScanMode.lowPower,
                    timeout: Duration(seconds: 10));
              }
              return snapShot.data == BluetoothState.off
                  ? _bluetoothOffWidget(state)
                  : _bluetoothListingWidget(state);
            });
      }),
    );
  }
}
