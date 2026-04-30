<?php
/**
 * API Avaliações — VanPro
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
$path   = rtrim(str_replace('/api_avaliacoes.php', '', $path), '/');
$id = null;
if (preg_match('#/(\d+)$#', $path, $m)) { $id = (int) $m[1]; $path = preg_replace('#/\d+$#', '', $path); }
$motParam = isset($_GET['motorista_id']) ? (int)$_GET['motorista_id'] : null;

if ($method === 'GET') {
    if ($id) {
        $stmt = $pdo->prepare("SELECT * FROM avaliacoes WHERE id = :id LIMIT 1");
        $stmt->execute(['id' => $id]);
    } elseif ($motParam) {
        $stmt = $pdo->prepare("SELECT * FROM avaliacoes WHERE motorista_id = :m ORDER BY data_avaliacao DESC");
        $stmt->execute(['m' => $motParam]);
    } else {
        $stmt = $pdo->query("SELECT * FROM avaliacoes ORDER BY data_avaliacao DESC");
    }
    responder($stmt->fetchAll(PDO::FETCH_ASSOC));
}

if ($method === 'POST') {
    $body = json_decode(file_get_contents('php://input'), true);
    if (empty($body['motorista_id'])) erro('motorista_id é obrigatório');
    if (!isset($body['nota_pontualidade']) || !isset($body['nota_seguranca']) || !isset($body['nota_cuidado'])) erro('notas são obrigatórias');

    $notaGeral = (($body['nota_pontualidade'] + $body['nota_seguranca'] + $body['nota_cuidado']) / 3);

    $stmt = $pdo->prepare("INSERT INTO avaliacoes (motorista_id, aluno_id, responsavel_uid, nota_pontualidade, nota_seguranca, nota_cuidado, nota_geral, comentario) VALUES (:m, :a, :u, :np, :ns, :nc, :ng, :c)");
    $stmt->execute([
        'm' => (int)$body['motorista_id'], 'a' => $body['aluno_id'] ?? null,
        'u' => $body['responsavel_uid'] ?? null,
        'np' => (int)$body['nota_pontualidade'], 'ns' => (int)$body['nota_seguranca'],
        'nc' => (int)$body['nota_cuidado'], 'ng' => round($notaGeral, 2),
        'c' => $body['comentario'] ?? null,
    ]);
    responder(['id' => $pdo->lastInsertId()], 201);
}

erro('Método não suportado');
