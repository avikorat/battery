import 'dart:io';
import 'package:battery/bloc/loading/loading_bloc.dart';
import 'package:battery/bloc/loading/loading_event.dart';
import 'package:battery/bloc/service/service_bloc.dart';
import 'package:battery/bloc/service/service_event.dart';
import 'package:battery/bloc/setting/setting_bloc.dart';
import 'package:battery/bloc/tab/tab_service_bloc.dart';
import 'package:battery/bloc/tab/tab_service_events.dart';
import 'package:battery/screen/main_screen.dart';
import 'package:battery/screen/settings.dart';
import 'package:battery/utils/constants.dart';
import 'package:battery/utils/dialog_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:hive/hive.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final String deviceId = "20:10:4B:80:64:C5";
  FlutterBluePlus flutterBlue = FlutterBluePlus.instance;
  BluetoothDevice? device;
  bool connected = false;
  List<BluetoothService> services = [];

  final _pageNo = [const MainScreen(), const Settings()];

  final _bottomBarItems = const [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
    BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings")
  ];

  // ************** BOTTOM NAV BAR WIDGET ****************

  Widget _bottomBar(int state) {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
            topRight: Radius.circular(30), topLeft: Radius.circular(30)),
        boxShadow: [
          BoxShadow(color: Colors.black38, spreadRadius: 0, blurRadius: 10),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30.0),
          topRight: Radius.circular(30.0),
        ),
        child: BottomNavigationBar(
          items: _bottomBarItems,
          currentIndex: state,
          elevation: 10,
          type: BottomNavigationBarType.fixed,
          onTap: (int index) {
            context.read<TabServiceBloc>().add(UpdateTabList(index));
          },
        ),
      ),
    );
  }

  _fetchingDataFromHive() async {
    var box = await Hive.openBox(SETUP);
    if (box.isNotEmpty) {
      var data = box.get(SETUP);
      context.read<SettingBloc>().add(UpdateSettingData(data));
    }
  }

  void showToast(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

// ********************* Checking and getting user permission *************************

  void checkPermissions() async {
    await Permission.location.request();
    await Permission.bluetooth.request();
    PermissionStatus locationStatus = await Permission.locationWhenInUse.status;
    if (locationStatus.isGranted) {
      // Check Bluetooth permission
      PermissionStatus bluetoothStatus = await Permission.bluetooth.status;
      if (bluetoothStatus.isGranted) {
        connectToDevice();
      } else if (bluetoothStatus.isDenied) {
        DialogUtils.showCustomDialog(context,
            title: "Permission",
            alertWidget:
                Text("Bluetooth permission is required to use this app."),
            buttonText: "Open Settings", actionCall: () {
          openAppSettings();
        });
        // openAppSettings();
      } else if (bluetoothStatus.isPermanentlyDenied) {
        DialogUtils.showCustomDialog(context,
            title: "Permission",
            alertWidget: Text(
                "Bluetooth permission is required to use this app. Please enable it in app settings."),
            buttonText: "Open Settings", actionCall: () {
          openAppSettings();
        });
      } else {
        PermissionStatus newStatus = await Permission.bluetooth.request();
        if (newStatus.isGranted) {
          connectToDevice();
        } else {
          showToast('');
          DialogUtils.showCustomDialog(context,
              title: "Permission",
              alertWidget:
                  Text("Bluetooth permission is required to use this app."),
              buttonText: "Open Settings", actionCall: () {
            openAppSettings();
          });
        }
      }
    } else if (locationStatus.isDenied) {
      DialogUtils.showCustomDialog(context,
          title: "Permission",
          alertWidget: Text(
              "Location permission is required to scan for Bluetooth devices."),
          buttonText: "Open Settings", actionCall: () {
        openAppSettings();
      });
    } else if (locationStatus.isPermanentlyDenied) {
      DialogUtils.showCustomDialog(context,
          title: "Permission",
          alertWidget: Text(
              "Location permission is required to scan for Bluetooth devices. Please enable it in app settings."),
          buttonText: "Open Settings", actionCall: () {
        openAppSettings();
      });
    } else {
      PermissionStatus newStatus = await Permission.locationWhenInUse.request();
      if (newStatus.isGranted) {
        // Check Bluetooth permission
        PermissionStatus bluetoothStatus = await Permission.bluetooth.status;
        if (bluetoothStatus.isGranted) {
          connectToDevice();
        } else {
          PermissionStatus newBluetoothStatus =
              await Permission.bluetooth.request();
          if (newBluetoothStatus.isGranted) {
            connectToDevice();
          } else {
            DialogUtils.showCustomDialog(context,
                title: "Permission",
                alertWidget:
                    Text("Bluetooth permission is required to use this app."),
                buttonText: "Open Settings", actionCall: () {
              openAppSettings();
            });
          }
        }
      } else {
        DialogUtils.showCustomDialog(context,
            title: "Permission",
            alertWidget: const Text(
                "Location permission is required to scan for Bluetooth devices."),
            buttonText: "Open Settings", actionCall: () {
          openAppSettings();
        });
      }
    }
  }

// ********************* Connect with already connected devices *************************

  void connectToDevice() async {
    try {
      List<BluetoothDevice> devices = await flutterBlue.connectedDevices;
      for (BluetoothDevice d in devices) {
        if (d.id.toString() == deviceId) {
          device = d;
          connected = true;
          discoverServices();
        }
      }
    } catch (e) {
      print(': $e');
      return;
    }

    if (!connected) {
      try {
        await flutterBlue.stopScan();
        flutterBlue.scan(timeout: const Duration(seconds: 6)).listen((event) {
          if (event.device.id.toString() == deviceId) {
            device = event.device;
            connectDevice();
          }
        });
      } catch (error) {
        print(error);
      }
    }
  }

// ********************* Connect with new devices *************************

  void connectDevice() async {
    try {
      var response = await device?.connect();
      flutterBlue.stopScan();
      connected = true;
      discoverServices();
    } catch (e) {
      print('Error connecting to device: $e');
      return;
    }
  }

// ********************* Discover services of connected device *************************

  void discoverServices() async {
    try {
      List<BluetoothService> _services = await device!.discoverServices();
      context.read<ServiceBloc>().add(UpdateServiceList(_services));
    } catch (e) {
      print('Error discovering services: $e');
    }
  }

  @override
  void initState() {
    context.read<LoadingBloc>().add(Loading(true));
    _fetchingDataFromHive();
    checkPermissions();
    super.initState();
  }

// **************  BLUETOOTH OFF WIDGET ****************
  _bluetoothOffWidget() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.bluetooth_disabled_rounded,
              size: 200.0,
              color: Colors.blue,
            ),
            Text(
              'Bluetooth Adapter is not available',
              style: Theme.of(context)
                  .primaryTextTheme
                  .subtitle2
                  ?.copyWith(color: Colors.black, fontSize: 16),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              child: const Text(
                'TURN ON',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: Platform.isAndroid
                  ? () async {
                      try {
                        context.read<LoadingBloc>().add(Loading(true));
                        await FlutterBluePlus.instance.turnOn();
                        await _fetchingDataFromHive();
                        connected = false;
                        checkPermissions();
                      } catch (e) {
                        print(e);
                      }
                    }
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TabServiceBloc, dynamic>(builder: (context, state) {
      return StreamBuilder<BluetoothState>(
          stream: flutterBlue.state,
          builder: (context, snapshot) {
            if (snapshot.data == BluetoothState.off) {
              context.read<ServiceBloc>().add(UpdateServiceList([]));
              device?.disconnect();
              return _bluetoothOffWidget();
            }
            return Scaffold(
              body: _pageNo[state],
              bottomNavigationBar: _bottomBar(state),
            );
          });
    });
  }
}
