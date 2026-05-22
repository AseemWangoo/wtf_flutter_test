import 'package:flutter/material.dart';

/// Brand and semantic colors per assessment spec.
abstract final class AppColors {
  // Guru (Member)
  static const Color guruPrimary = Color(0xFF1769E0);

  // Trainer
  static const Color trainerPrimary = Color(0xFFE50914);

  // Shared semantic
  static const Color success = Color(0xFF12B76A);
  static const Color warning = Color(0xFFF79009);
  static const Color error = Color(0xFFD92D20);

  // Chat bubbles
  static const Color memberBubble = Color(0xFF1769E0);
  static const Color trainerBubble = Color(0xFFE50914);

  // Neutrals
  static const Color neutral50 = Color(0xFFF9FAFB);
  static const Color neutral100 = Color(0xFFF2F4F7);
  static const Color neutral700 = Color(0xFF344054);
  static const Color neutral900 = Color(0xFF101828);
}
