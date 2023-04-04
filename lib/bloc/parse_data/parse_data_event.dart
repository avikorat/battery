abstract class ParseDataEvent {}

class ParsingList extends ParseDataEvent {
  final List<dynamic> incomingData;

  ParsingList(this.incomingData);
}
