import 'package:flutter/material.dart';
import 'package:myapp/models/usuario.dart';
import 'package:myapp/pages/cadastro_page.dart';
import 'package:myapp/pages/perfil_page.dart';
import 'package:myapp/pages/home_page.dart';
import 'package:myapp/pages/login_page.dart';
import 'package:myapp/pages/mensagens_page.dart';
import 'package:myapp/pages/unknown_page.dart';

class RouteGenerator {
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case "/":
        return MaterialPageRoute(
          builder: (context) => const LoginPage(),
        );
      case "/login":
        return MaterialPageRoute(
          builder: (context) => const LoginPage(),
        );
      case "/perfil":
        return MaterialPageRoute(
          builder: (context) => const PerfilPage(),
        );
      case "/home":
        return MaterialPageRoute(
          builder: (context) => const HomePage(),
        );
      case "/cadastro":
        return MaterialPageRoute(
          builder: (context) => const CadastroPage(),
        );
      case "/conversa":
        return MaterialPageRoute(
          builder: (context) =>
              MensagensPage(usuario: settings.arguments as Usuario),
        );
      default:
        return MaterialPageRoute(
          builder: (context) => const UnknownPage(),
        );
    }
  }
}
