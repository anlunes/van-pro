<?php
/**
 * Configuração de conexão ao banco de dados — VanPro
 * Dados do servidor antigo
 */

define('DB_HOST', 'localhost');
define('DB_USER', 'balcao2p');
define('DB_PASS', 'Mysql26@');
define('DB_NAME', 'balcao2p_vanpro');
define('API_KEY', 'VanPro@2026#Secure');

// Chave para cifrar CPF (AES-256-CBC)
define('CIPHER_KEY', 'VanPro_Secret_Key_2026_AES');

// ==========================================================
// Conexão PDO
// ==========================================================
try {
    $pdo = new PDO(
        'mysql:host=' . DB_HOST . ';dbname=' . DB_NAME . ';charset=utf8mb4',
        DB_USER,
        DB_PASS,
        [
            PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES   => false,
        ]
    );
} catch (PDOException $e) {
    http_response_code(503);
    echo json_encode(['erro' => 'Erro de conexão com o banco de dados']);
    exit;
}
