import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../core/config/api_config.dart';
import '../models/motorista_model.dart';

/// Serviço de acesso à API de motoristas (servidor PHP/MySQL).
class MotoristaApiService {
  MotoristaApiService._();
  static final MotoristaApiService instance = MotoristaApiService._();

  /// Busca um motorista pelo UID do Firebase.
  Future<Motorista?> buscarPorUid(String uid) async {
    try {
      final res = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api_motoristas.php?uid=$uid'),
        headers: ApiConfig.defaultHeaders,
      ).timeout(ApiConfig.requestTimeout);

      if (res.statusCode == 200) {
        final List<dynamic> data = json.decode(res.body);
        if (data.isEmpty) return null;
        return Motorista.fromServerMap(data.first as Map<String, dynamic>);
      }
    } catch (e) {
      debugPrint('[MotoristaApiService] Erro ao buscar por uid: $e');
    }
    return null;
  }

  /// Cria um novo motorista no servidor MySQL.
  Future<int?> criar(Motorista motorista) async {
    try {
      final res = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api_motoristas.php'),
        headers: ApiConfig.defaultHeaders,
        body: jsonEncode(motorista.toServerMap()),
      ).timeout(ApiConfig.requestTimeout);

      if (res.statusCode == 201) {
        final data = json.decode(res.body);
        return data['servidorid'] as int? ?? data['id'] as int?;
      }

      debugPrint('[MotoristaApiService] criar status: ${res.statusCode} body: ${res.body}');
    } catch (e) {
      debugPrint('[MotoristaApiService] Erro ao criar: $e');
    }
    return null;
  }

  /// Atualiza dados de um motorista.
  Future<bool> atualizar(int id, Motorista motorista) async {
    try {
      final res = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/api_motoristas.php/$id'),
        headers: ApiConfig.defaultHeaders,
        body: jsonEncode(motorista.toServerMap()),
      ).timeout(ApiConfig.requestTimeout);

      return res.statusCode == 200;
    } catch (e) {
      debugPrint('[MotoristaApiService] Erro ao atualizar: $e');
      return false;
    }
  }

  /// Verifica se um motorista existe pelo uid.
  Future<bool> existePorUid(String uid) async {
    final m = await buscarPorUid(uid);
    return m != null;
  }
}
