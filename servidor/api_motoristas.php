<?php
/**
 * API Motoristas — VanPro
 * CRUD completo de motoristas no MySQL
 */

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('X-Api-Key: VanPro@2026#Secure');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

require_once 'db_config.php';

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

function cifrarCpf($cpf) {
    // Cifragem AES-256 — a chave deve estar em db_config.php
    $key = defined('CIPHER_KEY') ? CIPHER_KEY : 'VanPro_Secret_Key_2026';
    return openssl_encrypt($cpf, 'AES-256-CBC', $key, 0, substr(md5($key), 0, 16));
}

// ==========================================================
// ROTEAMENTO
// ==========================================================

$method = $_SERVER['REQUEST_METHOD'];
$path   = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
$path   = rtrim(str_replace('/api_motoristas.php', '', $path), '/');

$id = null;
if (preg_match('#/(\d+)$#', $path, $m)) {
    $id = (int) $m[1];
    $path = preg_replace('#/\d+$#', '', $path);
}

$uidParam   = isset($_GET['uid'])      ? sanitizar($_GET['uid']) : null;
$vanParam   = isset($_GET['vanCode']) ? sanitizar($_GET['vanCode']) : null;
$emailParam = isset($_GET['email'])   ? sanitizar($_GET['email']) : null;

// ==========================================================
// GET — Buscar
// ==========================================================
if ($method === 'GET') {

    if ($uidParam) {
        $stmt = $pdo->prepare("SELECT * FROM motoristas WHERE uid = :uid LIMIT 1");
        $stmt->execute(['uid' => $uidParam]);
    }
    elseif ($vanParam) {
        $stmt = $pdo->prepare("SELECT * FROM motoristas WHERE van_code = :van LIMIT 1");
        $stmt->execute(['van' => $vanParam]);
    }
    elseif ($emailParam) {
        $stmt = $pdo->prepare("SELECT * FROM motoristas WHERE email = :email LIMIT 1");
        $stmt->execute(['email' => $emailParam]);
    }
    elseif ($id) {
        $stmt = $pdo->prepare("SELECT * FROM motoristas WHERE id = :id LIMIT 1");
        $stmt->execute(['id' => $id]);
    }
    else {
        $stmt = $pdo->query("SELECT * FROM motoristas ORDER BY nome");
    }

    $dados = $stmt->fetchAll(PDO::FETCH_ASSOC);
    responder($dados);
}

// ==========================================================
// POST — Criar motorista
// ==========================================================
if ($method === 'POST') {
    $body = json_decode(file_get_contents('php://input'), true);

    if (empty($body['uid']))       erro('uid é obrigatório', 400);
    if (empty($body['nome']))      erro('nome é obrigatório', 400);
    if (empty($body['email']))     erro('email é obrigatório', 400);
    if (empty($body['telefone']))  erro('telefone é obrigatório', 400);
    if (empty($body['vanCode']))   erro('vanCode é obrigatório', 400);

    // Verifica duplicados
    $check = $pdo->prepare("SELECT id FROM motoristas WHERE uid = :u OR email = :e OR van_code = :v LIMIT 1");
    $check->execute(['u' => $body['uid'], 'e' => strtolower($body['email']), 'v' => strtoupper($body['vanCode'])]);
    if ($check->fetch()) erro('Motorista já cadastrado (uid, email ou vanCode)', 409);

    // Insere em usuarios
    $stmtUser = $pdo->prepare("
        INSERT INTO usuarios (uid, role, nome, email, telefone)
        VALUES (:uid, 'motorista', :nome, :email, :telefone)
    ");
    $stmtUser->execute([
        'uid'      => $body['uid'],
        'nome'     => sanitizar($body['nome']),
        'email'    => strtolower(sanitizar($body['email'])),
        'telefone' => sanitizar($body['telefone']),
    ]);
    $usuarioId = $pdo->lastInsertId();

    // Insere em motoristas
    $stmt = $pdo->prepare("
        INSERT INTO motoristas
          (usuario_id, uid, nome, email, telefone, van_code, cpf,
           vagas, aceitando_novos, atend_municipio, atend_uf,
           cnh_url, crlv_url, vistoria_url)
        VALUES
          (:usuario_id, :uid, :nome, :email, :telefone, :van_code, :cpf,
           :vagas, 1, :municipio, :uf, :cnh, :crlv, :vistoria)
    ");
    $stmt->execute([
        'usuario_id' => $usuarioId,
        'uid'        => $body['uid'],
        'nome'       => sanitizar($body['nome']),
        'email'      => strtolower(sanitizar($body['email'])),
        'telefone'   => sanitizar($body['telefone']),
        'van_code'   => strtoupper(sanitizar($body['vanCode'])),
        'cpf'        => isset($body['cpf']) ? cifrarCpf($body['cpf']) : null,
        'vagas'      => (int)($body['vagas'] ?? 0),
        'municipio'  => $body['atendMunicipio'] ?? null,
        'uf'         => $body['atendUf'] ?? null,
        'cnh'        => $body['cnhUrl'] ?? null,
        'crlv'       => $body['crlvUrl'] ?? null,
        'vistoria'   => $body['vistoriaUrl'] ?? null,
    ]);
    $servidorId = $pdo->lastInsertId();

    responder([
        'mensagem'   => 'Motorista criado com sucesso',
        'id'         => $servidorId,
        'servidorid' => $servidorId,
        'usuario_id' => $usuarioId,
    ], 201);
}

// ==========================================================
// PUT — Atualizar motorista
// ==========================================================
if ($method === 'PUT') {
    if (!$id) erro('ID é obrigatório', 400);

    $body = json_decode(file_get_contents('php://input'), true);
    $campos = [];
    $valores = ['id' => $id];

    $camposPermitidos = [
        'nome', 'telefone', 'van_code', 'cpf', 'foto_url', 'vagas',
        'aceitando_novos', 'tem_seguro_app', 'atend_municipio', 'atend_uf',
        'cnh_url', 'vencimento_cnh', 'crlv_url', 'vencimento_vistoria',
        'vistoria_url', 'seguro_url', 'ativo',
    ];

    foreach ($camposPermitidos as $campo) {
        $chaveApp = $campo; // snake_case directo
        if ($campo === 'cpf' && isset($body[$chaveApp])) {
            $valores[$chaveApp] = cifrarCpf($body[$chaveApp]);
            $campos[] = "$campo = :$chaveApp";
        }
        elseif (isset($body[$chaveApp])) {
            $valores[$chaveApp] = $body[$chaveApp];
            $campos[] = "$campo = :$chaveApp";
        }
    }

    if (empty($campos)) erro('Nenhum campo para atualizar', 400);

    $sql = "UPDATE motoristas SET " . implode(', ', $campos) . " WHERE id = :id";
    $pdo->prepare($sql)->execute($valores);

    responder(['mensagem' => 'Atualizado com sucesso']);
}

// ==========================================================
// DELETE — Excluir motorista
// ==========================================================
if ($method === 'DELETE') {
    if (!$id) erro('ID é obrigatório', 400);

    $pdo->prepare("DELETE FROM motoristas WHERE id = :id")->execute(['id' => $id]);
    responder(['mensagem' => 'Excluído com sucesso']);
}

erro('Método não suportado', 405);
