-- ============================================================
-- VANPRO - Banco de Dados MySQL
-- Usa o banco balcao2p_vanpro existente
-- ============================================================

USE balcao2p_vanpro;
SET FOREIGN_KEY_CHECKS = 0;

-- Apaga tabelas antigas se existirem
DROP TABLE IF EXISTS logs;
DROP TABLE IF EXISTS cidades_atendidas;
DROP TABLE IF EXISTS fotos;
DROP TABLE IF EXISTS documentos;
DROP TABLE IF EXISTS mensalidades;
DROP TABLE IF EXISTS avaliacoes;
DROP TABLE IF EXISTS alunos;
DROP TABLE IF EXISTS escolas;
DROP TABLE IF EXISTS motoristas;
DROP TABLE IF EXISTS responsaveis;
DROP TABLE IF EXISTS usuarios;

SET FOREIGN_KEY_CHECKS = 1;

-- ============================================================
-- TABELA 1: usuários
-- ============================================================
CREATE TABLE usuarios (
  id           INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  uid          VARCHAR(28) NOT NULL UNIQUE COMMENT 'Firebase Auth UID',
  role         ENUM('responsavel','motorista','admin') NOT NULL DEFAULT 'responsavel',
  nome         VARCHAR(120) NOT NULL,
  email        VARCHAR(160) NOT NULL UNIQUE,
  telefone     VARCHAR(20)  NOT NULL,
  created_at   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  ativo        TINYINT(1)  NOT NULL DEFAULT 1,

  INDEX idx_uid (uid),
  INDEX idx_email (email),
  INDEX idx_role (role)
) ENGINE=InnoDB;

-- ============================================================
-- TABELA 2: responsáveis
-- ============================================================
CREATE TABLE responsaveis (
  id           INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  usuario_id   INT UNSIGNED NOT NULL,
  uid          VARCHAR(28)  NOT NULL UNIQUE COMMENT 'Firebase UID',
  nome         VARCHAR(120) NOT NULL,
  email        VARCHAR(160) NOT NULL,
  telefone     VARCHAR(20)  NOT NULL,
  endereco     VARCHAR(255) NULL,
  bairro       VARCHAR(100) NULL,
  municipio    VARCHAR(100) NULL,
  estado       VARCHAR(2)  NULL,
  cep          VARCHAR(9)  NULL,
  created_at   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
  UNIQUE KEY uk_responsavel_uid (uid),

  INDEX idx_email (email),
  INDEX idx_municipio (municipio)
) ENGINE=InnoDB;

-- ============================================================
-- TABELA 3: motoristas
-- ============================================================
CREATE TABLE motoristas (
  id                    INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  usuario_id            INT UNSIGNED NOT NULL,
  uid                   VARCHAR(28)  NOT NULL UNIQUE COMMENT 'Firebase UID',
  nome                  VARCHAR(120) NOT NULL,
  email                 VARCHAR(160) NOT NULL,
  telefone              VARCHAR(20)  NOT NULL,
  van_code              VARCHAR(10)  NOT NULL UNIQUE COMMENT 'Código da Van',
  cpf                   VARCHAR(255) NULL COMMENT 'CPF cifrado AES-256',
  foto_url              VARCHAR(500) NULL,

  vagas                 TINYINT UNSIGNED NOT NULL DEFAULT 0,
  aceitando_novos       TINYINT(1)       NOT NULL DEFAULT 1,

  avaliacao_media       DECIMAL(3,2)    NOT NULL DEFAULT 0.00,
  total_avaliacoes     INT UNSIGNED     NOT NULL DEFAULT 0,

  tem_seguro_app        TINYINT(1)      NOT NULL DEFAULT 0,

  atend_municipio       VARCHAR(100)    NULL,
  atend_uf              VARCHAR(2)      NULL,

  cnh_url               VARCHAR(500) NULL,
  vencimento_cnh        DATE NULL,
  crlv_url              VARCHAR(500) NULL,
  vencimento_vistoria   DATE NULL,
  vistoria_url          VARCHAR(500) NULL,
  seguro_url            VARCHAR(500) NULL,

  docs_verificados      TINYINT(1) NOT NULL DEFAULT 0,
  data_verificacao      DATE NULL,

  ativo                 TINYINT(1) NOT NULL DEFAULT 1,
  created_at            DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at            DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
  UNIQUE KEY uk_motorista_uid (uid),
  UNIQUE KEY uk_van_code (van_code),

  INDEX idx_van_code (van_code),
  INDEX idx_municipio (atend_municipio),
  INDEX idx_docs_verificados (docs_verificados)
) ENGINE=InnoDB;

