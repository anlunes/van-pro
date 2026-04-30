/// Modelo de dados da avaliação mensal do motorista.
class Avaliacao {
  final int? id;
  final int? alunoId;
  final int responsavelId;
  final int motoristaId;
  final String? vanCode;
  final double notaPontualidade;
  final double notaSeguranca;
  final double notaCordialidade;
  final double media;
  final String? comentario;
  final String mesReferencia; // formato: "4-2026"
  final DateTime? createdAt;

  // ── Campos extras do Firestore ─────────────────────────────────────
  final String? responsavelUid;
  final String? responsavelNome;
  final String? alunoNome;
  final Timestamp? timestamp;

  Avaliacao({
    this.id,
    this.alunoId,
    required this.responsavelId,
    required this.motoristaId,
    this.vanCode,
    required this.notaPontualidade,
    required this.notaSeguranca,
    required this.notaCordialidade,
    required this.media,
    this.comentario,
    required this.mesReferencia,
    this.createdAt,
    this.responsavelUid,
    this.responsavelNome,
    this.alunoNome,
    this.timestamp,
  });

  // ── fromMap: servidor MySQL (snake_case) ───────────────────────────
  factory Avaliacao.fromServerMap(Map<String, dynamic> map) {
    return Avaliacao(
      id: map['id'] as int?,
      alunoId: map['aluno_id'] as int?,
      responsavelId: map['responsavel_id'] as int? ?? 0,
      motoristaId: map['motorista_id'] as int? ?? 0,
      vanCode: map['vanCode'] as String?,
      notaPontualidade: (map['nota_pontualidade'] ?? 0.0).toDouble(),
      notaSeguranca: (map['nota_seguranca'] ?? 0.0).toDouble(),
      notaCordialidade: (map['nota_cordialidade'] ?? 0.0).toDouble(),
      media: (map['media'] ?? 0.0).toDouble(),
      comentario: map['comentario'] as String?,
      mesReferencia: map['mes_referencia'] as String? ?? '',
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString())
          : null,
    );
  }

  // ── fromMap: Firestore (camelCase) ─────────────────────────────────
  factory Avaliacao.fromFirestoreMap(Map<String, dynamic> map) {
    final notas = map['notas'] as Map<String, dynamic>? ?? {};
    return Avaliacao(
      responsavelId: _parseInt(map['responsavelId'] ?? map['responsavel_id'] ?? 0),
      responsavelUid: map['paiUid'] as String?,
      responsavelNome: map['paiNome'] as String?,
      alunoNome: map['alunoNome'] as String?,
      motoristaId: _parseInt(map['motoristaUid'] ?? map['motorista_id']),
      vanCode: map['vanCode'] as String?,
      notaPontualidade: (notas['pontualidade'] ?? (map['pontualidade'] ?? 0.0)).toDouble(),
      notaSeguranca: (notas['seguranca'] ?? (map['seguranca'] ?? 0.0)).toDouble(),
      notaCordialidade: (notas['cordialidade'] ?? (map['cordialidade'] ?? 0.0)).toDouble(),
      media: (map['media'] ?? 0.0).toDouble(),
      comentario: map['comentario'] as String?,
      mesReferencia: map['mes_referencia'] as String? ?? _gerarMesAnoAtual(),
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString())
          : null,
    );
  }

  // ── toMap: servidor MySQL (snake_case) ─────────────────────────────
  Map<String, dynamic> toServerMap() {
    return {
      if (id != null) 'id': id,
      if (alunoId != null) 'aluno_id': alunoId,
      'responsavel_id': responsavelId,
      'motorista_id': motoristaId,
      if (vanCode != null) 'vanCode': vanCode,
      'nota_pontualidade': notaPontualidade,
      'nota_seguranca': notaSeguranca,
      'nota_cordialidade': notaCordialidade,
      'media': media,
      if (comentario != null) 'comentario': comentario,
      'mes_referencia': mesReferencia,
    };
  }

  // ── toMap: Firestore (camelCase) ───────────────────────────────────
  Map<String, dynamic> toFirestoreMap() {
    return {
      if (responsavelUid != null) 'paiUid': responsavelUid,
      if (responsavelNome != null) 'paiNome': responsavelNome,
      if (alunoNome != null) 'alunoNome': alunoNome,
      'motoristaUid': _parseIntString(motoristaId),
      'vanCode': vanCode,
      'notas': {
        'pontualidade': notaPontualidade,
        'seguranca': notaSeguranca,
        'cordialidade': notaCordialidade,
      },
      'comentario': comentario ?? '',
      'media': media,
      'mes_referencia': mesReferencia,
    };
  }

  // ── Helpers ─────────────────────────────────────────────────────────
  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static String _parseIntString(int value) => value.toString();

  static String _gerarMesAnoAtual() {
    final now = DateTime.now();
    return '${now.month}-${now.year}';
  }

  /// Calcula a média a partir das 3 notas.
  static double calcularMedia(double p, double s, double c) {
    return double.parse(((p + s + c) / 3).toStringAsFixed(1));
  }

  /// Retorna o badge de estrelas da avaliação.
  String get badgeEstrelas => '⭐' * media.round().clamp(0, 5);

  @override
  String toString() =>
      'Avaliacao(motorista=$motoristaId, media=$media, mes=$mesReferencia)';
}

// Placeholder para Timestamp do Firestore (usado em fromFirestoreMap)
class Timestamp {
  final DateTime _dateTime;
  Timestamp.now() : _dateTime = DateTime.now();
  Timestamp._(this._dateTime);

  DateTime toDate() => _dateTime;
}