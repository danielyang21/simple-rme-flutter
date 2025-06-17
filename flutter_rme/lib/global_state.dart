import 'package:flutter/foundation.dart';
import '../models/analyte.dart';

class GlobalState with ChangeNotifier {
  final List<Analyte> _selectedAnalytes = [];

  List<Analyte> get selectedAnalytes => List.unmodifiable(_selectedAnalytes);

  void addAnalytes(List<Analyte> newAnalytes) {
    bool changed = false;
    
    for (var analyte in newAnalytes) {
      if (!_selectedAnalytes.any((a) => a.name == analyte.name)) {
        _selectedAnalytes.add(analyte);
        changed = true;
        debugPrint('Added analyte: ${analyte.name}'); // Debug log
      }
    }

    if (changed) {
      debugPrint('Total analytes after add: ${_selectedAnalytes.length}');
      notifyListeners();
    }
  }

  // Remove specific analytes
  void removeAnalytes(List<Analyte> analytesToRemove) {
    _selectedAnalytes.removeWhere((a) => analytesToRemove.contains(a));
    notifyListeners();
  }

  void removeAnalyteByName(String name) {
    _selectedAnalytes.removeWhere((analyte) => analyte.name == name);
    notifyListeners();
  }

  // Clear all analytes
  void clearAllAnalytes() {
    _selectedAnalytes.clear();
    notifyListeners();
  }
}
