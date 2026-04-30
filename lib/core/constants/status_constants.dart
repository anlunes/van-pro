/// Status de embarque do aluno — estados do ciclo diário.
/// Usado pelo Firestore em tempo real + UI do motorista e pai.
enum StatusEmbarque {
  aguardando('Aguardando'),
  embarcadoIda('Embarcou ida'),
  naEscola('Chegou na Escola'),
  aguardandoSaida('Aguardando Saída'),
  embarcadoVolta('Embarcou volta'),
  emCasa('Chegou em Casa'),
  naoVaiHoje('Não vai hoje');

  final String label;
  const StatusEmbarque(this.label);

  /// Retorna true se o pai deve ver o mapa GPS neste status.
  bool get paiVeGps =>
      this == StatusEmbarque.embarcadoIda ||
      this == StatusEmbarque.embarcadoVolta;

  /// Cria a partir de string salva no Firestore/servidor.
  static StatusEmbarque fromString(String? value) {
    return StatusEmbarque.values.firstWhere(
      (e) => e.label == value || e.name == value,
      orElse: () => StatusEmbarque.aguardando,
    );
  }
}

/// Status de transporte usado na lógica de chamada do motorista.
/// Representa o que aparece na UI dos botões de ação.
enum StatusTransporte {
  aguardando('Aguardando'),
  aCaminhoDaEscola('A caminho da Escola'),
  entregueNaEscola('Entregue na Escola'),
  aCaminhoDeCasa('A caminho de Casa'),
  entregueEmCasa('Entregue em Casa');

  final String label;
  const StatusTransporte(this.label);

  /// Próximo status na sequência (ida).
  StatusTransporte? get proximoIda {
    switch (this) {
      case StatusTransporte.aguardando:
        return StatusTransporte.aCaminhoDaEscola;
      case StatusTransporte.aCaminhoDaEscola:
        return StatusTransporte.entregueNaEscola;
      default:
        return null;
    }
  }

  /// Próximo status na sequência (volta).
  StatusTransporte? get proximoVolta {
    switch (this) {
      case StatusTransporte.entregueNaEscola:
        return StatusTransporte.aCaminhoDeCasa;
      case StatusTransporte.aCaminhoDeCasa:
        return StatusTransporte.entregueEmCasa;
      default:
        return null;
    }
  }

  static StatusTransporte fromString(String? value) {
    return StatusTransporte.values.firstWhere(
      (e) => e.label == value || e.name == value,
      orElse: () => StatusTransporte.aguardando,
    );
  }
}

/// Status de contratação do aluno (no servidor MySQL).
enum StatusContratacao {
  ativo('ativo'),
  inativo('inativo'),
  suspenso('suspenso'),
  recusado('recusado');

  final String value;
  const StatusContratacao(this.value);

  static StatusContratacao fromString(String? value) {
    return StatusContratacao.values.firstWhere(
      (e) => e.value == value,
      orElse: () => StatusContratacao.ativo,
    );
  }
}

/// Roles dos utilizadores no sistema.
enum UserRole {
  motorista('motorista'),
  responsavel('responsavel'),
  admin('admin');

  final String value;
  const UserRole(this.value);

  static UserRole fromString(String? value) {
    return UserRole.values.firstWhere(
      (e) => e.value == value,
      orElse: () => UserRole.responsavel,
    );
  }
}
