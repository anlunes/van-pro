<?php
/**
 * API Mensalidades — VanPro
 */
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, OPTIONS');
header('X-Api-Key: VanPro@2026#Secure');
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') { http_response_code(200); exit; }
require_once 'db_config.php';

function responder($data, $code = 200) { http_response_code($code); echo json_encode($data, JSON_UNESCAPED_UNICODE); exit; }
function erro($msg, $code = 400) { responder(['erro' => $msg], $code); }

$method = $_SERVER['REQUEST_METHOD'];
$path   = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
$path   = rtrim(str_replace('/api_mensalidades.php', '', $path), '/');
$id = null;
if (preg_match('#/(\d+)$#', $path, $m)) { $id = (int) $m[1]; $path = preg_replace('#/\d+$#', '', $path); }
$alunoParam = isset($_GET['aluno_id']) ? (int)$_GET['aluno_id'] : null;

if ($method === 'GET') {
    if ($id) {
        $stmt = $pdo->prepare("SELECT * FROM mensalidades WHERE id = :id LIMIT 1");
        $stmt->execute(['id' => $id]);
    } elseif ($alunoParam) {
        $stmt = $pdo->prepare("SELECT * FROM mensalidades WHERE aluno_id = :a ORDER BY ano DESC, mes DESC");
        $stmt->execute(['a' => $alunoParam]);
    } else {
        $stmt = $pdo->query("SELECT * FROM mensalidades ORDER BY ano DESC, mes DESC");
    }
    responder($stmt->fetchAll(PDO::FETCH_ASSOC));
}

if ($method === 'POST') {
    $body = json_decode(file_get_contents('php://input'), true);
    if (empty($body['aluno_id'])) erro('aluno_id é obrigatório');
    if (empty($body['ano'])) erro('ano é obrigatório');
    if (empty($body['mes'])) erro('mes é obrigatório');

    $stmt = $pdo->prepare("INSERT INTO mensalidades (aluno_id, ano, mes, valor, data_vencimento, data_pagamento, status, forma_pagamento, observacao) VALUES (:a, :ano, :m, :v, :dv, :dp, :s, :fp, :obs)");
    $stmt->execute([
        'a' => (int)$body['aluno_id'], 'ano' => (int)$body['ano'], 'm' => (int)$body['mes'],
        'v' => $body['valor'] ?? 0.00, 'dv' => $body['data_vencimento'] ?? null,
        'dp' => $body['data_pagamento'] ?? null, 's' => $body['status'] ?? 'pendente',
        'fp' => $body['forma_pagamento'] ?? null, 'obs' => $body['observacao'] ?? null,
    ]);
    responder(['id' => $pdo->lastInsertId()], 201);
}

if ($method === 'PUT' && $id) {
    $body = json_decode(file_get_contents('php://input'), true);
    $campos = []; $valores = ['id' => $id];
    $camposPermitidos = ['valor','data_vencimento','data_pagamento','status','forma_pagamento','observacao'];
    foreach ($camposPermitidos as $c) { if (isset($body[$c])) { $campos[] = "$c = :$c"; $valores[$c] = $body[$c]; } }
    if (empty($campos)) erro('Nenhum campo para atualizar');
    $pdo->prepare("UPDATE mensalidades SET " . implode(', ', $campos) . " WHERE id = :id")->execute($valores);
    responder(['mensagem' => 'Atualizado']);
}

erro('Método não suportado');
