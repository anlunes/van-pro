/// Modelo de dados do motorista.
/// Unifica dados do servidor MySQL (snake_case) + Firestore.
class Motorista {
  final int? id;
  final String uid; // Firebase Auth UID
  final String nome;
  final String email;
  final String telefone;
  final String vanCode;
  final String? cpf; // Cifrado (AES) — nunca expor
  final String fotoUrl;
  final int vagas;
  final bool aceitandoNovos;
  final double avaliacaoMedia;
  final int totalAvaliacoes;
  final bool temSeguroApp;
  final String? atendMunicipio;
  final String? atendUf;
  final String? cnhUrl;
  final DateTime? vencimentoCnh;
  final String? crlvUrl;
  final DateTime? vencimentoVistoria;
  final String? vistoriaUrl;
  final bool docsVerificados;
  final DateTime? dataVerificacao;
  final bool ativo;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // ── Campos extras do Firestore ─────────────────────────────────────
  final List<String>? bairrosTags;
  final List<String>? escolasTags;
  final bool? isOnline;

  Motorista({
    this.id,
    required this.uid,
    this.nome = '',
    this.email = '',
    this.telefone = '',
    required this.vanCode,
    this.cpf,
    this.fotoUrl = '',
    this.vagas = 0,
    this.aceitandoNovos = true,
    this.avaliacaoMedia = 0.0,
    this.totalAvaliacoes = 0,
    this.temSeguroApp = false,
    this.atendMunicipio,
    this.atendUf,
    this.cnhUrl,
    this.vencimentoCnh,
    this.crlvUrl,
    this.vencimentoVistoria,
    this.vistoriaUrl,
    this.docsVerificados = false,
    this.dataVerificacao,
    this.ativo = true,
    this.createdAt,
    this.updatedAt,
    this.bairrosTags,
    this.escolasTags,
    this.isOnline,
  });

