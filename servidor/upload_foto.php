<?php
/**
 * Upload de Fotos — VanPro
 */
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('X-Api-Key: VanPro@2026#Secure');
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') { http_response_code(200); exit; }

require_once 'db_config.php';

function responder($data, $code = 200) { http_response_code($code); echo json_encode($data, JSON_UNESCAPED_UNICODE); exit; }
function erro($msg, $code = 400) { responder(['erro' => $msg], $code); }

if ($_SERVER['REQUEST_METHOD'] !== 'POST') erro('Método não suportado');

$ref     = isset($_POST['referencia']) ? trim($_POST['referencia']) : null;
$refId   = isset($_POST['referencia_id']) ? (int)$_POST['referencia_id'] : null;
$tipo    = isset($_POST['tipo']) ? trim($_POST['tipo']) : 'foto';

if (!$ref || !$refId) erro('referencia e referencia_id são obrigatórios');

if (!isset($_FILES['arquivo'])) erro('Nenhum arquivo enviado');

$file = $_FILES['arquivo'];
if ($file['error'] !== UPLOAD_ERR_OK) erro('Erro no upload: ' . $file['error']);

// Extensões permitidas
$permitidas = ['jpg','jpeg','png','gif','webp','pdf'];
$ext = strtolower(pathinfo($file['name'], PATHINFO_EXTENSION));
if (!in_array($ext, $permitidas)) erro('Tipo de arquivo não permitido');

// Tamanho máximo 10MB
if ($file['size'] > 10 * 1024 * 1024) erro('Arquivo muito grande (máx 10MB)');

// Gera nome único
$nomeUnico = uniqid('vp_') . '_' . time() . '.' . $ext;
$pastaUpload = __DIR__ . '/uploads/';
if (!is_dir($pastaUpload)) mkdir($pastaUpload, 0755, true);

$caminhoDestino = $pastaUpload . $nomeUnico;
if (!move_uploaded_file($file['tmp_name'], $caminhoDestino)) erro('Erro ao mover arquivo');

$url = 'https://van-pro.balcao2ponto0.com.br/uploads/' . $nomeUnico;

// Salva na tabela fotos
$stmt = $pdo->prepare("INSERT INTO fotos (referencia, referencia_id, url, nome_arquivo, tamanho_bytes, mime_type, principal) VALUES (:r, :rid, :u, :n, :t, :m, :p)");
$stmt->execute([
    'r' => $ref, 'rid' => $refId, 'u' => $url,
    'n' => $file['name'], 't' => $file['size'],
    'm' => $file['type'], 'p' => ($tipo === 'principal' ? 1 : 0),
]);

responder(['url' => $url, 'id' => $pdo->lastInsertId()], 201);
