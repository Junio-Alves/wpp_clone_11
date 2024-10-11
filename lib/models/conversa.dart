import 'package:cloud_firestore/cloud_firestore.dart';

class Conversa {
  String idRemetente;
  String idDestinatario;
  String nome;
  String urlImagem;
  String mensagem;
  String tipo;
  Timestamp hora;
  Conversa(
      {required this.idRemetente,
      required this.idDestinatario,
      required this.nome,
      required this.urlImagem,
      required this.mensagem,
      required this.tipo,
      required this.hora});

  salvar() async {
    final db = FirebaseFirestore.instance;
    await db
        .collection("conversas")
        .doc(idRemetente)
        .collection("ultimas_conversas")
        .doc(idDestinatario)
        .set(toMap());
  }

  Map<String, dynamic> toMap() {
    return {
      "idDestinatario": idDestinatario,
      "idRemetente": idRemetente,
      "nome": nome,
      "urlImagem": urlImagem,
      "mensagem": mensagem,
      "tipo": tipo,
      "hora": hora,
    };
  }

  factory Conversa.fromMap(Map<String, dynamic> map) {
    return Conversa(
      idRemetente: map["idRemetente"],
      idDestinatario: map["idDestinatario"],
      nome: map["nome"],
      urlImagem: map["urlImagem"],
      mensagem: map["mensagem"],
      tipo: map["tipo"],
      hora: map["hora"] as Timestamp,
    );
  }
}
