import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myapp/pages/contatos_page.dart';
import 'package:myapp/pages/conversas_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> itensMenu = ["Configurações", "Deslogar"];
  escolhaMenuItem(String itemEscolhido) {
    switch (itemEscolhido) {
      case "Configurações":
        configuracoes();
        break;
      case "Deslogar":
        deslogarUsuario();
        break;
    }
  }

  configuracoes() {
    Navigator.pushNamed(
      context,
      "/perfil",
    );
  }

  deslogarUsuario() async {
    final auth = FirebaseAuth.instance;
    await auth.signOut().then(
      (_) {
        Navigator.pushNamedAndRemoveUntil(
            context, "/login", (Route<dynamic> route) => false);
      },
    );
  }

  Future verificarUsuarioLogado() async {
    final auth = FirebaseAuth.instance;
    final usuarioLogado = auth.currentUser;
    if (usuarioLogado == null) {
      Navigator.pushReplacementNamed(context, "/login");
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      verificarUsuarioLogado();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          title: const Text(
            "whatsapp",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          actions: [
            PopupMenuButton(
              iconColor: Colors.white,
              onSelected: escolhaMenuItem,
              itemBuilder: (context) {
                return itensMenu.map(
                  (String item) {
                    return PopupMenuItem(
                      value: item,
                      child: Text(item),
                    );
                  },
                ).toList();
              },
            )
          ],
          bottom: const TabBar(
              unselectedLabelColor: Colors.white,
              labelColor: Colors.white,
              indicatorColor: Colors.white,
              tabs: [
                Tab(
                  text: "Conversas",
                ),
                Tab(
                  text: "Contatos",
                ),
              ]),
        ),
        body: const TabBarView(
          children: [
            ConversasPage(),
            ContatosPage(),
          ],
        ),
      ),
    );
  }
}
