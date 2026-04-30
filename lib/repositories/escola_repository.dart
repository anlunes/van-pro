import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../services/escola_service.dart';

/// Repository de escolas.
/// Camada de acesso a dados de escolas (Firestore + IBGE).
class EscolaRepository {
  EscolaRepository._();
  static final EscolaRepository instance = EscolaRepository._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final EscolaService _service = EscolaService.instance;

  /// Busca escolas de uma cidade.
  Future<List<Map<String, dynamic>>> buscarPorCidade(String cidade) async {
    return await _service.buscarEscolas(cidade);
  }

  /// Busca escolas por nome.
  Future<List<Map<String, dynamic>>> buscarPorNome(
    String nome,
    String cidade,
  ) async {
    return await _service.buscarPorNome(nome, cidade);
  }

  /// Sugere nova escola.
  Future<void> sugerir({
    required String nome,
    required String bairro,
    required String cidade,
    required String endereco,
    required String uid,
  }) async {
    await _service.sugerirEscola(
      nome: nome,
      bairro: bairro,
      cidade: cidade,
      endereco: endereco,
      uid: uid,
    );
  }

  /// Homologa escola (admin).
  Future<void> homologar(String docId) async {
    await _service.homologar(docId);
  }

  /// Lista escolas pendentes (admin).
  Future<List<Map<String, dynamic>>> listarPendentes() async {
    try {
      final snapshot = await _db
          .collection('colegios')
          .where('status', isEqualTo: 'pendente')
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {...data, 'id': doc.id};
      }).toList();
    } catch (e) {
      debugPrint('[EscolaRepository] Erro ao listar pendentes: $e');
      return [];
    }
  }

  /// Lista escolas homologadas (admin).
  Future<List<Map<String, dynamic>>> listarHomologadas() async {
    try {
      final snapshot = await _db
          .collection('colegios')
          .where('status', isEqualTo: 'homologado')
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {...data, 'id': doc.id};
      }).toList();
    } catch (e) {
      debugPrint('[EscolaRepository] Erro ao listar homologadas: $e');
      return [];
    }
  }

  /// Deleta escola.
  Future<void> deletar(String docId) async {
    try {
      await _db.collection('colegios').doc(docId).delete();
    } catch (e) {
      debugPrint('[EscolaRepository] Erro ao deletar: $e');
    }
  }

  /// Atualiza dados de escola.
  Future<void> atualizar(
    String docId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _db.collection('colegios').doc(docId).update(data);
    } catch (e) {
      debugPrint('[EscolaRepository] Erro ao atualizar: $e');
    }
  }

  /// Busca estados do Brasil (IBGE).
  Future<List<Map<String, dynamic>>> buscarEstados() async {
    return await _service.buscarEstados();
  }

  /// Busca cidades de um estado (IBGE).
  Future<List<Map<String, dynamic>>> buscarCidades(String ufId) async {
    return await _service.buscarCidades(ufId);
  }
}
