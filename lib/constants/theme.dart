import 'package:flutter/material.dart';

class CustomColor {
  static const primary = MaterialColor(0xFF1DB954, {
    50: Color(0xFFE5F5EA),
    100: Color(0xFFBFE6CB),
    200: Color(0xFF94D5A8),
    300: Color(0xFF68C485),
    400: Color(0xFF4CC965),
    500: Color(0xFF1DB954),
    600: Color(0xFF12823D),
    700: Color(0xFF0F6E32),
    800: Color(0xFF0B5928),
    900: Color(0xFF063D1B),
  });
}

final ThemeData appTheme = ThemeData(
  // --------- General Theme -----------
  brightness: Brightness.dark,
  fontFamily: 'Roboto',
  fontFamilyFallback: const ['Arial', 'Helvetica'],

  // --------- Colors -----------
  primaryColor: const Color(0xFF1DB954),
  primaryColorDark: const Color(0xFF12823D),
  primaryColorLight: const Color(0xFF4CC965),
  primarySwatch: const MaterialColor(0xFF1DB954, {
    50: Color(0xFFE5F5EA),
    100: Color(0xFFBFE6CB),
    200: Color(0xFF94D5A8),
    300: Color(0xFF68C485),
    400: Color(0xFF4CC965),
    500: Color(0xFF1DB954),
    600: Color(0xFF12823D),
    700: Color(0xFF0F6E32),
    800: Color(0xFF0B5928),
    900: Color(0xFF063D1B),
  }),
  scaffoldBackgroundColor: const Color(0xFF1C1C1E),
  canvasColor: const Color(0xFF1C1C1E),
  cardColor: const Color(0xFF2C2C2E),
  dialogBackgroundColor: const Color(0xFF2C2C2E),
  disabledColor: Colors.grey[700],
  dividerColor: Colors.grey[700],
  focusColor: const Color(0xFF1DB954),
  highlightColor: const Color(0xFF2E2E2F),
  hintColor: Colors.grey[500],
  hoverColor: const Color(0xFF3A3A3C),
  indicatorColor: const Color(0xFF1DB954),
  secondaryHeaderColor: const Color(0xFF1DB954),
  shadowColor: Colors.black54,
  splashColor: const Color(0xFF1DB954).withOpacity(0.2),
  unselectedWidgetColor: Colors.grey[600],

  // --------- Input Fields -----------
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF2C2C2E),
    hintStyle: TextStyle(color: Colors.grey[500]),
    labelStyle: const TextStyle(color: Colors.white),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: Colors.grey[700]!),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFF1DB954)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: Colors.grey[700]!),
    ),
  ),
  textSelectionTheme: TextSelectionThemeData(
    cursorColor: const Color(0xFF1DB954),
    selectionColor: const Color(0xFF1DB954).withOpacity(0.5),
    selectionHandleColor: const Color(0xFF1DB954),
  ),

  // --------- Buttons -----------
  buttonTheme: ButtonThemeData(
    buttonColor: const Color(0xFF1DB954),
    disabledColor: Colors.grey[700],
    textTheme: ButtonTextTheme.primary,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF1DB954),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: const Color(0xFF1DB954),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
  toggleButtonsTheme: ToggleButtonsThemeData(
    fillColor: const Color(0xFF1DB954),
    selectedColor: Colors.white,
    color: Colors.grey[600],
    borderRadius: BorderRadius.circular(8),
    borderColor: Colors.grey[700],
    selectedBorderColor: const Color(0xFF1DB954),
  ),

  // --------- Other Widgets -----------
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF1C1C1E),
    elevation: 0,
    iconTheme: IconThemeData(color: Colors.white),
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: const Color(0xFF1C1C1E),
    selectedItemColor: const Color(0xFF1DB954),
    unselectedItemColor: Colors.grey[600],
    showUnselectedLabels: true,
  ),
  tabBarTheme: TabBarTheme(
    indicator: const UnderlineTabIndicator(
      borderSide: BorderSide(color: Color(0xFF1DB954), width: 2),
    ),
    labelColor: Colors.white,
    unselectedLabelColor: Colors.grey[600],
    labelStyle: const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
    ),
    unselectedLabelStyle: const TextStyle(
      fontWeight: FontWeight.normal,
      fontSize: 14,
    ),
  ),
  cardTheme: CardTheme(
    color: const Color(0xFF2C2C2E),
    shadowColor: Colors.black54,
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
  ),
  checkboxTheme: CheckboxThemeData(
    checkColor: WidgetStateProperty.all(Colors.white),
    fillColor: WidgetStateProperty.all(const Color(0xFF1DB954)),
    side: BorderSide(color: Colors.grey[700]!),
  ),
  datePickerTheme: DatePickerThemeData(
    backgroundColor: const Color(0xFF2C2C2E),
    dayForegroundColor: WidgetStateProperty.all(Colors.white),
    yearForegroundColor: WidgetStateProperty.all(Colors.white),
    headerBackgroundColor: const Color(0xFF1DB954),
    headerForegroundColor: Colors.white,
  ),
  dataTableTheme: DataTableThemeData(
    dataRowColor: WidgetStateProperty.all(const Color(0xFF2C2C2E)),
    headingRowColor: WidgetStateProperty.all(const Color(0xFF1DB954)),
    headingTextStyle:
        const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    dataTextStyle: const TextStyle(color: Colors.white),
  ),
  dialogTheme: DialogTheme(
    backgroundColor: const Color(0xFF2C2C2E),
    titleTextStyle: const TextStyle(
        color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
    contentTextStyle: const TextStyle(color: Colors.white, fontSize: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
  ),
  dividerTheme: DividerThemeData(
    color: Colors.grey[700],
    thickness: 1,
    space: 20,
  ),
  drawerTheme: const DrawerThemeData(
    backgroundColor: Color(0xFF1C1C1E),
  ),
  dropdownMenuTheme: DropdownMenuThemeData(
    menuStyle: MenuStyle(
      backgroundColor: WidgetStateProperty.all(const Color(0xFF2C2C2E)),
      elevation: WidgetStateProperty.all(4),
    ),
  ),
  timePickerTheme: const TimePickerThemeData(
    backgroundColor: Color(0xFF2C2C2E),
    dialHandColor: Color(0xFF1DB954),
    dialBackgroundColor: Color(0xFF3A3A3C),
    hourMinuteTextColor: Colors.white,
    entryModeIconColor: Colors.white,
  ),

  // --------- Rest -----------
  textTheme: TextTheme(
    displayLarge: const TextStyle(
        color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold),
    displayMedium: const TextStyle(
        color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold),
    displaySmall: const TextStyle(
        color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
    headlineLarge: const TextStyle(
        color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
    headlineMedium: const TextStyle(
        color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
    headlineSmall: const TextStyle(
        color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
    titleLarge: const TextStyle(
        color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
    titleMedium: const TextStyle(
        color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
    titleSmall: TextStyle(color: Colors.grey[500], fontSize: 14),
    bodyLarge: const TextStyle(color: Colors.white, fontSize: 16),
    bodyMedium: TextStyle(color: Colors.grey[500], fontSize: 14),
    bodySmall: TextStyle(color: Colors.grey[500], fontSize: 12),
    labelLarge: const TextStyle(
        color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
    labelMedium: const TextStyle(color: Colors.white, fontSize: 12),
    labelSmall: TextStyle(color: Colors.grey[500], fontSize: 10),
  ),
  iconTheme: const IconThemeData(color: Colors.white),
);
