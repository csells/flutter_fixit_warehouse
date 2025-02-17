import 'package:flutter/foundation.dart';

class GardeningData extends ChangeNotifier {
  String? _selectedAction;

  String? get selectedAction => _selectedAction;

  set selectedAction(String? value) {
    _selectedAction = value;
    notifyListeners();
  }
}