-- ============================================================
-- TABELA 4: escolas
-- ============================================================
CREATE TABLE escolas (
  id             INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nome           VARCHAR(200) NOT NULL,
  tipo           ENUM('publica','privada','federal') NOT NULL DEFAULT 'publica',
  endereco       VARCHAR(255) NULL,
  numero         VARCHAR(10)  NULL,
  bairro         VARCHAR(100) NULL,
  municipio      VARCHAR(100) NOT NULL,
  estado         VARCHAR(2)  NOT NULL,
  cep            VARCHAR(9)   NULL,
  latitude       DECIMAL(10,7) NULL,
  longitude      DECIMAL(10,7) NULL,
  telefone       VARCHAR(20)  NULL,
  horario_inicio TIME NULL,
  horario_fim    TIME NULL,

  ibge_municipio_id  INT UNSIGNED NULL,
  ibge_municipio_nome VARCHAR(100) NULL,

  status         ENUM('pendente','homologado','recusado') NOT NULL DEFAULT 'pendente',
  data_homologacao DATE NULL,

  created_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  INDEX idx_municipio_estado (municipio, estado),
  INDEX idx_status (status),
  INDEX idx_ibge (ibge_municipio_id)
) ENGINE=InnoDB;

-- ============================================================
-- TABELA 5: alunos
-- ============================================================
CREATE TABLE alunos (
  id                    INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  uid                   VARCHAR(28)  NULL COMMENT 'Firebase UID do responsável',
  nome                  VARCHAR(120) NOT NULL,
  foto_url              VARCHAR(500) NULL,
  data_nascimento       DATE NULL,

  responsavel_nome      VARCHAR(120) NOT NULL,
  responsavel_telefone  VARCHAR(20)  NOT NULL,

  endereco              VARCHAR(255) NULL,
  bairro                VARCHAR(100) NULL,
  municipio             VARCHAR(100) NULL,
  estado                VARCHAR(2)   NULL,
  cep                   VARCHAR(9)   NULL,
  referencia_endereco   VARCHAR(255) NULL COMMENT 'Ponto de referência',
  latitude              DECIMAL(10,7) NULL,
  longitude             DECIMAL(10,7) NULL,

  escola_id             INT UNSIGNED NULL,
  serie                 VARCHAR(20)  NULL,
  turno                 ENUM('manha','tarde','noite','integral') NULL,

  motorista_id          INT UNSIGNED NULL,
  van_code              VARCHAR(10)  NULL COMMENT 'Código da Van',
  mensalidade_valor     DECIMAL(8,2) NULL DEFAULT 0.00,
  pago                  TINYINT(1)  NOT NULL DEFAULT 0,
  vencimento_mensalidade DATE NULL,

  ativo                 TINYINT(1) NOT NULL DEFAULT 1,
  created_at            DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at            DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  FOREIGN KEY (escola_id) REFERENCES escolas(id) ON DELETE SET NULL,
  FOREIGN KEY (motorista_id) REFERENCES motoristas(id) ON DELETE SET NULL,

  INDEX idx_uid (uid),
  INDEX idx_motorista (motorista_id),
  INDEX idx_escola (escola_id),
  INDEX idx_van_code (van_code),
  INDEX idx_pago (pago)
) ENGINE=InnoDB;

-- ============================================================
-- TABELA 6: mensalidades
-- ============================================================
CREATE TABLE mensalidades (
  id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  aluno_id        INT UNSIGNED NOT NULL,
  ano             SMALLINT UNSIGNED NOT NULL,
  mes             TINYINT UNSIGNED NOT NULL,
  valor           DECIMAL(8,2) NOT NULL DEFAULT 0.00,
  data_vencimento DATE NULL,
  data_pagamento  DATE NULL,
  status          ENUM('pendente','pago','atrasado','isento') NOT NULL DEFAULT 'pendente',
  forma_pagamento ENUM('dinheiro','pix','cartao','boleto','outro') NULL,
  observacao      VARCHAR(255) NULL,
  created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  FOREIGN KEY (aluno_id) REFERENCES alunos(id) ON DELETE CASCADE,

  UNIQUE KEY uk_aluno_ano_mes (aluno_id, ano, mes),
  INDEX idx_status (status),
  INDEX idx_vencimento (data_vencimento)
) ENGINE=InnoDB;

-- ============================================================
-- TABELA 7: avaliacoes
-- ============================================================
CREATE TABLE avaliacoes (
  id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  motorista_id    INT UNSIGNED NOT NULL,
  aluno_id       INT UNSIGNED NULL,
  responsavel_uid VARCHAR(28)  NULL,
  data_avaliacao  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

  nota_pontualidade  TINYINT UNSIGNED NOT NULL,
  nota_seguranca    TINYINT UNSIGNED NOT NULL,
  nota_cuidado      TINYINT UNSIGNED NOT NULL,
  nota_geral        DECIMAL(3,2) NOT NULL,

  comentario         TEXT NULL,
  resposta_motorista TEXT NULL,
  data_resposta      DATETIME NULL,

  FOREIGN KEY (motorista_id) REFERENCES motoristas(id) ON DELETE CASCADE,
  FOREIGN KEY (aluno_id)    REFERENCES alunos(id)    ON DELETE SET NULL,

  INDEX idx_motorista (motorista_id),
  INDEX idx_data (data_avaliacao)
) ENGINE=InnoDB;

