-- ============================================================
-- LIMPEZA COMPLETA DO BANCO — VanPro
-- Execute TODOS os comandos um por um no phpMyAdmin
-- ============================================================

-- PASSO 1: Desativar verificação de chaves
SET FOREIGN_KEY_CHECKS = 0;

-- PASSO 2: Apagar cada tabela individualmente
-- (Execute UM por UM se necessário)
SET FOREIGN_KEY_CHECKS = 0;
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

-- PASSO 3: Verificar se todas foram apagadas
SHOW TABLES;

-- Se aparecer alguma tabela acima, execute DROP TABLE manualmente para ela
