<?php
/**
 * API Escolas — VanPro
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
$path   = rtrim(str_replace('/api_escolas.php', '', $path), '/');
$id = null;
if (preg_match('#/(\d+)$#', $path, $m)) { $id = (int) $m[1]; $path = preg_replace('#/\d+$#', '', $path); }
$statusParam = isset($_GET['status']) ? sanitizar($_GET['status']) : null;
$munParam = isset($_GET['municipio']) ? sanitizar($_GET['municipio']) : null;

if ($method === 'GET') {
    if ($id) {
        $stmt = $pdo->prepare("SELECT * FROM escolas WHERE id = :id LIMIT 1");
        $stmt->execute(['id' => $id]);
    } elseif ($statusParam) {
        $stmt = $pdo->prepare("SELECT * FROM escolas WHERE status = :s ORDER BY nome");
        $stmt->execute(['s' => $statusParam]);
    } elseif ($munParam) {
        $stmt = $pdo->prepare("SELECT * FROM escolas WHERE municipio LIKE :mun ORDER BY nome");
        $stmt->execute(['mun' => "%$munParam%"]);
    } else {
        $stmt = $pdo->query("SELECT * FROM escolas ORDER BY nome");
    }
    responder($stmt->fetchAll(PDO::FETCH_ASSOC));
}

if ($method === 'POST') {
    $body = json_decode(file_get_contents('php://input'), true);
    if (empty($body['nome'])) erro('nome é obrigatório');
    if (empty($body['municipio'])) erro('municipio é obrigatório');
    if (empty($body['estado'])) erro('estado é obrigatório');

    $stmt = $pdo->prepare("INSERT INTO escolas (nome, tipo, endereco, numero, bairro, municipio, estado, cep, latitude, longitude, telefone, horario_inicio, horario_fim, ibge_municipio_id, ibge_municipio_nome, status) VALUES (:n, :t, :e, :num, :b, :m, :uf, :c, :lat, :lng, :tel, :hi, :hf, :ibge, :ibge_nome, :s)");
    $stmt->execute([
        'n' => sanitizar($body['nome']), 't' => $body['tipo'] ?? 'publica',
        'e' => $body['endereco'] ?? null, 'num' => $body['numero'] ?? null,
        'b' => $body['bairro'] ?? null, 'm' => sanitizar($body['municipio']),
        'uf' => strtoupper(sanitizar($body['estado'])), 'c' => $body['cep'] ?? null,
        'lat' => $body['latitude'] ?? null, 'lng' => $body['longitude'] ?? null,
        'tel' => $body['telefone'] ?? null, 'hi' => $body['horario_inicio'] ?? null,
        'hf' => $body['horario_fim'] ?? null, 'ibge' => $body['ibge_municipio_id'] ?? null,
        'ibge_nome' => $body['ibge_municipio_nome'] ?? null, 's' => $body['status'] ?? 'pendente',
    ]);
    responder(['id' => $pdo->lastInsertId()], 201);
}

if ($method === 'PUT' && $id) {
    $body = json_decode(file_get_contents('php://input'), true);
    $campos = []; $valores = ['id' => $id];
    $camposPermitidos = ['nome','tipo','endereco','numero','bairro','municipio','estado','cep','latitude','longitude','telefone','horario_inicio','horario_fim','ibge_municipio_id','ibge_municipio_nome','status','data_homologacao'];
    foreach ($camposPermitidos as $c) { if (isset($body[$c])) { $campos[] = "$c = :$c"; $valores[$c] = $body[$c]; } }
    if (empty($campos)) erro('Nenhum campo para atualizar');
    $pdo->prepare("UPDATE escolas SET " . implode(', ', $campos) . " WHERE id = :id")->execute($valores);
    responder(['mensagem' => 'Atualizado']);
}

erro('Método não suportado');