-- ============================================================
-- TABELA 8: documentos
-- ============================================================
CREATE TABLE documentos (
  id             INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  motorista_id   INT UNSIGNED NULL,
  aluno_id       INT UNSIGNED NULL,
  responsavel_id INT UNSIGNED NULL,

  tipo           ENUM('cnh','crlv','vistoria','seguro','rg','cpf','comprovante','outro') NOT NULL,
  url            VARCHAR(500) NOT NULL,
  nome_arquivo   VARCHAR(255) NOT NULL,
  tamanho_bytes  INT UNSIGNED NULL,
  mime_type      VARCHAR(50)  NULL,
  validade       DATE NULL COMMENT 'Data de validade do documento',
  verificado     TINYINT(1)  NOT NULL DEFAULT 0,
  data_verificacao DATETIME NULL,
  observacao     VARCHAR(255) NULL,
  created_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

  FOREIGN KEY (motorista_id)   REFERENCES motoristas(id)   ON DELETE CASCADE,
  FOREIGN KEY (aluno_id)       REFERENCES alunos(id)       ON DELETE CASCADE,
  FOREIGN KEY (responsavel_id) REFERENCES responsaveis(id) ON DELETE CASCADE,

  INDEX idx_tipo (tipo),
  INDEX idx_motorista (motorista_id),
  INDEX idx_verificado (verificado)
) ENGINE=InnoDB;

-- ============================================================
-- TABELA 9: fotos
-- ============================================================
CREATE TABLE fotos (
  id             INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  referencia     ENUM('aluno','motorista','responsavel','escola','van','documento') NOT NULL,
  referencia_id  INT UNSIGNED NOT NULL COMMENT 'ID do registro',
  url            VARCHAR(500) NOT NULL,
  nome_arquivo   VARCHAR(255) NOT NULL,
  tamanho_bytes  INT UNSIGNED NULL,
  mime_type      VARCHAR(50)  NULL,
  principal      TINYINT(1)  NOT NULL DEFAULT 0 COMMENT '1 = foto principal',
  created_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

  INDEX idx_referencia (referencia, referencia_id),
  INDEX idx_principal (referencia, referencia_id, principal)
) ENGINE=InnoDB;

-- ============================================================
-- TABELA 10: cidades_atendidas
-- ============================================================
CREATE TABLE cidades_atendidas (
  id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  motorista_id    INT UNSIGNED NOT NULL,
  municipio       VARCHAR(100) NOT NULL,
  estado          VARCHAR(2)  NOT NULL,
  ibge_municipio_id INT UNSIGNED NULL,
  valor_mensal    DECIMAL(8,2) NULL DEFAULT 0.00 COMMENT 'Preço na cidade',
  created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

  FOREIGN KEY (motorista_id) REFERENCES motoristas(id) ON DELETE CASCADE,

  UNIQUE KEY uk_motorista_cidade (motorista_id, municipio, estado),
  INDEX idx_municipio (municipio, estado),
  INDEX idx_ibge (ibge_municipio_id)
) ENGINE=InnoDB;

-- ============================================================
-- TABELA 11: logs
-- ============================================================
CREATE TABLE logs (
  id             BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  evento         VARCHAR(50)  NOT NULL COMMENT 'Ex: ALUNO_CRIADO',
  tabela         VARCHAR(50)  NULL COMMENT 'Tabela afectada',
  registro_id    INT UNSIGNED NULL COMMENT 'ID do registo',
  uid            VARCHAR(28)  NULL COMMENT 'Utilizador',
  van_code       VARCHAR(10)  NULL,
  aluno_nome     VARCHAR(120) NULL,
  dados_anteriores TEXT NULL COMMENT 'JSON estado anterior',
  dados_novos     TEXT NULL COMMENT 'JSON estado novo',
  ip_origem      VARCHAR(45)  NULL,
  user_agent     VARCHAR(255) NULL,
  plataforma     ENUM('app','admin_web','api') NULL DEFAULT 'app',
  created_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

  INDEX idx_evento (evento),
  INDEX idx_tabela (tabela),
  INDEX idx_uid (uid),
  INDEX idx_van_code (van_code),
  INDEX idx_created_at (created_at)
) ENGINE=InnoDB;

-- ============================================================
-- PRONTO! Execute SHOW TABLES para confirmar
-- ============================================================
