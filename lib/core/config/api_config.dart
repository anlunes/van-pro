/// Configurações centralizadas de API e servidor.
/// Todas as URLs, chaves e constantes de rede ficam aqui.
class ApiConfig {
  ApiConfig._();

  // ── Servidor principal (PHP/MySQL) ────────────────────────────────
  static const String baseUrl = 'https://van-pro.balcao2ponto0.com.br';
  static const String apiKey = 'VanPro@2026#Secure';

  // ── Endpoints ─────────────────────────────────────────────────────
  static const String alunosEndpoint = '$baseUrl/api_alunos.php/alunos';
  static const String motoristasEndpoint = '$baseUrl/api_motoristas.php/motoristas';
  static const String avaliacoesEndpoint = '$baseUrl/api_avaliacoes.php/avaliacoes';
  static const String escolasEndpoint = '$baseUrl/api_escolas.php/escolas';
  static const String logsEndpoint = '$baseUrl/api_logs.php/logs';
  static const String mensalidadesEndpoint = '$baseUrl/api_mensalidades.php/mensalidades';
  static const String trackingEndpoint = '$baseUrl/api_tracking.php/tracking';

  // ── Upload de fotos ───────────────────────────────────────────────
  static const String uploadFotoUrl = '$baseUrl/upload_foto.php';

  // ── IBGE (estados e cidades) ──────────────────────────────────────
  static const String ibgeBaseUrl = 'https://servicodados.ibge.gov.br/api/v1/localidades';
  static const String ibgeEstadosUrl = '$ibgeBaseUrl/estados?orderBy=nome';
  static String ibgeCidadesUrl(String ufId) =>
      '$ibgeBaseUrl/estados/$ufId/municipios?orderBy=nome';

  // ── Headers padrão ────────────────────────────────────────────────
  static Map<String, String> get defaultHeaders => {
        'Content-Type': 'application/json',
        'X-Api-Key': apiKey,
      };

  // ── Timeouts ──────────────────────────────────────────────────────
  static const Duration requestTimeout = Duration(seconds: 15);
  static const Duration uploadTimeout = Duration(seconds: 30);
}