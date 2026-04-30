import 'dart:typed_data';

/// Modelo de dados do aluno.
/// Unifica dados do servidor MySQL (snake_case) com dados operacionais do Firestore (camelCase).
class Aluno {
  final int? id;
  final String? firebaseStatusId; // doc ID em alunos_status (Firestore)
  final int? responsavelId;
  final String responsavelUid;
  final String nomeResponsavel;
  final int? motoristaId;
  final String? vanCode;
  final String nome;
  final String fotoUrl;
  final String telefone;
  final String endereco;
  final String bairro;
  final String municipio;
  final String estado;
  final int? escolaId;
  final String nomeEscola;
  final String enderecoEscola;
  final String? horarioEntrada; // HH:mm
  final int? horarioEntradaMinutos;
  final String? horarioSaida;
  final int? horarioSaidaMinutos;
  final String statusContratacao;
  final String? motivoRecusa;
  final double valorMensalidade;
  final int diaPagamento;
  final int ordem;
  final bool avaliadoNoCiclo;
  final String? mesAvaliado;
  final DateTime? ultimoPagamento;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool pago;
  final bool vaiHoje;
  final bool cienteMotorista;
  final bool solicitacaoContato;
  final String? respostaContato;
  final String status; // StatusEmbarque (Firestore)

  // ── Campos operacionais (Firestore — tempo real) ───────────────────
  final int? servidorId; // ID retornado pelo MySQL
  final Uint8List? fotoBytes; // Bytes da foto para upload

  Aluno({
    this.id,
    this.firebaseStatusId,
    this.responsavelId,
    this.responsavelUid = '',
    this.nomeResponsavel = '',
    this.motoristaId,
    this.vanCode,
    this.nome = '',
    this.fotoUrl = '',
    this.telefone = '',
    this.endereco = '',
    this.bairro = '',
    this.municipio = '',
    this.estado = '',
    this.escolaId,
    this.nomeEscola = '',
    this.enderecoEscola = '',
    this.horarioEntrada,
    this.horarioEntradaMinutos,
    this.horarioSaida,
    this.horarioSaidaMinutos,
    this.statusContratacao = 'ativo',
    this.motivoRecusa,
    this.valorMensalidade = 0.0,
    this.diaPagamento = 5,
    this.ordem = 0,
    this.avaliadoNoCiclo = false,
    this.mesAvaliado,
    this.ultimoPagamento,
    this.createdAt,
    this.updatedAt,
    this.pago = false,
    this.vaiHoje = true,
    this.cienteMotorista = false,
    this.solicitacaoContato = false,
    this.respostaContato,
    this.status = 'Aguardando',
    this.servidorId,
    this.fotoBytes,
  });

