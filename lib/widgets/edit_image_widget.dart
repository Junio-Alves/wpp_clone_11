import 'package:flutter/material.dart';

Future popUpEditImagem(BuildContext context, Function(bool) editarFoto) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Editar foto de perfil",
              style: TextStyle(
                fontSize: 20,
              ),
            ),
            TextButton(
              onPressed: () => editarFoto(true),
              child: const Text("Camera"),
            ),
            TextButton(
              onPressed: () => editarFoto(false),
              child: const Text("Galeria"),
            )
          ],
        ),
      );
    },
  );
}
