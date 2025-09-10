import 'package:flutter/material.dart';

class FontSizeProvider with ChangeNotifier {
  double _fontSize = 16.0;

  double get fontSize => _fontSize;

  void setFontSize(double newSize) {
    _fontSize = newSize;
    notifyListeners();
  }
}
