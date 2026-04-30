import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/responsavel_model.dart';
import '../services/responsavel_api_service.dart';

/// Repository de responsáveis.
///
/// Fluxo de leitura:
/// 1. Busca dados do servidor MySQL (completo)
/// 2. Puxa dados operacionais do Firestore
/// 3. Retorna Responsavel completo
class ResponsavelRepository {
  ResponsavelRepository._();
  static final ResponsavelRepository instance = ResponsavelRepository._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final ResponsavelApiService _api = ResponsavelApiService.instance;

  /// Busca responsável completo por UID (MySQL + Firestore merge).
  Future<Responsavel?> buscarPorUid(String uid) async {
    try {
      // 1. MySQL (dados completos)
      final servidorData = await _api.buscarPorUid(uid);
      if (servidorData != null) return servidorData;

      // 2. Fallback: Firestore
      final doc = await _db.collection('users').doc(uid).get();
      if (!doc.exists) return null;

      final data = doc.data()!;
      return Responsavel(
        uid: uid,
        nome: data['nome'] as String? ?? '',
        email: data['email'] as String? ?? '',
        telefone: data['telefone'] as String? ?? '',
      );
    } catch (e) {
      debugPrint('[ResponsavelRepository] Erro ao buscar: $e');
      return null;
    }
  }

  /// Atualiza dados no servidor MySQL.
  Future<bool> atualizar(int id, Responsavel responsavel) async {
    return await _api.atualizar(id, responsavel);
  }

  /// Atualiza dados no Firestore (enxuto).
  Future<void> atualizarFirestore(String uid, Map<String, dynamic> data) async {
    try {
      await _db.collection('users').doc(uid).update(data);
    } catch (e) {
      debugPrint('[ResponsavelRepository] Erro ao atualizar Firestore: $e');
    }
  }
}
