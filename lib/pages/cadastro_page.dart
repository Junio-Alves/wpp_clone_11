import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myapp/models/usuario.dart';
import 'package:myapp/widgets/avatar_image_widget.dart';
import 'package:myapp/widgets/popUp_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  bool loadingImage = false;
  String? imageUrl;
  final imagePicker = ImagePicker();
  XFile? pickedImage;
  File? image;
  bool creatingAccount = false;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).unfocus();
    });
    super.initState();
  }

  final formKey = GlobalKey<FormState>();
  final nomeController = TextEditingController(text: "Teste");
  final emailController = TextEditingController(text: "juniophb2003@gmail.com");
  final senhaController = TextEditingController(text: "123456");

  limparTexto() {
    nomeController.clear();
    emailController.clear();
    senhaController.clear();
  }

  validar() {
    if (formKey.currentState!.validate()) {
      final usuario = Usuario(
          idUsuario: "",
          nome: nomeController.text,
          email: emailController.text.trim(),
          senha: senhaController.text);
      cadastrar(usuario);
    }
  }

  cadastrar(Usuario usuario) async {
    final auth = FirebaseAuth.instance;
    creatingAccount = true;
    popUpDialog(
      context: context,
      titleText: "Criando Conta",
      content: const Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
        ],
      ),
    );
    try {
      await auth
          .createUserWithEmailAndPassword(
        email: usuario.email,
        password: usuario.senha!,
      )
          .then((userCredencial) {
        final firestore = FirebaseFirestore.instance;
        firestore
            .collection("usuarios")
            .doc(userCredencial.user!.uid)
            .set(usuario.toMap());
        uploadImage();

        Navigator.pushNamedAndRemoveUntil(context, "/home", (_) => false);
      });
    } on FirebaseAuthException catch (e) {
      if (mounted && e.code == "email-already-in-use") {
        popUpDialog(context: context, titleText: "E-mail já em uso");
      }
    } catch (e) {
      if (mounted) popUpDialog(context: context, titleText: e.toString());
    }
    creatingAccount = false;
  }

  editarFoto(bool isCamera) async {
    loadingImage = true;
    if (isCamera == true) {
      pickedImage = await imagePicker.pickImage(source: ImageSource.camera);
    } else {
      pickedImage = await imagePicker.pickImage(source: ImageSource.gallery);
    }
    if (pickedImage != null) {
      image = File(pickedImage!.path);
      setState(() {
        loadingImage = false;
      });
    }
  }

  Future uploadImage() async {
    final storage = FirebaseStorage.instance;
    final auth = FirebaseAuth.instance;
    if (auth.currentUser != null && image != null) {
      final pastaRaiz =
          storage.ref().child("perfil").child("${auth.currentUser!.uid}.jpg");
      await pastaRaiz.putFile(image!);
      final urlImage = await pastaRaiz.getDownloadURL();
      final store = FirebaseFirestore.instance;
      store.collection("usuarios").doc(auth.currentUser!.uid).update({
        "Imagem": urlImage,
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text(
          "Cadastro",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Stack(children: [
        Center(
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: AvatarImageWidget(
                      editarFoto: editarFoto,
                      loadingImage: loadingImage,
                      image: image,
                    ),
                  ),
                  formFieldWidget(nomeController, "Nome", TextInputType.text,
                      (nome) {
                    if (nome == null || nome.isEmpty) {
                      return "Campo Nome Vazio!";
                    } else if (nome.length < 3) {
                      return "Nome deve ter no mínimo 3 caracteres.";
                    }
                    return null;
                  }),
                  formFieldWidget(
                      emailController, "E-mail", TextInputType.emailAddress,
                      (email) {
                    final emailRegExp = RegExp(
                        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                        caseSensitive: false);
                    if (email == null || email.isEmpty) {
                      return "Campo vazio!";
                    } else if (!emailRegExp.hasMatch(email)) {
                      return "E-Mail invalido";
                    }
                    return null;
                  }),
                  formFieldWidget(
                    senhaController,
                    "Senha",
                    TextInputType.text,
                    (senha) {
                      if (senha == null || senha.isEmpty) {
                        return "Campo vazio!";
                      } else if (senha.length < 6) {
                        return "Senha deve ter no mínimo 6 caracteres.";
                      }
                      return null;
                    },
                    obscureText: true,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 20,
                      right: 20,
                      top: 30,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green),
                        onPressed: () => validar(),
                        child: const Text(
                          "Cadastrar",
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ]),
    );
  }

  Widget formFieldWidget(TextEditingController controller, String hintText,
      TextInputType textInputType, String? Function(String?) validator,
      {bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 20,
        right: 20,
        top: 10,
      ),
      child: SizedBox(
        width: double.infinity,
        height: 60,
        child: TextFormField(
          obscureText: obscureText,
          controller: controller,
          style: const TextStyle(fontSize: 20),
          keyboardType: textInputType,
          validator: validator,
          decoration: InputDecoration(
            errorStyle: const TextStyle(color: Colors.white),
            hintText: hintText,
            hintStyle: const TextStyle(fontSize: 20),
            contentPadding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(32),
            ),
          ),
        ),
      ),
    );
  }
}
