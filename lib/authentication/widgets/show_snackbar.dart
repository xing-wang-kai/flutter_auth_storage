import 'package:firebase_with_flutter/_core/my_colors.dart';
import 'package:flutter/material.dart';

void showSnackBar({
  required BuildContext context,
  required String message,
  bool isError = true,
}) {
  SnackBar snackBar = SnackBar(
    content: Text(message),
    backgroundColor: (isError) ? MyColors.red : Colors.green,
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
