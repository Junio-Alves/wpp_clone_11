import 'package:flutter/material.dart';
import 'package:myapp/models/conversa.dart';

class ConversasPage extends StatefulWidget {
  const ConversasPage({super.key});

  @override
  State<ConversasPage> createState() => _ConversasPageState();
}

class _ConversasPageState extends State<ConversasPage> {
  List<Conversa> conversas = [
    Conversa(
      caminhoPerfil: "assets/images/perfil5.jpg",
      nome: "Jamilton Damasceno",
      mensagem: "Olá,Tudo bem?",
    ),
    Conversa(
      caminhoPerfil: "assets/images/perfil4.jpg",
      nome: "Marcela Silva",
      mensagem: "Vou jogar tenis hoje",
    ),
    Conversa(
      caminhoPerfil: "assets/images/perfil3.jpg",
      nome: "Lucas Ferreira",
      mensagem: "Vai hj para o estagio?",
    ),
    Conversa(
      caminhoPerfil: "assets/images/perfil2.jpg",
      nome: "Carla Carneiro",
      mensagem: "Me faz o pix",
    ),
    Conversa(
      caminhoPerfil: "assets/images/perfil1.jpg",
      nome: "Renan Sabino",
      mensagem: "cade teu irmao",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ListView.builder(
        itemCount: conversas.length,
        itemBuilder: (context, index) {
          return Column(
            children: [
              ListTile(
                leading: CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage(
                    conversas[index].caminhoPerfil,
                  ),
                ),
                title: Text(
                  conversas[index].nome,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(conversas[index].mensagem),
              ),
            ],
          );
        },
      ),
    );
  }
}