  // ── fromMap: servidor MySQL (snake_case) ───────────────────────────
  factory Aluno.fromServerMap(Map<String, dynamic> map) {
    return Aluno(
      id: map['id'] as int?,
      firebaseStatusId: map['firebase_status_id'] as String?,
      responsavelId: map['responsavel_id'] as int?,
      responsavelUid: map['responsavel_uid'] as String? ?? '',
      nomeResponsavel: map['nome_responsavel'] as String? ?? '',
      motoristaId: map['motorista_id'] as int?,
      vanCode: map['vanCode'] as String?,
      nome: map['nome'] as String? ?? '',
      fotoUrl: map['foto_url'] as String? ?? '',
      telefone: map['telefone'] as String? ?? '',
      endereco: map['endereco'] as String? ?? '',
      bairro: map['bairro'] as String? ?? '',
      municipio: map['municipio'] as String? ?? '',
      estado: map['estado'] as String? ?? '',
      escolaId: map['escola_id'] as int?,
      nomeEscola: map['nome_escola'] as String? ?? '',
      enderecoEscola: map['endereco_escola'] as String? ?? '',
      horarioEntrada: map['horario_entrada'] as String?,
      horarioEntradaMinutos: map['horario_entrada_minutos'] as int?,
      horarioSaida: map['horario_saida'] as String?,
      horarioSaidaMinutos: map['horario_saida_minutos'] as int?,
      statusContratacao: map['status_contratacao'] as String? ?? 'ativo',
      motivoRecusa: map['motivo_recusa'] as String?,
      valorMensalidade: (map['valor_mensalidade'] ?? 0.0).toDouble(),
      diaPagamento: map['dia_pagamento'] as int? ?? 5,
      ordem: map['ordem'] as int? ?? 0,
      avaliadoNoCiclo: map['avaliado_no_ciclo'] == 1,
      mesAvaliado: map['mes_avaliado'] as String?,
      ultimoPagamento: map['ultimo_pagamento'] != null
          ? DateTime.tryParse(map['ultimo_pagamento'].toString())
          : null,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString())
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'].toString())
          : null,
      pago: map['pago'] == 1,
      vaiHoje: map['vai_hoje'] != 0,
      cienteMotorista: map['ciente_motorista'] == 1,
      solicitacaoContato: map['solicitacao_contato'] == 1,
      respostaContato: map['resposta_contato'] as String?,
      status: map['status'] as String? ?? 'Aguardando',
      servidorId: map['servidorid'] as int?,
    );
  }

  // ── fromMap: Firestore (camelCase + mix) ───────────────────────────
  factory Aluno.fromFirestoreMap(Map<String, dynamic> map) {
    return Aluno(
      firebaseStatusId: map['firebaseStatusId'] as String?,
      responsavelUid: map['responsavelUid'] as String? ?? '',
      nome: map['nome'] as String? ?? '',
      fotoUrl: map['fotoUrl'] as String? ?? '',
      telefone: map['telefone'] as String? ?? '',
      endereco: map['endereco'] as String? ?? '',
      bairro: map['bairro'] as String? ?? '',
      municipio: map['municipio'] as String? ?? '',
      estado: map['estado'] as String? ?? '',
      nomeEscola: map['nomeEscola'] as String? ?? '',
      enderecoEscola: map['enderecoEscola'] as String? ?? '',
      horarioEntrada: map['horarioEntrada'] as String?,
      horarioSaida: map['horarioSaida'] as String?,
      valorMensalidade: (map['valorMensalidade'] ?? 0.0).toDouble(),
      diaPagamento: map['diaPagamento'] as int? ?? 5,
      pago: map['pago'] == true || map['pago'] == 1,
      vaiHoje: map['vaiHoje'] != false && map['vaiHoje'] != 0,
      status: map['status'] as String? ?? 'Aguardando',
      servidorId: map['servidorId'] as int?,
    );
  }

  // ── toMap: servidor MySQL (snake_case) ─────────────────────────────
  Map<String, dynamic> toServerMap() {
    return {
      if (id != null) 'id': id,
      if (firebaseStatusId != null) 'firebase_status_id': firebaseStatusId,
      'responsavel_id': responsavelId,
      'responsavel_uid': responsavelUid,
      'nome_responsavel': nomeResponsavel,
      if (motoristaId != null) 'motorista_id': motoristaId,
      if (vanCode != null) 'vanCode': vanCode,
      'nome': nome,
      'foto_url': fotoUrl,
      'telefone': telefone,
      'endereco': endereco,
      'bairro': bairro,
      'municipio': municipio,
      'estado': estado,
      if (escolaId != null) 'escola_id': escolaId,
      'nome_escola': nomeEscola,
      'endereco_escola': enderecoEscola,
      'horario_entrada': horarioEntrada,
      'horario_entrada_minutos': horarioEntradaMinutos,
      'horario_saida': horarioSaida,
      'horario_saida_minutos': horarioSaidaMinutos,
      'status_contratacao': statusContratacao,
      if (motivoRecusa != null) 'motivo_recusa': motivoRecusa,
      'valor_mensalidade': valorMensalidade,
      'dia_pagamento': diaPagamento,
      'ordem': ordem,
      'avaliado_no_ciclo': avaliadoNoCiclo ? 1 : 0,
      if (mesAvaliado != null) 'mes_avaliado': mesAvaliado,
      if (ultimoPagamento != null) 'ultimo_pagamento': ultimoPagamento!.toIso8601String(),
      'pago': pago ? 1 : 0,
      'vai_hoje': vaiHoje ? 1 : 0,
      'ciente_motorista': cienteMotorista ? 1 : 0,
      'solicitacao_contato': solicitacaoContato ? 1 : 0,
      if (respostaContato != null) 'resposta_contato': respostaContato,
      'status': status,
    };
  }

  // ── toMap: Firestore (camelCase — só 5 campos operacionais) ─────────
  Map<String, dynamic> toFirestoreMap() {
    return {
      if (firebaseStatusId != null) 'firebaseStatusId': firebaseStatusId,
      'responsavelUid': responsavelUid,
      if (servidorId != null) 'servidorId': servidorId,
      'status': status,
      'vaiHoje': vaiHoje,
      'cienteMotorista': cienteMotorista,
    };
  }

  Aluno copyWith({
    int? id,
    String? firebaseStatusId,
    int? responsavelId,
    String? responsavelUid,
    String? nomeResponsavel,
    int? motoristaId,
    String? vanCode,
    String? nome,
    String? fotoUrl,
    String? telefone,
    String? endereco,
    String? bairro,
    String? municipio,
    String? estado,
    int? escolaId,
    String? nomeEscola,
    String? enderecoEscola,
    String? horarioEntrada,
    int? horarioEntradaMinutos,
    String? horarioSaida,
    int? horarioSaidaMinutos,
    String? statusContratacao,
    String? motivoRecusa,
    double? valorMensalidade,
    int? diaPagamento,
    int? ordem,
    bool? avaliadoNoCiclo,
    String? mesAvaliado,
    DateTime? ultimoPagamento,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? pago,
    bool? vaiHoje,
    bool? cienteMotorista,
    bool? solicitacaoContato,
    String? respostaContato,
    String? status,
    int? servidorId,
  }) {
    return Aluno(
      id: id ?? this.id,
      firebaseStatusId: firebaseStatusId ?? this.firebaseStatusId,
      responsavelId: responsavelId ?? this.responsavelId,
      responsavelUid: responsavelUid ?? this.responsavelUid,
      nomeResponsavel: nomeResponsavel ?? this.nomeResponsavel,
      motoristaId: motoristaId ?? this.motoristaId,
      vanCode: vanCode ?? this.vanCode,
      nome: nome ?? this.nome,
      fotoUrl: fotoUrl ?? this.fotoUrl,
      telefone: telefone ?? this.telefone,
      endereco: endereco ?? this.endereco,
      bairro: bairro ?? this.bairro,
      municipio: municipio ?? this.municipio,
      estado: estado ?? this.estado,
      escolaId: escolaId ?? this.escolaId,
      nomeEscola: nomeEscola ?? this.nomeEscola,
      enderecoEscola: enderecoEscola ?? this.enderecoEscola,
      horarioEntrada: horarioEntrada ?? this.horarioEntrada,
      horarioEntradaMinutos: horarioEntradaMinutos ?? this.horarioEntradaMinutos,
      horarioSaida: horarioSaida ?? this.horarioSaida,
      horarioSaidaMinutos: horarioSaidaMinutos ?? this.horarioSaidaMinutos,
      statusContratacao: statusContratacao ?? this.statusContratacao,
      motivoRecusa: motivoRecusa ?? this.motivoRecusa,
      valorMensalidade: valorMensalidade ?? this.valorMensalidade,
      diaPagamento: diaPagamento ?? this.diaPagamento,
      ordem: ordem ?? this.ordem,
      avaliadoNoCiclo: avaliadoNoCiclo ?? this.avaliadoNoCiclo,
      mesAvaliado: mesAvaliado ?? this.mesAvaliado,
      ultimoPagamento: ultimoPagamento ?? this.ultimoPagamento,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      pago: pago ?? this.pago,
      vaiHoje: vaiHoje ?? this.vaiHoje,
      cienteMotorista: cienteMotorista ?? this.cienteMotorista,
      solicitacaoContato: solicitacaoContato ?? this.solicitacaoContato,
      respostaContato: respostaContato ?? this.respostaContato,
      status: status ?? this.status,
      servidorId: servidorId ?? this.servidorId,
    );
  }

  /// Converte minutos (ex: 480) para string HH:mm.
  static String minutosParaHorario(int minutos) {
    final h = (minutos ~/ 60).toString().padLeft(2, '0');
    final m = (minutos % 60).toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  String toString() => 'Aluno(nome=$nome, vanCode=$vanCode, status=$status)';
}