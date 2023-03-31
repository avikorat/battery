
import 'package:battery/bloc/tab/tab_service_events.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TabServiceBloc extends Bloc<UpdateTabList ,int>
    implements StateStreamable<int> {
  TabServiceBloc() : super(0) {
    on<UpdateTabList>((event, emit) {
      var newList = event.tab;
      emit(newList);
    });
  }
}