import 'package:flutter/material.dart';

Future popUpOrigemImagem({required BuildContext context,required Function(bool) selecinarOrigem, String title = "Editar foto de perfil"}) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
              ),
            ),
            TextButton(
              onPressed: () => selecinarOrigem(true),
              child: const Text("Camera"),
            ),
            TextButton(
              onPressed: () => selecinarOrigem(false),
              child: const Text("Galeria"),
            )
          ],
        ),
      );
    },
  );
}
