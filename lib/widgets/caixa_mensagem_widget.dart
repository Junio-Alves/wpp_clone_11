import 'package:flutter/material.dart';

class CaixaDeMensagem extends StatelessWidget {
  final TextEditingController mensagemController;
  final VoidCallback enviarMensagem;
  final VoidCallback enviarFoto;
  const CaixaDeMensagem({
    super.key,
    required this.mensagemController,
    required this.enviarMensagem,
    required this.enviarFoto,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(
              right: 8,
            ),
            child: SizedBox(
              height: 40,
              child: TextFormField(
                textAlignVertical: TextAlignVertical.bottom,
                controller: mensagemController,
                style: const TextStyle(fontSize: 15),
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.circular(32),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.circular(32),
                  ),
                  errorStyle: const TextStyle(color: Colors.white),
                  hintText: "Digite uma Mensagem",
                  hintStyle: const TextStyle(fontSize: 15),
                  contentPadding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
                  filled: true,
                  fillColor: Colors.white,
                  suffixIcon: IconButton(
                    onPressed: () => enviarFoto(),
                    icon: const Icon(Icons.camera_alt),
                  ),
                ),
              ),
            ),
          ),
        ),
        FloatingActionButton(
          mini: true,
          backgroundColor: Theme.of(context).primaryColor,
          onPressed: () => enviarMensagem(),
          child: const Icon(
            Icons.send,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
