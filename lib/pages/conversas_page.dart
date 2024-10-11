import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/models/usuario.dart';

class ConversasPage extends StatefulWidget {
  const ConversasPage({super.key});

  @override
  State<ConversasPage> createState() => _ConversasPageState();
}

class _ConversasPageState extends State<ConversasPage> {
  String? idUsuarioLogado;
  recuperarConversas() async {
    final store = FirebaseFirestore.instance;
    final auth = FirebaseAuth.instance;
    idUsuarioLogado = auth.currentUser!.uid;
    if (idUsuarioLogado != null) {
      final querySnapshot =
          await store.collection("mensagens").doc("$idUsuarioLogado").get();
      print("aqui");
      final data = querySnapshot.data() as Map<String, dynamic>;
      data.forEach((key, value) {
        print("$key:$value");
      });
    }
  }

  abrirConversa(Usuario usuario) {
    Navigator.pushNamed(context, "/conversa", arguments: usuario);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: recuperarConversas(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    Text("Carregando Contatos!")
                  ],
                ),
              );

            case ConnectionState.active:
            case ConnectionState.done:
              return Container();
            default:
              return Container();
          }
        },
      ),
    );
  }
}
