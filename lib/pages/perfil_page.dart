import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/widgets/avatar_image_widget.dart';
import 'package:myapp/widgets/edit_name_widget.dart';
import 'package:myapp/widgets/popUp_widget.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  File? image;
  final ImagePicker imagePicker = ImagePicker();
  XFile? pickedImage;
  String? idUsuarioLogado;
  bool loadingImage = false;
  String? imageUrl;
  String nomeUsuario = "";
  final nomeEditController = TextEditingController();

  editarFoto(bool isCamera) async {
    if (isCamera == true) {
      pickedImage = await imagePicker.pickImage(source: ImageSource.camera);
    } else {
      pickedImage = await imagePicker.pickImage(source: ImageSource.gallery);
    }
    if (pickedImage != null) {
      setState(() {
        image = File(pickedImage!.path);
        loadingImage = true;
        uploadImagem();
      });
    }
  }

  Future uploadImagem() async {
    final storage = FirebaseStorage.instance;
    final pastaRaiz = storage.ref();
    final arquivo = pastaRaiz.child("perfil").child("$idUsuarioLogado.jpg");
    try {
      await arquivo.putFile(image!);
      imageUrl = await arquivo.getDownloadURL();
      final store = FirebaseFirestore.instance;
      await store
          .collection("usuarios")
          .doc(idUsuarioLogado)
          .update({"Imagem": imageUrl});
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) popUpDialog(context: context, titleText: e.toString());
    }
    setState(() {
      loadingImage = false;
    });
  }

  editarNome() {
    editNameBottomSheet(context, nomeEditController, atualizarNome);
  }

  recuperarDadosUsuario() async {
    final auth = FirebaseAuth.instance;
    final usuarioLogado = auth.currentUser;
    idUsuarioLogado = usuarioLogado!.uid;
  }

  recuperarUrlImagem() async {
    loadingImage = true;
    final store = FirebaseFirestore.instance;
    final DocumentSnapshot userDocument =
        await store.collection("usuarios").doc(idUsuarioLogado).get();
    if (userDocument.exists) {
      Map<String, dynamic> userData =
          userDocument.data() as Map<String, dynamic>;
      setState(() {
        imageUrl = userData["Imagem"];
        loadingImage = false;
      });
    }
  }

  recuperarNome() async {
    final store = FirebaseFirestore.instance;
    final DocumentSnapshot userDocument =
        await store.collection("usuarios").doc(idUsuarioLogado).get();
    if (userDocument.exists) {
      Map<String, dynamic> userData =
          userDocument.data() as Map<String, dynamic>;
      setState(() {
        nomeUsuario = userData["Nome"];
        nomeEditController.text = nomeUsuario;
      });
    }
  }

  atualizarNome() async {
    final store = FirebaseFirestore.instance;
    try {
      await store
          .collection("usuarios")
          .doc(idUsuarioLogado)
          .update({"Nome": nomeEditController.text});
      recuperarNome();
    } catch (e) {
      if (mounted) popUpDialog(context: context, titleText: e.toString());
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    recuperarDadosUsuario();
    recuperarUrlImagem();
    recuperarNome();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
        title: const Text(
          "Configurações",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(
              height: 50,
            ),
            AvatarImageWidget(
              editarFoto: editarFoto,
              loadingImage: loadingImage,
              imageUrl: imageUrl,
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Nome:"),
                  Text(
                    nomeUsuario,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              trailing: IconButton(
                onPressed: () => editarNome(),
                icon: const Icon(Icons.edit),
              ),
              subtitle: const Text(
                "Esse é o nome que estará visivel para os seus contatos.",
              ),
            )
          ],
        ),
      ),
    );
  }
}
