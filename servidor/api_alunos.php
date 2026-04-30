<?php
/**
 * API Alunos — VanPro
 */
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('X-Api-Key: VanPro@2026#Secure');
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') { http_response_code(200); exit; }
require_once 'db_config.php';

function responder($data, $code = 200) { http_response_code($code); echo json_encode($data, JSON_UNESCAPED_UNICODE); exit; }
function erro($msg, $code = 400) { responder(['erro' => $msg], $code); }
function sanitizar($v) { return trim(htmlspecialchars($v, ENT_QUOTES, 'UTF-8')); }

$method = $_SERVER['REQUEST_METHOD'];
$path   = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
$path   = rtrim(str_replace('/api_alunos.php', '', $path), '/');
$id = null;
if (preg_match('#/(\d+)$#', $path, $m)) { $id = (int) $m[1]; $path = preg_replace('#/\d+$#', '', $path); }
$uidParam = isset($_GET['uid']) ? sanitizar($_GET['uid']) : null;
$vanParam = isset($_GET['vanCode']) ? sanitizar($_GET['vanCode']) : null;

if ($method === 'GET') {
    if ($uidParam) {
        $stmt = $pdo->prepare("SELECT * FROM alunos WHERE uid = :uid ORDER BY nome");
        $stmt->execute(['uid' => $uidParam]);
    } elseif ($vanParam) {
        $stmt = $pdo->prepare("SELECT * FROM alunos WHERE van_code = :v AND ativo = 1 ORDER BY nome");
        $stmt->execute(['v' => $vanParam]);
    } elseif ($id) {
        $stmt = $pdo->prepare("SELECT * FROM alunos WHERE id = :id LIMIT 1");
        $stmt->execute(['id' => $id]);
    } else {
        $stmt = $pdo->query("SELECT * FROM alunos WHERE ativo = 1 ORDER BY nome");
    }
    responder($stmt->fetchAll(PDO::FETCH_ASSOC));
}

if ($method === 'POST') {
    $body = json_decode(file_get_contents('php://input'), true);
    if (empty($body['nome'])) erro('nome é obrigatório');
    if (empty($body['responsavel_nome'])) erro('responsavel_nome é obrigatório');
    if (empty($body['responsavel_telefone'])) erro('responsavel_telefone é obrigatório');

    $stmt = $pdo->prepare("INSERT INTO alunos (uid, nome, foto_url, data_nascimento, responsavel_nome, responsavel_telefone, endereco, bairro, municipio, estado, cep, referencia_endereco, latitude, longitude, escola_id, serie, turno, motorista_id, van_code, mensalidade_valor, pago, vencimento_mensalidade) VALUES (:uid, :nome, :foto, :nasc, :resp_nome, :resp_tel, :end, :bairro, :mun, :uf, :cep, :ref, :lat, :lng, :esc, :serie, :turno, :mot, :van, :val, :pago, :venc)");
    $stmt->execute([
        'uid' => $body['uid'] ?? null,
        'nome' => sanitizar($body['nome']),
        'foto' => $body['foto_url'] ?? null,
        'nasc' => $body['data_nascimento'] ?? null,
        'resp_nome' => sanitizar($body['responsavel_nome']),
        'resp_tel' => sanitizar($body['responsavel_telefone']),
        'end' => $body['endereco'] ?? null,
        'bairro' => $body['bairro'] ?? null,
        'mun' => $body['municipio'] ?? null,
        'uf' => $body['estado'] ?? null,
        'cep' => $body['cep'] ?? null,
        'ref' => $body['referencia_endereco'] ?? null,
        'lat' => $body['latitude'] ?? null,
        'lng' => $body['longitude'] ?? null,
        'esc' => $body['escola_id'] ?? null,
        'serie' => $body['serie'] ?? null,
        'turno' => $body['turno'] ?? null,
        'mot' => $body['motorista_id'] ?? null,
        'van' => $body['van_code'] ?? null,
        'val' => $body['mensalidade_valor'] ?? 0.00,
        'pago' => $body['pago'] ?? 0,
        'venc' => $body['vencimento_mensalidade'] ?? null,
    ]);
    $novoId = $pdo->lastInsertId();
    responder(['id' => $novoId, 'servidorid' => $novoId], 201);
}

if ($method === 'PUT' && $id) {
    $body = json_decode(file_get_contents('php://input'), true);
    $campos = []; $valores = ['id' => $id];
    $camposPermitidos = ['nome','foto_url','data_nascimento','responsavel_nome','responsavel_telefone','endereco','bairro','municipio','estado','cep','referencia_endereco','latitude','longitude','escola_id','serie','turno','motorista_id','van_code','mensalidade_valor','pago','vencimento_mensalidade','ativo'];
    foreach ($camposPermitidos as $c) { if (isset($body[$c])) { $campos[] = "$c = :$c"; $valores[$c] = $body[$c]; } }
    if (empty($campos)) erro('Nenhum campo para atualizar');
    $pdo->prepare("UPDATE alunos SET " . implode(', ', $campos) . " WHERE id = :id")->execute($valores);
    responder(['mensagem' => 'Atualizado']);
}

if ($method === 'DELETE' && $id) {
    $pdo->prepare("UPDATE alunos SET ativo = 0 WHERE id = :id")->execute(['id' => $id]);
    responder(['mensagem' => 'Desativado']);
}

erro('Método não suportado');
