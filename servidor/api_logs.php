<?php
/**
 * API Logs — VanPro
 */
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('X-Api-Key: VanPro@2026#Secure');
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') { http_response_code(200); exit; }
require_once 'db_config.php';

function responder($data, $code = 200) { http_response_code($code); echo json_encode($data, JSON_UNESCAPED_UNICODE); exit; }
function erro($msg, $code = 400) { responder(['erro' => $msg], $code); }

$method = $_SERVER['REQUEST_METHOD'];
$uidParam = isset($_GET['uid']) ? trim($_GET['uid']) : null;
$vanParam = isset($_GET['vanCode']) ? trim($_GET['vanCode']) : null;

if ($method === 'GET') {
    if ($uidParam) {
        $stmt = $pdo->prepare("SELECT * FROM logs WHERE uid = :u ORDER BY created_at DESC LIMIT 100");
        $stmt->execute(['u' => $uidParam]);
    } elseif ($vanParam) {
        $stmt = $pdo->prepare("SELECT * FROM logs WHERE van_code = :v ORDER BY created_at DESC LIMIT 100");
        $stmt->execute(['v' => $vanParam]);
    } else {
        $stmt = $pdo->query("SELECT * FROM logs ORDER BY created_at DESC LIMIT 200");
    }
    responder($stmt->fetchAll(PDO::FETCH_ASSOC));
}

if ($method === 'POST') {
    $body = json_decode(file_get_contents('php://input'), true);
    $stmt = $pdo->prepare("INSERT INTO logs (evento, tabela, registro_id, uid, van_code, aluno_nome, dados_anteriores, dados_novos, ip_origem, user_agent, plataforma) VALUES (:e, :t, :r, :u, :v, :a, :da, :dn, :ip, :ua, :p)");
    $stmt->execute([
        'e' => $body['evento'] ?? 'LOG', 't' => $body['tabela'] ?? null,
        'r' => $body['registro_id'] ?? null, 'u' => $body['uid'] ?? null,
        'v' => $body['van_code'] ?? null, 'a' => $body['aluno_nome'] ?? null,
        'da' => $body['dados_anteriores'] ?? null, 'dn' => $body['dados_novos'] ?? null,
        'ip' => $_SERVER['REMOTE_ADDR'] ?? null, 'ua' => $_SERVER['HTTP_USER_AGENT'] ?? null,
        'p' => $body['plataforma'] ?? 'app',
    ]);
    responder(['id' => $pdo->lastInsertId()], 201);
}

erro('Método não suportado');
