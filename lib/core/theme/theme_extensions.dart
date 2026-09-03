import 'package:flutter/material.dart';
import 'app_colors.dart';

extension ThemeContextX on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
  TextTheme get textStyles => Theme.of(this).textTheme;
}
