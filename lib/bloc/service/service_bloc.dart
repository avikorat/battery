import 'package:battery/bloc/service/service_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class ServiceBloc extends Bloc<UpdateServiceList ,List<BluetoothService>>
    implements StateStreamable<List<BluetoothService>> {
  ServiceBloc() : super([]) {
    on<UpdateServiceList>((event, emit) {
      var newList = event.services;
      emit(newList);
    });

  }
}