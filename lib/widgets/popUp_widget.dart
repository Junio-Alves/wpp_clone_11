import 'package:flutter/material.dart';

Future popUpDialog(
    {required BuildContext context,
    required String titleText,
    Widget? content}) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(
          titleText,
          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        content: content ??
            Text(
              titleText,
              style: const TextStyle(color: Colors.red, fontSize: 22),
            ),
        actions: [
          content != null
              ? Container()
              : TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Confirmar"),
                )
        ],
      );
    },
  );
}
