abstract class ParseDataEvent {}

class ParsingList extends ParseDataEvent {
  final List<String> incomingData;

  ParsingList(this.incomingData);
}
