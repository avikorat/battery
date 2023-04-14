import 'package:battery/bloc/loading/loading_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoadingBloc extends Bloc<LoadingEvent, bool>
    implements StateStreamable<bool> {
  LoadingBloc() : super(false) {
    on<Loading>((event, emit) {
      emit(event.incomingData);
    });
  }
}
