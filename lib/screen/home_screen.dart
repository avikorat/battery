import 'dart:async';
import 'dart:io';
import 'package:battery/bloc/connection/connection_bloc.dart';
import 'package:battery/bloc/connection/connection_event.dart';
import 'package:battery/bloc/loading/loading_bloc.dart';
import 'package:battery/bloc/loading/loading_event.dart';
import 'package:battery/bloc/service/service_bloc.dart';
import 'package:battery/bloc/service/service_event.dart';
import 'package:battery/bloc/setting/setting_bloc.dart';
import 'package:battery/bloc/setting/setting_data.dart';
import 'package:battery/bloc/tab/tab_service_bloc.dart';
import 'package:battery/bloc/tab/tab_service_events.dart';
import 'package:battery/screen/main_screen.dart';
import 'package:battery/screen/settings.dart';
import 'package:battery/utils/constants.dart';
import 'package:battery/utils/dialog_utils.dart';
import 'package:battery/utils/file_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
// import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

String BLUETOOTH_NAME = "";
dynamic CONFIG_FILE = [];
String BLUETOOTH_MAC = "";
String BRANDNAME = "";
String CRC = "";
String fileSelectedData = "";

bool is_exist = false;

class _HomeScreenState extends State<HomeScreen> {
  // final String deviceId = "20:10:4B:80:64:C5";
  final String deviceId = "20:10:4B";
  FlutterBluePlus flutterBlue = FlutterBluePlus.instance;
  bool connected = false;
  bool scanStoped = false;
  List<BluetoothService> services = [];
  List<String> dataFromHive = [];
  BluetoothDevice? device;
  List<BluetoothDevice> multipleDevices = [];

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

// Data injection is done from here so make change if data comes from server

  readOrWriteData() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/profile.txt';
    final file = File(path);
    final exist = await file.exists();
    String data = "";
    if (exist) {
      // data = await file.readAsString();
      // context.read<SettingBloc>().add(UpdateSettingData(SettingData(
      //     fileData: data,
      //     batteryBrand: dataFromHive.length > 0 ? dataFromHive[0] : '',
      //     batterySavedValue: dataFromHive.length > 0 ? dataFromHive[1] : '')));
    } else {
      // file.writeAsString(
      //     "Discover - AGM=${Discover}\nExide - GEL=${Excide}\nTrojan - WET=${Trojon}\nLithium =${Lithium}");
      // context.read<SettingBloc>().add(UpdateSettingData(exist
      //     ? SettingData(
      //         fileData: data,
      //         batteryBrand: dataFromHive.length > 0 ? dataFromHive[0] : '',
      //         batterySavedValue: dataFromHive.length > 0 ? dataFromHive[1] : '')
      //     : SettingData(
      //         fileData:
      //             "Discover - AGM=${Discover}\nExide - GEL=${Excide}\nTrojan - WET=${Trojon}\nLithium =${Lithium}",
      //         batteryBrand: '',
      //         batterySavedValue: '')));
    }
  }

  // _fetchingDataFromHive() async {
  //   // var box = await Hive.openBox(SETUP);
  //   // var configBox = await Hive.openBox("configBox");
  //   // if (box.isNotEmpty) {
  //   //   dataFromHive = box.get(SETUP);
  //   // }
  //   // if (configBox.isNotEmpty) {
  //   //   CONFIG_FILE = configBox.get("configData");
  //   // }
  //   // await box.close();
  // }

  void showToast(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

// ********************* Checking and getting user permission *************************

  void requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.bluetoothAdvertise,
      Permission.location,
    ].request();

    if (statuses[Permission.bluetoothScan]!.isDenied ||
        statuses[Permission.bluetoothConnect]!.isDenied ||
        statuses[Permission.bluetoothAdvertise]!.isDenied ||
        statuses[Permission.location]!.isDenied) {
      DialogUtils.showCustomDialog(context,
          title: "Permission",
          alertWidget:
              Text("Please grant us permission to operate fully functionally."),
          buttonText: "Open Settings", actionCall: () {
        openAppSettings();
      });
    } else if (statuses[Permission.bluetoothScan]!.isPermanentlyDenied ||
        statuses[Permission.bluetoothConnect]!.isPermanentlyDenied ||
        statuses[Permission.bluetoothAdvertise]!.isPermanentlyDenied ||
        statuses[Permission.location]!.isPermanentlyDenied) {
      DialogUtils.showCustomDialog(context,
          title: "Permission",
          alertWidget:
              Text("Please grant us permission to operate fully functionally."),
          buttonText: "Open Settings", actionCall: () {
        openAppSettings();
      });
    } else {
      connectToDevice();
    }
  }

