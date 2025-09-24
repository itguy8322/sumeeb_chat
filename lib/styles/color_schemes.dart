import 'package:flutter/material.dart';

const lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFF006C50),
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFF84F8CC),
  onPrimaryContainer: Color(0xFF002116),
  secondary: Color(0xFF4C6359),
  onSecondary: Color(0xFFFFFFFF),
  secondaryContainer: Color(0xFFCEE9DB),
  onSecondaryContainer: Color(0xFF092017),
  tertiary: Color(0xFF3F6375),
  onTertiary: Color(0xFFFFFFFF),
  tertiaryContainer: Color(0xFFC2E8FD),
  onTertiaryContainer: Color(0xFF001F2A),
  error: Color(0xFFBA1A1A),
  onError: Color(0xFFFFFFFF),
  errorContainer: Color(0xFFFFDAD6),
  onErrorContainer: Color(0xFF410002),
  outline: Color(0xFF707974),
  surface: Color(0xFFF8FAF6),
  onSurface: Color(0xFF191C1A),
  surfaceContainerHighest: Color(0xFFDBE5DE),
  onSurfaceVariant: Color(0xFF404944),
  inverseSurface: Color(0xFF2E312F),
  onInverseSurface: Color(0xFFEFF1EE),
  inversePrimary: Color(0xFF67DBB1),
  shadow: Color(0xFF000000),
  surfaceTint: Color(0xFF006C50),
  outlineVariant: Color(0xFFBFC9C2),
  scrim: Color(0xFF000000),
);

const myColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Colors.amber, //Color(0xFF67DBB1),
  onPrimary: Colors.black,
  primaryContainer: Colors.white,
  onPrimaryContainer: Color(0xFF84F8CC),
  secondary: Colors.white,
  onSecondary: Color(0xFF1E352C),
  secondaryContainer: Color(0xFF354C42),
  onSecondaryContainer: Color(0xFFCEE9DB),
  tertiary: Color(0xFFA6CCE0),
  onTertiary: Color(0xFF0A3545),
  tertiaryContainer: Color(0xFF264B5C),
  onTertiaryContainer: Color(0xFFC2E8FD),
  error: Color(0xFFFFB4AB),
  onError: Color(0xFF690005),
  errorContainer: Color(0xFF93000A),
  onErrorContainer: Color(0xFFFFDAD6),
  outline: Color(0xFF89938D),
  surface: Color.fromARGB(255, 12, 0, 64),
  onSurface: Colors.white,
  surfaceContainerHighest: Color(0xFF404944),
  onSurfaceVariant: Color(0xFFBFC9C2),
  inverseSurface: Color(0xFFE1E3E0),
  onInverseSurface: Colors.white,
  inversePrimary: Color(0xFF006C50),
  shadow: Color(0xFF000000),
  surfaceTint: Color(0xFF67DBB1),
  outlineVariant: Color(0xFF404944),
  scrim: Color.fromARGB(255, 12, 0, 64),
);

abstract class Styles {
  //color styles
  //FFBE00
  static const Color colorPrimary = Color(0xff313131);
  static const Color colorSecondary = Color(0xffFFC835);
  static const Color colorWhite = Color(0xffffffff);
  static const Color colorBlack = Color(0xcc000000);
  static const Color colorBackground = Color(0xffF9F9F9);
  static const Color colorFiltersBackground = Color(0xffF9F9f9);
  static const Color colorTextDark = Color(0xff615151);
  static const Color colorTextBlue = Color(0xff007C98);
  static const Color colorTextGreen = Color(0xff06AD17);
  static const Color colorTextRed = Color(0xffEC0E0E);
  static const Color colorTextBlack = Color(0xcc000000);
  static const Color colorTextLightGrey = Color(0xff9C9C9C);
  static const Color colorSuccess = Color(0xff2AA952);
  static const Color colorBarBottomSheet = Color(0xffD8D8D8);
  static const Color colorTextFieldBackground = Color(0xffF1F1F1);
  static const Color colorTextFieldHint = Color(0xff8A8686);
  static const Color colorGray = Color(0xff8A8686);
  static const Color colorTextFieldBorder = Color(0xffdbdbdb);

  static const Color colorTextGomartText = Color(0xff606060);
  static const Color colorSkeletalBackground = Color(0xfffafafa);

  static const Color colorHomeDropdownBorder = Color(0xffEBEBEB);
  static const Color colorHomeDropdownFill = Color(0xffFDFDFD);

  static const Color colorButtonPay = Color(0xffD9EBF0);
  static const Color colorButtonGrey = Color(0xffE8E8E8);
  static const Color colorTransactionItemLogoBg = Color(0xffE19164);

  static const Color colorPromoteAdsPremium = Color(0xffC3E9D2);
}
