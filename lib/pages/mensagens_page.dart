import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myapp/models/mensagem.dart';
import 'package:myapp/models/usuario.dart';
import 'package:myapp/widgets/caixa_mensagem_widget.dart';
import 'package:myapp/widgets/edit_image_widget.dart';
import 'package:myapp/widgets/image_align_widget.dart';
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
      //salvando para usuario logado
      salvarMensagem(
        idRemetente: idUsuarioLogado!,
        idDestinatario: idUsuarioDestinatario!,
        mensagem: mensagem,
      );
      //salvando para remetente
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
  
  enviarImagem(File image) async{
    final storage = FirebaseStorage.instance;
    final auth = FirebaseAuth.instance;
    if (auth.currentUser != null) {
      final pastaRaiz =
          storage.ref().child("perfil").child("${auth.currentUser!.uid}.jpg");
      await pastaRaiz.putFile(image);
      final urlImage = await pastaRaiz.getDownloadURL();
      
      final mensagem = Mensagem(idUsuario: idUsuarioLogado!, mensagem: "", urlImagem: urlImage, tipo: "imagem", hora: Timestamp.now(),);
      salvarMensagem(idRemetente: idUsuarioLogado!, idDestinatario: idUsuarioDestinatario!, mensagem: mensagem,);
       salvarMensagem(idRemetente: idUsuarioDestinatario!, idDestinatario: idUsuarioLogado!, mensagem: mensagem,);
    }

  }

  escolherOrigem(bool isCamera) async{
    final imagePicker = ImagePicker();
    XFile? pickedImage;
    File? image;
    if(isCamera == true){
      pickedImage = await imagePicker.pickImage(source: ImageSource.camera);
    }else{
      pickedImage = await imagePicker.pickImage(source: ImageSource.gallery);
    }
    if(pickedImage != null){
      image = File(pickedImage.path);
      enviarImagem(image);
    }

  }
  enviarFoto() {
    popUpOrigemImagem(context:  context,selecinarOrigem:  escolherOrigem,title: "Escolha a origem");
  }
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
                    return item["tipo"] == "texto" ? MensagemAlignWidget(
                      aligment: aligment,
                      larguraContainer: larguraContainer,
                      color: color,
                      item: item,
                    ) : ImageAlignWidget(aligment: aligment, larguraContainer: larguraContainer, color: color, item: item) ;
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
