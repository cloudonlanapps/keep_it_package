import 'dart:developer' as dev;
import 'dart:math' as math;

import 'package:characters/characters.dart';

//import '../../app_logger.dart';

extension UtilExtensionOnString on String {
  bool isURL() {
    try {
      final uri = Uri.parse(this);
      // Check if the scheme is non-empty to ensure it's a valid URL
      return uri.scheme.isNotEmpty;
    } catch (e) {
      return false; // Parsing failed, not a valid URL
    }
  }

  void printString({String prefix = ''}) {
    dev.log('$prefix $this', name: 'printString');
  }

  String uptoLength(int N) {
    return substring(0, math.min(length, N));
  }

  String capitalizeFirstLetter() {
    if (isEmpty) return this; // Return the string as is if it's empty
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  String capitalizeWords() {
    return split(RegExp(r'\s+')) // split on spaces/tabs
        .map((word) {
          if (word.isEmpty) return word;
          final first = word.characters.first.toUpperCase();
          final rest = word.characters.skip(1).toString();
          return '$first$rest';
        })
        .join(' ');
  }
}

extension UtilExtensionOnStringNullable on String? {
  String? capitalizeFirstLetter() {
    if (this == null) {
      return null;
    }
    return this!.capitalizeFirstLetter();
  }

  String? capitalizeWords(String name) {
    if (this == null) {
      return null;
    }
    return this!.capitalizeWords();
  }

  int? toInt() {
    if (this == null) return null;
    return int.parse(this!);
  }
}
