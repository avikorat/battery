import 'package:battery/bloc/parse_data/parse_data_event.dart';
import 'package:battery/models/data_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ParseDataBloc extends Bloc<ParseDataEvent, List<dynamic>> implements StateStreamable<List<dynamic>> {
  ParseDataBloc() : super([]) {
    on<ParsingList>((event, emit) {
      var newList = event.incomingData;
      emit(event.incomingData);
    });
  }
}
