import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/models/conversa.dart';
import 'package:myapp/models/usuario.dart';

class ConversasPage extends StatefulWidget {
  const ConversasPage({super.key});

  @override
  State<ConversasPage> createState() => _ConversasPageState();
}

class _ConversasPageState extends State<ConversasPage> {
  List<DocumentSnapshot> conversas = [];
  final db = FirebaseFirestore.instance;
  String? idUsuarioLogado;
  final controller = StreamController<QuerySnapshot>.broadcast();

  abrirConversa(Usuario usuario) {
    Navigator.pushNamed(context, "/conversa", arguments: usuario);
  }

  recuperarDados() {
    final auth = FirebaseAuth.instance;
    idUsuarioLogado = auth.currentUser!.uid;
    adicionarListenerConversas();
  }

  adicionarListenerConversas() {
    final stream = db
        .collection("conversas")
        .doc(idUsuarioLogado!)
        .collection("ultimas_conversas")
        .snapshots();
    stream.listen((dados) {
      controller.add(dados);
    });
  }

  @override
  void initState() {
    super.initState();
    recuperarDados();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    controller.close();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: controller.stream,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return const Column(
              children: [
                Text("Carregando conversas"),
                CircularProgressIndicator()
              ],
            );
          case ConnectionState.active:
          case ConnectionState.done:
            if (snapshot.hasError) {
              return const Text("Erro ao carregar mensagens");
            } else {
              final querySnapshot = snapshot.data;
              if (querySnapshot!.docs.isEmpty) {
                return const Center(
                  child: Text(
                    "Você não tem nenhuma mensagem ainda",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              } else {
                conversas = querySnapshot.docs.toList();
                return Expanded(
                  child: ListView.builder(
                    itemCount: conversas.length,
                    itemBuilder: (context, index) {
                      final item =
                          conversas[index].data() as Map<String, dynamic>;
                      final conversa = Conversa.fromMap(item);
                      final usuario = Usuario(
                        idUsuario: conversa.idDestinatario,
                        urlImagem: conversa.urlImagem,
                        nome: conversa.nome,
                        email: "",
                      );

                      final DateTime hora = conversa.hora.toDate();
                      String data = "${hora.hour} : ${hora.minute}";
                      return ListTile(
                        onTap: () => abrirConversa(usuario),
                        title: Text(
                          conversa.nome,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        leading: CircleAvatar(
                          radius: 30,
                          backgroundImage: NetworkImage(
                            conversa.urlImagem,
                          ),
                        ),
                        subtitle: conversa.tipo == "texto"
                            ? Text(conversa.mensagem)
                            : const Row(
                                children: [
                                  Icon(
                                    Icons.camera_alt,
                                    size: 17,
                                  ),
                                  Text("Imagem"),
                                ],
                              ),
                        trailing: Text(data),
                      );
                    },
                  ),
                );
              }
            }
        }
      },
    );
  }
}
