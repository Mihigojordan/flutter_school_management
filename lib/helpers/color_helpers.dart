import 'package:flutter/material.dart';
import '../app/themes/colors.dart';

bool isDarkmode(BuildContext context){
  return Theme.of(context).brightness == Brightness.dark;
}

Color? svgColorBasedOnDarkMode(BuildContext context) {
  return isDarkmode(context) ?  NepanikarColors.white : null;
}

Color? textColorBasedOnDarkMode(BuildContext context) {
  return customColorsBasedOnDarkMode(context, NepanikarColors.white, null);
}

Color? pdfColorBasedOnDarkMode(BuildContext context) {
  return isDarkmode(context) ? NepanikarColors.primarySwatch.shade700 : null;
}

Color? longTileColorBasedOnDarkMode(BuildContext context){
  return isDarkmode(context) ? NepanikarColors.containerD : null;
}

Color? customColorsBasedOnDarkMode(BuildContext context, Color? darkModeColor1, Color? lightModeColor2){
  return isDarkmode(context) ? darkModeColor1 : lightModeColor2;
}

Color? backgroundColorsBasedOnDarkMode(BuildContext context){
  return customColorsBasedOnDarkMode(context, NepanikarColors.primaryD, NepanikarColors.primary);
}
