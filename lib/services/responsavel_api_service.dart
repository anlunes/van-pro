import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../core/config/api_config.dart';
import '../models/responsavel_model.dart';

/// Serviço de acesso à API de responsáveis (servidor PHP/MySQL).
/// CRUD completo de responsáveis no banco de dados do servidor.
class ResponsavelApiService {
  ResponsavelApiService._();
  static final ResponsavelApiService instance = ResponsavelApiService._();

  /// Busca um responsável pelo UID do Firebase.
  Future<Responsavel?> buscarPorUid(String uid) async {
    try {
      final res = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api_responsaveis.php?uid=$uid'),
        headers: ApiConfig.defaultHeaders,
      ).timeout(ApiConfig.requestTimeout);

      if (res.statusCode == 200) {
        final List<dynamic> data = json.decode(res.body);
        if (data.isEmpty) return null;
        return Responsavel.fromServerMap(data.first as Map<String, dynamic>);
      }
    } catch (e) {
      debugPrint('[ResponsavelApiService] Erro ao buscar por uid: $e');
    }
    return null;
  }

  /// Cria um novo responsável no servidor MySQL.
  Future<int?> criar(Responsavel responsavel) async {
    try {
      final res = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api_responsaveis.php'),
        headers: ApiConfig.defaultHeaders,
        body: jsonEncode(responsavel.toServerMap()),
      ).timeout(ApiConfig.requestTimeout);

      if (res.statusCode == 201) {
        final data = json.decode(res.body);
        return data['servidorid'] as int? ?? data['id'] as int?;
      }

      debugPrint('[ResponsavelApiService] criar status: ${res.statusCode} body: ${res.body}');
    } catch (e) {
      debugPrint('[ResponsavelApiService] Erro ao criar: $e');
    }
    return null;
  }

  /// Atualiza dados de um responsável.
  Future<bool> atualizar(int id, Responsavel responsavel) async {
    try {
      final res = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/api_responsaveis.php/$id'),
        headers: ApiConfig.defaultHeaders,
        body: jsonEncode(responsavel.toServerMap()),
      ).timeout(ApiConfig.requestTimeout);

      return res.statusCode == 200;
    } catch (e) {
      debugPrint('[ResponsavelApiService] Erro ao atualizar: $e');
      return false;
    }
  }

  /// Verifica se um responsável existe pelo uid.
  Future<bool> existePorUid(String uid) async {
    final r = await buscarPorUid(uid);
    return r != null;
  }
}
