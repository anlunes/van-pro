import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/motorista_model.dart';
import '../services/motorista_api_service.dart';

/// Repository de motoristas.
///
/// Fluxo de leitura:
/// 1. Busca dados completos do servidor MySQL (snake_case)
/// 2. Sobrescreve/merge com dados operacionais do Firestore (camelCase)
/// 3. Retorna objeto Motorista completo
///
/// Fluxo de escrita:
/// - Dados pessoais → servidor MySQL
/// - Dados operacionais (status, avaliação, docs) → Firestore
class MotoristaRepository {
  MotoristaRepository._();
  static final MotoristaRepository instance = MotoristaRepository._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final MotoristaApiService _api = MotoristaApiService.instance;

  /// Busca dados COMPLETOS do motorista por UID.
  /// Merge: MySQL (completo) + Firestore (operacional).
  Future<Motorista?> buscarPorUid(String uid) async {
    try {
      // 1. Dados completos do servidor MySQL
      final servidorData = await _api.buscarPorUid(uid);

      // 2. Dados operacionais do Firestore
      final docFirestore = await _db.collection('users').doc(uid).get();

      if (!docFirestore.exists && servidorData == null) return null;

      // Constrói objeto base do MySQL (ou do Firestore como fallback)
      Motorista base = servidorData ?? Motorista.fromFirestoreMap(docFirestore.data()!);

      // 3. Merge com dados do Firestore (sobrescreve campos operacionais)
      if (docFirestore.exists) {
        final fsData = docFirestore.data()!;
        base = base.copyWith(
          fotoUrl: fsData['fotoUrl'] as String? ?? base.fotoUrl,
          avaliacaoMedia: (fsData['mediaAvaliacoes'] ?? fsData['avaliacaoMedia'] ?? base.avaliacaoMedia).toDouble(),
          totalAvaliacoes: fsData['totalAvaliacoes'] as int? ?? base.totalAvaliacoes,
          docsVerificados: fsData['documentosVerificados'] as bool? ?? base.docsVerificados,
          cnhUrl: fsData['cnhUrl'] as String? ?? base.cnhUrl,
          crlvUrl: fsData['crlvUrl'] as String? ?? base.crlvUrl,
          vistoriaUrl: fsData['vistoriaUrl'] as String? ?? base.vistoriaUrl,
          isOnline: fsData['isOnline'] as bool? ?? false,
          bairrosTags: fsData['bairros_tags'] != null
              ? List<String>.from(fsData['bairros_tags'])
              : base.bairrosTags,
          escolasTags: fsData['escolas_tags'] != null
              ? List<String>.from(fsData['escolas_tags'])
              : base.escolasTags,
        );
      }

      return base;
    } catch (e) {
      debugPrint('[MotoristaRepository] Erro ao buscar: $e');
      return null;
    }
  }

  /// Busca motorista por vanCode (Firestore).
  Future<Motorista?> buscarPorVanCode(String vanCode) async {
    try {
      final snapshot = await _db
          .collection('users')
          .where('vanCode', isEqualTo: vanCode)
          .where('role', isEqualTo: 'motorista')
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;
      final m = Motorista.fromFirestoreMap(snapshot.docs.first.data());
      return buscarPorUid(m.uid); // Puxa dados completos do MySQL
    } catch (e) {
      debugPrint('[MotoristaRepository] Erro ao buscar por vanCode: $e');
      return null;
    }
  }

  /// Atualiza dados pessoais no servidor MySQL.
  Future<bool> atualizarServidor(int id, Motorista motorista) async {
    return await _api.atualizar(id, motorista);
  }

  /// Atualiza dados operacionais no Firestore (enxuto).
  Future<void> atualizarFirestore(String uid, Map<String, dynamic> data) async {
    try {
      await _db.collection('users').doc(uid).update(data);
    } catch (e) {
      debugPrint('[MotoristaRepository] Erro ao atualizar Firestore: $e');
    }
  }

  /// Atualiza URL de documento (CNH, CRLV, Vistoria) — Firestore.
  Future<void> atualizarDocumento(String uid, String tipo, String url) async {
    try {
      await _db.collection('users').doc(uid).update({'${tipo}Url': url});
    } catch (e) {
      debugPrint('[MotoristaRepository] Erro ao atualizar documento: $e');
    }
  }

  /// Atualiza avaliação média — Firestore.
  Future<void> atualizarAvaliacao(String uid, double media, int total) async {
    try {
      await _db.collection('users').doc(uid).update({
        'mediaAvaliacoes': media,
        'totalAvaliacoes': total,
      });
    } catch (e) {
      debugPrint('[MotoristaRepository] Erro ao atualizar avaliação: $e');
    }
  }

  /// Lista todos os motoristas (admin) — MySQL.
  Future<List<Motorista>> listarTodos() async {
    try {
      final snapshot = await _db
          .collection('users')
          .where('role', isEqualTo: 'motorista')
          .get();

      final List<Motorista> lista = [];
      for (final doc in snapshot.docs) {
        final m = await buscarPorUid(doc.data()['uid'] as String);
        if (m != null) lista.add(m);
      }
      return lista;
    } catch (e) {
      debugPrint('[MotoristaRepository] Erro ao listar: $e');
      return [];
    }
  }

  /// Homologa documentos do motorista (admin) — MySQL + Firestore.
  Future<void> homologarDocumentos(String uid) async {
    try {
      // Firestore
      await _db.collection('users').doc(uid).update({
        'documentosVerificados': true,
        'dataVerificacao': DateTime.now().toIso8601String().split('T')[0],
      });
    } catch (e) {
      debugPrint('[MotoristaRepository] Erro ao homologar: $e');
    }
  }
}
