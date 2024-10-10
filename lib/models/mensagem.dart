import 'package:cloud_firestore/cloud_firestore.dart';

class Mensagem {
  String idUsuario;
  String mensagem;
  String urlImagem;
  String tipo;
  Timestamp hora;
  Mensagem({
    required this.idUsuario,
    required this.mensagem,
    required this.urlImagem,
    required this.tipo,
    required this.hora,
  });

  Map<String, dynamic> topMap() {
    return {
      "idUsuario": idUsuario,
      "mensagem": mensagem,
      "urlImagem": urlImagem,
      "tipo": tipo,
      "hora": hora,
    };
  }
}
