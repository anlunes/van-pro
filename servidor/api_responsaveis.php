<?php
/**
 * API Responsáveis — VanPro
 * CRUD completo de responsáveis no MySQL
 */

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('X-Api-Key: VanPro@2026#Secure');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

require_once 'db_config.php'; // Conexão PDO $pdo

// ==========================================================
// FUNÇÕES AUXILIARES
// ==========================================================

function responder($data, $code = 200) {
    http_response_code($code);
    echo json_encode($data, JSON_UNESCAPED_UNICODE);
    exit;
}

function erro($msg, $code = 400) {
    responder(['erro' => $msg], $code);
}

function sanitizar($valor) {
    return trim(htmlspecialchars($valor, ENT_QUOTES, 'UTF-8'));
}

// ==========================================================
// ROTEAMENTO
// ==========================================================

$method = $_SERVER['REQUEST_METHOD'];
$path   = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
$path   = rtrim(str_replace('/api_responsaveis.php', '', $path), '/');

// Extrai ID se presente: /api_responsaveis.php/123
$id = null;
if (preg_match('#/(\d+)$#', $path, $m)) {
    $id = (int) $m[1];
    $path = preg_replace('#/\d+$#', '', $path);
}

// Parâmetros GET
$uidParam = isset($_GET['uid']) ? sanitizar($_GET['uid']) : null;
$emailParam = isset($_GET['email']) ? sanitizar($_GET['email']) : null;

// ==========================================================
// GET — Listar ou buscar
// ==========================================================
if ($method === 'GET') {

    // Buscar por UID
    if ($uidParam) {
        $stmt = $pdo->prepare("SELECT r.* FROM responsaveis r WHERE r.uid = :uid LIMIT 1");
        $stmt->execute(['uid' => $uidParam]);
    }
    // Buscar por e-mail
    elseif ($emailParam) {
        $stmt = $pdo->prepare("SELECT r.* FROM responsaveis r WHERE r.email = :email LIMIT 1");
        $stmt->execute(['email' => $emailParam]);
    }
    // Buscar por ID
    elseif ($id) {
        $stmt = $pdo->prepare("SELECT r.* FROM responsaveis r WHERE r.id = :id LIMIT 1");
        $stmt->execute(['id' => $id]);
    }
    // Listar todos
    else {
        $stmt = $pdo->query("SELECT r.* FROM responsaveis r ORDER BY r.nome");
    }

    $dados = $stmt->fetchAll(PDO::FETCH_ASSOC);
    responder($dados);
}

// ==========================================================
// POST — Criar responsável
// ==========================================================
if ($method === 'POST') {
    $body = json_decode(file_get_contents('php://input'), true);

    if (empty($body['uid']))  erro('uid é obrigatório', 400);
    if (empty($body['nome']))  erro('nome é obrigatório', 400);
    if (empty($body['email'])) erro('email é obrigatório', 400);
    if (empty($body['telefone'])) erro('telefone é obrigatório', 400);

    // Verifica se já existe
    $check = $pdo->prepare("SELECT id FROM responsaveis WHERE uid = :uid OR email = :email LIMIT 1");
    $check->execute(['uid' => $body['uid'], 'email' => $body['email']]);
    if ($check->fetch()) erro('Responsável já cadastrado', 409);

    // Insere na tabela usuarios primeiro
    $stmtUser = $pdo->prepare("
        INSERT INTO usuarios (uid, role, nome, email, telefone)
        VALUES (:uid, 'responsavel', :nome, :email, :telefone)
    ");
    $stmtUser->execute([
        'uid'      => $body['uid'],
        'nome'     => sanitizar($body['nome']),
        'email'    => strtolower(sanitizar($body['email'])),
        'telefone' => sanitizar($body['telefone']),
    ]);
    $usuarioId = $pdo->lastInsertId();

    // Insere na tabela responsaveis
    $stmt = $pdo->prepare("
        INSERT INTO responsaveis
          (usuario_id, uid, nome, email, telefone, endereco, bairro, municipio, estado, cep)
        VALUES
          (:usuario_id, :uid, :nome, :email, :telefone, :endereco, :bairro, :municipio, :estado, :cep)
    ");
    $stmt->execute([
        'usuario_id' => $usuarioId,
        'uid'        => $body['uid'],
        'nome'       => sanitizar($body['nome']),
        'email'      => strtolower(sanitizar($body['email'])),
        'telefone'   => sanitizar($body['telefone']),
        'endereco'   => $body['endereco']  ?? null,
        'bairro'     => $body['bairro']    ?? null,
        'municipio'  => $body['municipio'] ?? null,
        'estado'     => $body['estado']    ?? null,
        'cep'        => $body['cep']       ?? null,
    ]);
    $servidorId = $pdo->lastInsertId();

    responder([
        'mensagem'   => 'Responsável criado com sucesso',
        'id'         => $servidorId,
        'servidorid' => $servidorId,
        'usuario_id' => $usuarioId,
    ], 201);
}

// ==========================================================
// PUT — Atualizar responsável
// ==========================================================
if ($method === 'PUT') {
    if (!$id) erro('ID é obrigatório', 400);

    $body = json_decode(file_get_contents('php://input'), true);

    $campos = [];
    $valores = ['id' => $id];

    if (isset($body['nome']))       { $campos[] = 'nome = :nome';       $valores['nome']       = sanitizar($body['nome']); }
    if (isset($body['telefone']))   { $campos[] = 'telefone = :telefone'; $valores['telefone']   = sanitizar($body['telefone']); }
    if (isset($body['endereco']))   { $campos[] = 'endereco = :endereco'; $valores['endereco']   = $body['endereco']; }
    if (isset($body['bairro']))     { $campos[] = 'bairro = :bairro';     $valores['bairro']     = $body['bairro']; }
    if (isset($body['municipio']))  { $campos[] = 'municipio = :municipio'; $valores['municipio'] = $body['municipio']; }
    if (isset($body['estado']))     { $campos[] = 'estado = :estado';     $valores['estado']     = $body['estado']; }
    if (isset($body['cep']))        { $campos[] = 'cep = :cep';           $valores['cep']         = $body['cep']; }

    if (empty($campos)) erro('Nenhum campo para atualizar', 400);

    // Atualiza responsaveis
    $sql = "UPDATE responsaveis SET " . implode(', ', $campos) . " WHERE id = :id";
    $stmt = $pdo->prepare($sql);
    $stmt->execute($valores);

    // Atualiza usuarios (nome + telefone)
    $stmtUser = $pdo->prepare("
        UPDATE usuarios SET nome = :nome, telefone = :telefone WHERE id = (SELECT usuario_id FROM responsaveis WHERE id = :id)
    ");
    $stmtUser->execute([
        'nome'     => $valores['nome']     ?? '---',
        'telefone' => $valores['telefone'] ?? '---',
        'id'       => $id,
    ]);

    responder(['mensagem' => 'Atualizado com sucesso']);
}

// ==========================================================
// DELETE — Excluir responsável
// ==========================================================
if ($method === 'DELETE') {
    if (!$id) erro('ID é obrigatório', 400);

    $stmt = $pdo->prepare("DELETE FROM responsaveis WHERE id = :id");
    $stmt->execute(['id' => $id]);

    responder(['mensagem' => 'Excluído com sucesso']);
}

erro('Método não suportado', 405);
