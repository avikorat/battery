
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

abstract class TabServiceEvent  {
}

class UpdateTabList extends TabServiceEvent {
  final int tab;

  UpdateTabList(this.tab);
}