  factory Motorista.fromServerMap(Map<String, dynamic> map) {
    return Motorista(
      id: map['id'] as int?,
      uid: map['uid'] as String? ?? '',
      nome: map['nome'] as String? ?? '',
      email: map['email'] as String? ?? '',
      telefone: map['telefone'] as String? ?? '',
      vanCode: map['vanCode'] as String? ?? '',
      cpf: map['cpf'] as String?,
      fotoUrl: map['foto_url'] as String? ?? '',
      vagas: map['vagas'] as int? ?? 0,
      aceitandoNovos: map['aceitando_novos'] == 1,
      avaliacaoMedia: (map['avaliacao_media'] ?? 0.0).toDouble(),
      totalAvaliacoes: map['total_avaliacoes'] as int? ?? 0,
      temSeguroApp: map['tem_seguro_app'] == 1,
      atendMunicipio: map['atend_municipio'] as String?,
      atendUf: map['atend_uf'] as String?,
      cnhUrl: map['cnh_url'] as String?,
      vencimentoCnh: map['vencimento_cnh'] != null
          ? DateTime.tryParse(map['vencimento_cnh'].toString())
          : null,
      crlvUrl: map['crlv_url'] as String?,
      vencimentoVistoria: map['vencimento_vistoria'] != null
          ? DateTime.tryParse(map['vencimento_vistoria'].toString())
          : null,
      vistoriaUrl: map['vistoria_url'] as String?,
      docsVerificados: map['docs_verificados'] == 1,
      dataVerificacao: map['data_verificacao'] != null
          ? DateTime.tryParse(map['data_verificacao'].toString())
          : null,
      ativo: map['ativo'] != 0,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString())
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'].toString())
          : null,
    );
  }

  factory Motorista.fromFirestoreMap(Map<String, dynamic> map) {
    return Motorista(
      uid: map['uid'] as String? ?? map['userId'] as String? ?? '',
      nome: map['nome'] as String? ?? '',
      email: map['email'] as String? ?? map['userEmail'] as String? ?? '',
      telefone: map['telefone'] as String? ?? '',
      fotoUrl: map['fotoUrl'] as String? ?? '',
      vanCode: map['vanCode'] as String? ?? '',
      vagas: map['vagas'] as int? ?? 0,
      aceitandoNovos: map['aceitandoNovos'] != false,
      avaliacaoMedia: (map['mediaAvaliacoes'] ?? map['avaliacaoMedia'] ?? 0.0).toDouble(),
      totalAvaliacoes: map['totalAvaliacoes'] as int? ?? 0,
      docsVerificados: map['documentosVerificados'] ?? map['docsVerificados'] ?? false,
      cnhUrl: map['cnhUrl'] as String?,
      crlvUrl: map['crlvUrl'] as String?,
      vistoriaUrl: map['vistoriaUrl'] as String?,
      temSeguroApp: map['temSeguroApp'] == true || map['tem_seguro_app'] == 1,
      atendMunicipio: map['atend_municipio'] as String? ?? map['atendMunicipio'] as String?,
      atendUf: map['atend_uf'] as String? ?? map['atendUf'] as String?,
      bairrosTags: map['bairros_tags'] != null ? List<String>.from(map['bairros_tags']) : null,
      escolasTags: map['escolas_tags'] != null ? List<String>.from(map['escolas_tags']) : null,
      isOnline: map['isOnline'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toServerMap() {
    return {
      if (id != null) 'id': id,
      'uid': uid,
      'nome': nome,
      'email': email,
      'telefone': telefone,
      'vanCode': vanCode,
      if (cpf != null) 'cpf': cpf,
      'foto_url': fotoUrl,
      'vagas': vagas,
      'aceitando_novos': aceitandoNovos ? 1 : 0,
      'avaliacao_media': avaliacaoMedia,
      'total_avaliacoes': totalAvaliacoes,
      'tem_seguro_app': temSeguroApp ? 1 : 0,
      if (atendMunicipio != null) 'atend_municipio': atendMunicipio,
      if (atendUf != null) 'atend_uf': atendUf,
      if (cnhUrl != null) 'cnh_url': cnhUrl,
      if (vencimentoCnh != null) 'vencimento_cnh': vencimentoCnh!.toIso8601String().split('T')[0],
      if (crlvUrl != null) 'crlv_url': crlvUrl,
      if (vencimentoVistoria != null) 'vencimento_vistoria': vencimentoVistoria!.toIso8601String().split('T')[0],
      if (vistoriaUrl != null) 'vistoria_url': vistoriaUrl,
      'docs_verificados': docsVerificados ? 1 : 0,
      if (dataVerificacao != null) 'data_verificacao': dataVerificacao!.toIso8601String().split('T')[0],
      'ativo': ativo ? 1 : 0,
    };
  }

  Map<String, dynamic> toFirestoreMap() {
    return {
      'uid': uid,
      'nome': nome,
      'email': email,
      'telefone': telefone,
      'fotoUrl': fotoUrl,
      'vanCode': vanCode,
      'vagas': vagas,
      'aceitandoNovos': aceitandoNovos,
      'mediaAvaliacoes': avaliacaoMedia,
      'totalAvaliacoes': totalAvaliacoes,
      'documentosVerificados': docsVerificados,
      'temSeguroApp': temSeguroApp,
      if (atendMunicipio != null) 'atendMunicipio': atendMunicipio,
      if (atendUf != null) 'atendUf': atendUf,
      if (cnhUrl != null) 'cnhUrl': cnhUrl,
      if (crlvUrl != null) 'crlvUrl': crlvUrl,
      if (vistoriaUrl != null) 'vistoriaUrl': vistoriaUrl,
      if (bairrosTags != null) 'bairros_tags': bairrosTags,
      if (escolasTags != null) 'escolas_tags': escolasTags,
      'role': 'motorista',
    };
  }

  Motorista copyWith({
    int? id, String? uid, String? nome, String? email, String? telefone,
    String? vanCode, String? cpf, String? fotoUrl, int? vagas,
    bool? aceitandoNovos, double? avaliacaoMedia, int? totalAvaliacoes,
    bool? temSeguroApp, String? atendMunicipio, String? atendUf,
    String? cnhUrl, DateTime? vencimentoCnh, String? crlvUrl,
    DateTime? vencimentoVistoria, String? vistoriaUrl,
    bool? docsVerificados, DateTime? dataVerificacao, bool? ativo,
    List<String>? bairrosTags, List<String>? escolasTags, bool? isOnline,
  }) {
    return Motorista(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      nome: nome ?? this.nome,
      email: email ?? this.email,
      telefone: telefone ?? this.telefone,
      vanCode: vanCode ?? this.vanCode,
      cpf: cpf ?? this.cpf,
      fotoUrl: fotoUrl ?? this.fotoUrl,
      vagas: vagas ?? this.vagas,
      aceitandoNovos: aceitandoNovos ?? this.aceitandoNovos,
      avaliacaoMedia: avaliacaoMedia ?? this.avaliacaoMedia,
      totalAvaliacoes: totalAvaliacoes ?? this.totalAvaliacoes,
      temSeguroApp: temSeguroApp ?? this.temSeguroApp,
      atendMunicipio: atendMunicipio ?? this.atendMunicipio,
      atendUf: atendUf ?? this.atendUf,
      cnhUrl: cnhUrl ?? this.cnhUrl,
      vencimentoCnh: vencimentoCnh ?? this.vencimentoCnh,
      crlvUrl: crlvUrl ?? this.crlvUrl,
      vencimentoVistoria: vencimentoVistoria ?? this.vencimentoVistoria,
      vistoriaUrl: vistoriaUrl ?? this.vistoriaUrl,
      docsVerificados: docsVerificados ?? this.docsVerificados,
      dataVerificacao: dataVerificacao ?? this.dataVerificacao,
      ativo: ativo ?? this.ativo,
      bairrosTags: bairrosTags ?? this.bairrosTags,
      escolasTags: escolasTags ?? this.escolasTags,
      isOnline: isOnline ?? this.isOnline,
    );
  }

  String get avaliacaoFormatada =>
      totalAvaliacoes > 0
          ? '${avaliacaoMedia.toStringAsFixed(1)} ($totalAvaliacoes avaliações)'
          : 'Sem avaliações';

  String get badgeStatus => docsVerificados ? '✅ Verificado' : '⚠ Pendente';

  @override
  String toString() => 'Motorista(nome=$nome, vanCode=$vanCode, media=$avaliacaoMedia)';
}
