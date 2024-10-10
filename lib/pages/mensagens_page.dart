import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myapp/models/mensagem.dart';
import 'package:myapp/models/usuario.dart';
import 'package:myapp/widgets/caixa_mensagem_widget.dart';
import 'package:myapp/widgets/mensagem_align_widget.dart';

class MensagensPage extends StatefulWidget {
  final Usuario usuario;
  const MensagensPage({super.key, required this.usuario});

  @override
  State<MensagensPage> createState() => _MensagensPageState();
}

class _MensagensPageState extends State<MensagensPage> {
  final db = FirebaseFirestore.instance;
  String? idUsuarioLogado;
  String? idUsuarioDestinatario;
  enviarMensagem() {
    final textoMensagem = mensagemController.text;
    if (textoMensagem.isNotEmpty) {
      final mensagem = Mensagem(
        idUsuario: idUsuarioLogado!,
        mensagem: textoMensagem,
        urlImagem: "",
        tipo: "texto",
        hora: Timestamp.now(),
      );
      salvarMensagem(
        idRemetente: idUsuarioLogado!,
        idDestinatario: idUsuarioDestinatario!,
        mensagem: mensagem,
      );
      salvarMensagem(
        idRemetente: idUsuarioDestinatario!,
        idDestinatario: idUsuarioLogado!,
        mensagem: mensagem,
      );
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> recuperarMensagens(
    String idRemetente,
    String idDestinatario,
  ) {
    return db
        .collection("mensagens")
        .doc(idRemetente)
        .collection(idDestinatario)
        .orderBy("hora", descending: false)
        .snapshots();
  }

  salvarMensagem({
    required String idRemetente,
    required String idDestinatario,
    required Mensagem mensagem,
  }) async {
    await db
        .collection("mensagens")
        .doc(idRemetente)
        .collection(idDestinatario)
        .add(
          mensagem.topMap(),
        );
    mensagemController.clear();
  }

  recuperarDadosUsuario() {
    final auth = FirebaseAuth.instance;
    idUsuarioLogado = auth.currentUser!.uid;
    idUsuarioDestinatario = widget.usuario.idUsuario;
  }

  enviarFoto() {}
  final mensagemController = TextEditingController();

  @override
  void initState() {
    super.initState();
    recuperarDadosUsuario();
  }

  @override
  Widget build(BuildContext context) {
    Widget stream = StreamBuilder(
      stream: recuperarMensagens(idUsuarioLogado!, idUsuarioDestinatario!),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return const Center(
              child: Column(
                children: [
                  Text("Carregando mensagens"),
                  CircularProgressIndicator(),
                ],
              ),
            );
          case ConnectionState.active:
          case ConnectionState.done:
            final querySnapshot = snapshot.data;
            if (snapshot.hasError) {
              return const Expanded(
                child: Text("Erro ao carregar dados"),
              );
            } else {
              return Expanded(
                child: ListView.builder(
                  itemCount: querySnapshot!.docs.length,
                  itemBuilder: (context, index) {
                    List<DocumentSnapshot> mensagens = querySnapshot.docs;
                    DocumentSnapshot item = mensagens[index];
                    final larguraContainer =
                        MediaQuery.of(context).size.width * 0.8;
                    final aligment = idUsuarioLogado != item["idUsuario"]
                        ? Alignment.centerLeft
                        : Alignment.centerRight;
                    final color = idUsuarioLogado != item["idUsuario"]
                        ? Colors.white
                        : const Color(0xffd2ffa5);
                    return MensagemAlignWidget(
                      aligment: aligment,
                      larguraContainer: larguraContainer,
                      color: color,
                      item: item,
                    );
                  },
                ),
              );
            }
        }
      },
    );

    return Scaffold(
      backgroundColor: const Color(0xFFECE5DD),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 23,
              backgroundImage: NetworkImage(
                widget.usuario.urlImagem!,
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Text(
              widget.usuario.nome!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Center(
        child: Stack(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/background.png"),
                  fit: BoxFit.cover,
                  opacity: 0.15,
                  colorFilter: ColorFilter.mode(Colors.black, BlendMode.srcIn),
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      stream,
                      CaixaDeMensagem(
                        mensagemController: mensagemController,
                        enviarFoto: enviarFoto,
                        enviarMensagem: enviarMensagem,
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
