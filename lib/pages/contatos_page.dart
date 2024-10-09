import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/models/usuario.dart';

class ContatosPage extends StatefulWidget {
  const ContatosPage({super.key});

  @override
  State<ContatosPage> createState() => _ContatosPageState();
}

class _ContatosPageState extends State<ContatosPage> {
  Future<List<Usuario>> recuperarContatos() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final store = FirebaseFirestore.instance;
    final querySnapshot = await store.collection("usuarios").get();
    List<Usuario> listaUsuarios = [];
    for (final usuario in querySnapshot.docs) {
      if (usuario.id != currentUser!.uid) {
        final dados = usuario.data();
        print(usuario.id);
        final user = Usuario(
          idUsuario: usuario.id,
          nome: dados["Nome"],
          email: dados["Email"],
          urlImagem: dados["Imagem"],
        );
        listaUsuarios.add(user);
      }
    }
    return listaUsuarios;
  }

  abrirConversa(Usuario usuario) {
    Navigator.pushNamed(context, "/conversa", arguments: usuario);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    recuperarContatos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: recuperarContatos(),
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
              List<Usuario> itens = snapshot.data!;
              return ListView.builder(
                itemCount: itens.length,
                itemBuilder: (context, index) {
                  final usuario = itens[index];
                  return Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: ListTile(
                      onTap: () => abrirConversa(usuario),
                      leading: CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(
                          usuario.urlImagem ?? "",
                        ),
                      ),
                      title: Text(
                        usuario.nome!,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  );
                },
              );
            default:
              return Container();
          }
        },
      ),
    );
  }
}
