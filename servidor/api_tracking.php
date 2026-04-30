<?php
/**
 * API Tracking/GPS — VanPro
 * Histórico de localização das vans
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
$vanParam = isset($_GET['vanCode']) ? trim($_GET['vanCode']) : null;
$hoje = date('Y-m-d');

if ($method === 'GET') {
    if ($vanParam) {
        $stmt = $pdo->prepare("SELECT * FROM logs WHERE van_code = :v AND DATE(created_at) = :d AND evento LIKE 'TRACKING%' ORDER BY created_at ASC");
        $stmt->execute(['v' => $vanParam, 'd' => $hoje]);
    } else {
        $stmt = $pdo->query("SELECT * FROM logs WHERE evento LIKE 'TRACKING%' AND DATE(created_at) = '$hoje' ORDER BY created_at ASC");
    }
    responder($stmt->fetchAll(PDO::FETCH_ASSOC));
}

if ($method === 'POST') {
    $body = json_decode(file_get_contents('php://input'), true);
    $stmt = $pdo->prepare("INSERT INTO logs (evento, tabela, van_code, uid, dados_novos, ip_origem, plataforma) VALUES ('TRACKING_GPS', 'tracking', :v, :u, :d, :ip, 'app')");
    $stmt->execute([
        'v' => $body['vanCode'] ?? null, 'u' => $body['uid'] ?? null,
        'd' => json_encode(['lat' => $body['latitude'] ?? 0, 'lng' => $body['longitude'] ?? 0, 'velocidade' => $body['velocidade'] ?? 0]),
        'ip' => $_SERVER['REMOTE_ADDR'] ?? null,
    ]);
    responder(['id' => $pdo->lastInsertId()], 201);
}

erro('Método não suportado');
