class Usuario {
  String? idUsuario;
  String? urlImagem;
  String? nome;
  String email;
  String? senha;
  Usuario({
    this.idUsuario,
    this.urlImagem,
    this.nome,
    required this.email,
    this.senha,
  });

  Map<String, dynamic> toMap() {
    return {
      "idUsuario" : idUsuario,
      "Nome": nome,
      "Email": email,
      "urlImagem": urlImagem,
    };
  }
}
