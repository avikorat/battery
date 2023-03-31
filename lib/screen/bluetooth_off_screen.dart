import 'dart:io';

import 'package:battery/bloc/service/service_bloc.dart';
import 'package:battery/bloc/service/service_event.dart';
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
                ? Center(
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
                                  FlutterBluePlus.instance.scan(
                                      timeout: const Duration(seconds: 10));
                                }
                              : null,
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () => FlutterBluePlus.instance
                        .startScan(timeout: const Duration(seconds: 4)),
                    child: SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          StreamBuilder<List<BluetoothDevice>>(
                            stream: Stream.periodic(const Duration(seconds: 2))
                                .asyncMap((_) =>
                                    FlutterBluePlus.instance.connectedDevices),
                            initialData: const [],
                            builder: (c, snapshot) => Column(
                              children: snapshot.data!
                                  .map((d) => ListTile(
                                        title: Text(d.name),
                                        subtitle: Text(d.id.toString()),
                                        trailing:
                                            StreamBuilder<BluetoothDeviceState>(
                                          stream: d.state,
                                          initialData:
                                              BluetoothDeviceState.disconnected,
                                          builder: (c, snapshot) {
                                            if (snapshot.data ==
                                                BluetoothDeviceState
                                                    .connected) {
                                              return ElevatedButton(
                                                child: const Text('OPEN'),
                                                onPressed: () {},
                                                // onPressed: () => Navigator.of(context).push(
                                                //     MaterialPageRoute(
                                                //         builder: (context) =>
                                                //             DeviceScreen(device: d))),
                                              );
                                            }
                                            return Text(
                                                snapshot.data.toString());
                                          },
                                        ),
                                      ))
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
                                              await r.device.connect();
                                              List<BluetoothService> services =
                                                  await r.device
                                                      .discoverServices();
                                                      context.read<ServiceBloc>().add(UpdateServiceList(services));
                                              Navigator.pushNamed(
                                                  context, '/mainScreen');
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
          }),
    );
  }

  Widget _scanTile(ScanResult blueToothList, VoidCallback onTap) {
    return ListTile(
      tileColor: Colors.white,
      title: Text(blueToothList.device.name.toString()),
      trailing: IconButton(icon: Icon(Icons.bluetooth_sharp), onPressed: onTap),
    );
  }
}
