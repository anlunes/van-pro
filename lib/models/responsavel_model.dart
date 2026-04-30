/// Modelo de dados do responsável (pai/mãe).
/// Unifica dados do servidor MySQL (snake_case) com Firebase Auth (email, uid).
class Responsavel {
  final int? id;
  final String uid; // Firebase Auth UID
  final String nome;
  final String email;
  final String telefone;
  final String? endereco;
  final String? bairro;
  final String? municipio;
  final String? estado;
  final String? cep;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Responsavel({
    this.id,
    required this.uid,
    required this.nome,
    required this.email,
    required this.telefone,
    this.endereco,
    this.bairro,
    this.municipio,
    this.estado,
    this.cep,
    this.createdAt,
    this.updatedAt,
  });

  factory Responsavel.fromServerMap(Map<String, dynamic> map) {
    return Responsavel(
      id: map['id'] as int?,
      uid: map['uid'] as String? ?? '',
      nome: map['nome'] as String? ?? '',
      email: map['email'] as String? ?? '',
      telefone: map['telefone'] as String? ?? '',
      endereco: map['endereco'] as String?,
      bairro: map['bairro'] as String?,
      municipio: map['municipio'] as String?,
      estado: map['estado'] as String?,
      cep: map['cep'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString())
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toServerMap() {
    return {
      if (id != null) 'id': id,
      'uid': uid,
      'nome': nome,
      'email': email,
      'telefone': telefone,
      if (endereco != null) 'endereco': endereco,
      if (bairro != null) 'bairro': bairro,
      if (municipio != null) 'municipio': municipio,
      if (estado != null) 'estado': estado,
      if (cep != null) 'cep': cep,
    };
  }

  Responsavel copyWith({
    int? id,
    String? uid,
    String? nome,
    String? email,
    String? telefone,
    String? endereco,
    String? bairro,
    String? municipio,
    String? estado,
    String? cep,
  }) {
    return Responsavel(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      nome: nome ?? this.nome,
      email: email ?? this.email,
      telefone: telefone ?? this.telefone,
      endereco: endereco ?? this.endereco,
      bairro: bairro ?? this.bairro,
      municipio: municipio ?? this.municipio,
      estado: estado ?? this.estado,
      cep: cep ?? this.cep,
    );
  }

  @override
  String toString() => 'Responsavel(uid=$uid, nome=$nome, email=$email)';
}
