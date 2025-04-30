import 'package:flutter/material.dart';

import '../_core/my_colors.dart';

ThemeData generalThemeData = ThemeData(
  primarySwatch: MyColors.brown,
  scaffoldBackgroundColor: MyColors.green,
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: MyColors.red,
  ),
  listTileTheme: const ListTileThemeData(iconColor: MyColors.blue),
  appBarTheme: AppBarTheme(
    toolbarHeight: 72,
    centerTitle: true,
    elevation: 0,
    backgroundColor: MyColors.brown,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
    ),
    iconTheme: const IconThemeData(
      color: Colors.white, // Cor dos ícones (menu, voltar etc.)
    ),
    actionsIconTheme: const IconThemeData(
      color: Colors.white, // Cor dos ícones das actions (à direita)
    ),
    titleTextStyle: const TextStyle(
      color: Colors.white, // Cor do texto do título
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),
);