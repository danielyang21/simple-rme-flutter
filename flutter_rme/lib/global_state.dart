import 'package:flutter/foundation.dart';
import '../models/analyte.dart';

class GlobalState with ChangeNotifier {
  final List<Analyte> _selectedAnalytes = [];

  List<Analyte> get selectedAnalytes => _selectedAnalytes;

  // Add new analytes without clearing existing ones
  void addAnalytes(List<Analyte> newAnalytes) {
    // Avoid duplicates
    for (var analyte in newAnalytes) {
      if (!_selectedAnalytes.any((a) => a == analyte)) {
        _selectedAnalytes.add(analyte);
      }
    }
    notifyListeners();
  }

  // Remove specific analytes
  void removeAnalytes(List<Analyte> analytesToRemove) {
    _selectedAnalytes.removeWhere((a) => analytesToRemove.contains(a));
    notifyListeners();
  }

  // Clear all analytes
  void clearAllAnalytes() {
    _selectedAnalytes.clear();
    notifyListeners();
  }
}