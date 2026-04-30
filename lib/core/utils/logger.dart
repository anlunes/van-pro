import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

/// Logger unificado do VanPro.
/// - Em desenvolvimento: imprime no console.
/// - Em produção: envia para o servidor MySQL (tabela vanpro_logs).
/// - Web: mantém buffer em memória para download.
class AppLogger {
  AppLogger._();

  static final List<Map<String, dynamic>> _buffer = [];

  /// Log genérico (console)
  static void log(String mensagem, {String? tag}) {
    final prefixo = tag != null ? '[$tag]' : '[VanPro]';
    debugPrint('$prefixo $mensagem');
  }

  /// Registra evento de embarque/transporte no servidor.
  /// Não bloqueia a UI — fire-and-forget.
  static Future<void> registrarEvento({
    required String alunoId,
    required String nomeAluno,
    required String evento,
    int? motoristaId,
    String? vanCode,
    String origem = 'sistema',
  }) async {
    final dados = {
      'aluno_id': alunoId,
      'nome_aluno': nomeAluno,
      'evento': evento,
      'motorista_id': motoristaId,
      'vanCode': vanCode,
      'origem': origem,
    };

    // Adiciona ao buffer (para web ou auditoria)
    _buffer.add({...dados, 'timestamp': DateTime.now().toIso8601String()});

    // Envia ao servidor (non-blocking)
    try {
      await http
          .post(
            Uri.parse(ApiConfig.logsEndpoint),
            headers: ApiConfig.defaultHeaders,
            body: jsonEncode(dados),
          )
          .timeout(ApiConfig.requestTimeout);
    } catch (e) {
      debugPrint('[AppLogger] Erro ao enviar log: $e');
    }
  }

  /// Retorna todos os logs em buffer (útil no web para download).
  static List<Map<String, dynamic>> get bufferLogs =>
      List.unmodifiable(_buffer);

  /// Limpa o buffer de logs em memória.
  static void limparBuffer() => _buffer.clear();

  /// Exporta buffer como string CSV.
  static String exportarCsv() {
    final sb = StringBuffer();
    sb.writeln('timestamp;aluno_id;nome_aluno;evento;vanCode;origem');
    for (final log in _buffer) {
      sb.writeln(
        '${log['timestamp']};${log['aluno_id']};${log['nome_aluno']};'
        '${log['evento']};${log['vanCode'] ?? ''};${log['origem']}',
      );
    }
    return sb.toString();
  }
}
