import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../core/config/api_config.dart';
import '../models/aluno_model.dart';

/// Serviço de acesso à API de alunos (servidor PHP/MySQL).
/// CRUD completo de alunos no banco de dados do servidor.
class AlunoApiService {
  AlunoApiService._();
  static final AlunoApiService instance = AlunoApiService._();

  /// Busca todos os alunos de uma van.
  Future<List<Aluno>> buscarPorVanCode(String vanCode) async {
    try {
      final res = await http.get(
        Uri.parse('${ApiConfig.alunosEndpoint}?vanCode=$vanCode'),
        headers: ApiConfig.defaultHeaders,
      ).timeout(ApiConfig.requestTimeout);

      if (res.statusCode == 200) {
        final List<dynamic> data = json.decode(res.body);
        return data.map((e) => Aluno.fromServerMap(e as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      debugPrint('[AlunoApiService] Erro ao buscar por vanCode: $e');
    }
    return [];
  }

  /// Busca alunos de um responsável.
  Future<List<Aluno>> buscarPorResponsavel(String responsavelUid) async {
    try {
      final res = await http.get(
        Uri.parse('${ApiConfig.alunosEndpoint}?responsavel_uid=$responsavelUid'),
        headers: ApiConfig.defaultHeaders,
      ).timeout(ApiConfig.requestTimeout);

      if (res.statusCode == 200) {
        final List<dynamic> data = json.decode(res.body);
        return data.map((e) => Aluno.fromServerMap(e as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      debugPrint('[AlunoApiService] Erro ao buscar por responsavel: $e');
    }
    return [];
  }

  /// Busca um aluno específico por ID.
  Future<Aluno?> buscarPorId(int id) async {
    try {
      final res = await http.get(
        Uri.parse('${ApiConfig.alunosEndpoint}/$id'),
        headers: ApiConfig.defaultHeaders,
      ).timeout(ApiConfig.requestTimeout);

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        return Aluno.fromServerMap(data as Map<String, dynamic>);
      }
    } catch (e) {
      debugPrint('[AlunoApiService] Erro ao buscar por id: $e');
    }
    return null;
  }

  /// Cria um novo aluno.
  Future<int?> criar(Aluno aluno) async {
    try {
      final res = await http.post(
        Uri.parse(ApiConfig.alunosEndpoint),
        headers: ApiConfig.defaultHeaders,
        body: jsonEncode(aluno.toServerMap()),
      ).timeout(ApiConfig.requestTimeout);

      if (res.statusCode == 201) {
        final data = json.decode(res.body);
        return data['servidorid'] as int?;
      }
    } catch (e) {
      debugPrint('[AlunoApiService] Erro ao criar: $e');
    }
    return null;
  }

  /// Atualiza um aluno existente.
  Future<bool> atualizar(int id, Aluno aluno) async {
    try {
      final res = await http.put(
        Uri.parse('${ApiConfig.alunosEndpoint}/$id'),
        headers: ApiConfig.defaultHeaders,
        body: jsonEncode(aluno.toServerMap()),
      ).timeout(ApiConfig.requestTimeout);

      return res.statusCode == 200;
    } catch (e) {
      debugPrint('[AlunoApiService] Erro ao atualizar: $e');
      return false;
    }
  }

  /// Deleta um aluno.
  Future<bool> deletar(int id) async {
    try {
      final res = await http.delete(
        Uri.parse('${ApiConfig.alunosEndpoint}/$id'),
        headers: ApiConfig.defaultHeaders,
      ).timeout(ApiConfig.requestTimeout);

      return res.statusCode == 200;
    } catch (e) {
      debugPrint('[AlunoApiService] Erro ao deletar: $e');
      return false;
    }
  }

  /// Atualiza status de pagamento.
  Future<bool> atualizarPagamento(int id, bool pago) async {
    try {
      final res = await http.patch(
        Uri.parse('${ApiConfig.alunosEndpoint}/$id'),
        headers: ApiConfig.defaultHeaders,
        body: jsonEncode({'pago': pago ? 1 : 0}),
      ).timeout(ApiConfig.requestTimeout);

      return res.statusCode == 200;
    } catch (e) {
      debugPrint('[AlunoApiService] Erro ao atualizar pagamento: $e');
      return false;
    }
  }
}
