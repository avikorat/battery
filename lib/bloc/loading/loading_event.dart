abstract class LoadingEvent {}

class Loading extends LoadingEvent {
  final bool incomingData;

  Loading(this.incomingData);
}