// ********************* Connect with already connected devices *************************

  void connectToDevice() async {
    try {
      List<BluetoothDevice> devices = await flutterBlue.connectedDevices;
      for (BluetoothDevice d in devices) {
        if (d.id.toString().substring(0, 8) == deviceId &&
            d.name.contains("JDY")) {
          device = d;
          connected = true;
          BLUETOOTH_NAME = d.name;
          BLUETOOTH_MAC = d.id.toString();

          _readData();
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

        flutterBlue
            .scan(timeout: const Duration(seconds: 10))
            .listen((event) async {
          if (event.device.type == BluetoothDeviceType.le) {
            print(event.device.id);
            String scannedId = event.device.id.toString();

            if (scannedId.substring(0, 8) == deviceId &&
                event.device.name.contains("JDY")) {
              device = event.device;
              connectDevice();
            }
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
      BLUETOOTH_NAME = device!.name;
      flutterBlue.stopScan();
      connected = true;
      BLUETOOTH_MAC = device!.id.toString();
      _readData();
      discoverServices();
      setState(() {});
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
    //_fetchingDataFromHive();

    //  readOrWriteData();
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
            Text(
              'Please turn on the bluetooth.',
              style: Theme.of(context)
                  .primaryTextTheme
                  .subtitle2
                  ?.copyWith(color: Colors.black, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  _readData() async {
    is_exist = await FileUtils().searchFile(BLUETOOTH_MAC);
    if (is_exist) {
      String fileData = await FileUtils().readFile(BLUETOOTH_MAC);
      String brandName = fileData
          .split('\n')
          .take(fileData.split('\n').length - 1)
          .where((element) => element.startsWith('_'))
          .first
          .split("=")[0]
          .substring(1)
          .trim();
      BRANDNAME = brandName;
      String brandValue = fileData
          .split('\n')
          .take(fileData.split('\n').length - 1)
          .where((element) => element.startsWith('_'))
          .first
          .split("=")[1];
      CRC = fileData
          .split('\n')
          .take(fileData.split('\n').length - 1)
          .where((element) => element.startsWith('_'))
          .first
          .split(';')
          .where((element) => element.startsWith('C:50:'))
          .first
          .split(":")[2];
      fileSelectedData = fileData
          .split('\n')
          .take(fileData.split('\n').length - 1)
          .where((element) => element.startsWith('_'))
          .first
          .split("=")[1];
      CONFIG_FILE = fileData.split('\n').last.split("=");
      context.read<SettingBloc>().add(UpdateSettingData(SettingData(
          fileData: fileData,
          batteryBrand: brandName,
          batterySavedValue: brandValue)));
    }
  }

  _scanOffWidget(String data) {
    bool scanOFff = false;
    return Scaffold(
      body: Center(
          child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            data,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black, fontSize: 20),
          ),
          SizedBox(
            height: 40,
          ),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                  primary: Colors.blueAccent,
                  maximumSize: Size(150, 70),
                  minimumSize: Size(125, 50)),
              child: Text(
                "Rescan",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              onPressed: () {
                requestPermissions();
                scanOFff = true;
                scanStoped = false;
                setState(() {});
              }),
          scanOFff ? CircularProgressIndicator() : Container()
        ],
      )),
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
              connected = false;
              return _bluetoothOffWidget();
            } else if (snapshot.data == BluetoothState.on) {
              if (!scanStoped) requestPermissions();
              Timer.periodic(Duration(seconds: 20), (timer) {
                if (!connected) {
                  // FlutterBluePlus.instance.stopScan();
                  setState(() {
                    scanStoped = true;
                    isShown = true;
                  });
                }
              });
            }
            return snapshot.data == BluetoothState.on
                ? scanStoped
                    ? _scanOffWidget("Couldn't locate charger. Please scan for charger again.")
                    : StreamBuilder<BluetoothDeviceState>(
                        stream: device?.state,
                        builder: (context, snapShot) {
                          if (snapShot.data == BluetoothDeviceState.connected) {
                            return Scaffold(
                              body: _pageNo[state],
                              bottomNavigationBar: _bottomBar(state),
                            );
                          } else if (snapShot.data ==
                              BluetoothDeviceState.disconnected) {
                            return _scanOffWidget("Bluetooth is disconnected.");
                          } else {
                            return Scaffold(
                              body: Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                        })
                : Scaffold(
                    body: Container(),
                  );
          });
    });
  }
}
