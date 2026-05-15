import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF1DB954);

  static bool isDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  static Color background(BuildContext context) {
    return isDark(context) ? const Color(0xFF191414) : const Color(0xFFF7F8FA);
  }

  static Color surface(BuildContext context) {
    return isDark(context) ? const Color(0xFF282828) : Colors.white;
  }

  static Color text(BuildContext context) {
    return isDark(context) ? Colors.white : const Color(0xFF171717);
  }

  static Color mutedText(BuildContext context) {
    return isDark(context) ? Colors.grey : const Color(0xFF666666);
  }

  static Color icon(BuildContext context) {
    return isDark(context) ? Colors.white : const Color(0xFF333333);
  }

  static Color tile(BuildContext context) {
    return isDark(context) ? const Color(0xFF282828) : const Color(0xFFEDEFF2);
  }
}
