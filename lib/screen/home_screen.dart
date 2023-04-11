import 'package:battery/bloc/setting/setting_bloc.dart';
import 'package:battery/bloc/tab/tab_service_bloc.dart';
import 'package:battery/bloc/tab/tab_service_events.dart';
import 'package:battery/screen/search_bluetooth_screen.dart';
import 'package:battery/screen/main_screen.dart';
import 'package:battery/screen/settings.dart';
import 'package:battery/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:hive/hive.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _pageNo = [
    const MainScreen(),
    const Settings()
  ];

  final _bottomBarItems = const [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
    BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings")
  ];

  // ************** BOTTOM NAV BAR WIDGET ****************

  Widget _bottomBar(int state) {
    return Container(
      height: MediaQuery.of(context).size.height / 13,
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
  @override
  void initState() {
    _fetchingDataFromHive();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
     final arguments = (ModalRoute.of(context)?.settings.arguments ?? <String, dynamic>{}) as Map;
     print(arguments["BluetoothDevice"]);
    return StreamBuilder<BluetoothState>(
        stream: FlutterBluePlus.instance.state,
        initialData: BluetoothState.unknown,
        builder: (c, snapshot) {
          if (arguments["BluetoothDevice"] == null) {
         
            Navigator.pop(context);
            if (snapshot.connectionState == BluetoothState.on) {
              FlutterBluePlus.instance.scan(
                  scanMode: ScanMode.lowPower, timeout: const Duration(seconds: 6));
            }
          }

          return BlocBuilder<TabServiceBloc, dynamic>(
              builder: (context, state) {
            return Scaffold(
              body: _pageNo[state],
              bottomNavigationBar: _bottomBar(state),
            );
          });
        });
  }
}
