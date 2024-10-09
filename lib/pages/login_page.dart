import 'package:flutter/material.dart';
import 'package:myapp/models/usuario.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/widgets/popUp_widget.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  void initState() {
    /*função usada para agendar uma ação que será executada 
    após a construção do frame */
    WidgetsBinding.instance.addPostFrameCallback((_) {
      verificarUsuarioLogado();
    });
    super.initState();
  }

  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController(text: "juniophb2005@gmail.com");
  final senhaController = TextEditingController(text: "123456");

  limparTexto() {
    emailController.clear();
    senhaController.clear();
  }

  validar() {
    if (formKey.currentState!.validate()) {
      final usuario = Usuario(
        email: emailController.text,
        senha: senhaController.text,
      );
      login(usuario);
    }
  }

  cadastrar() {
    Navigator.pushNamed(context, "/cadastro");
  }

  Future verificarUsuarioLogado() async {
    final auth = FirebaseAuth.instance;
    final usuarioLogado = auth.currentUser;
    if (usuarioLogado != null) {
      Navigator.pushReplacementNamed(context, "/home");
    }
  }

  login(Usuario usuario) async {
    try {
      final auth = FirebaseAuth.instance;
      await auth
          .signInWithEmailAndPassword(
        email: usuario.email,
        password: usuario.senha!,
      )
          .then((user) {
        Navigator.pushReplacementNamed(context, "/home");
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == "invalid-credential" && mounted) {
        popUpDialog(context: context, titleText: "Credenciais Invalidas");
      }
    } catch (e) {
      if (mounted) {
        popUpDialog(context: context, titleText: e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/images/logo.png",
                  height: 150,
                ),
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
                        "Entrar",
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => cadastrar(),
                  child: const Text(
                    "Não tem conta? cadastre-se!",
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
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
