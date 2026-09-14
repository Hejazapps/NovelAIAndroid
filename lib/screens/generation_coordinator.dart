import 'package:flutter/foundation.dart';

enum GenerationType {
  book,
  screenplay,
}

class GenerationCoordinator extends ChangeNotifier {
  GenerationCoordinator._();

  static final GenerationCoordinator shared = GenerationCoordinator._();

  GenerationType? _activeType;

  bool get isBusy => _activeType != null;
  GenerationType? get activeType => _activeType;

  String get activeLabel {
    switch (_activeType) {
      case GenerationType.book:
        return 'book';
      case GenerationType.screenplay:
        return 'screenplay';
      case null:
        return '';
    }
  }

  bool tryStart(GenerationType type) {
    if (_activeType != null) return false;

    _activeType = type;
    debugPrint(
      '🔒 [GenerationCoordinator] Started ${type.name} generation',
    );
    notifyListeners();
    return true;
  }

  void finish(GenerationType type) {
    if (_activeType != type) return;

    debugPrint(
      '🔓 [GenerationCoordinator] Finished ${type.name} generation',
    );
    _activeType = null;
    notifyListeners();
  }

  void forceReset() {
    _activeType = null;
    notifyListeners();
  }
}
