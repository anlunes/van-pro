import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../core/config/api_config.dart';

/// Serviço de dados de escolas.
/// Usa Firestore para escolas homologadas + IBGE para estados/cidades.
class EscolaService {
  EscolaService._();
  static final EscolaService instance = EscolaService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Busca escolas homologadas de uma cidade (Firestore).
  Future<List<Map<String, dynamic>>> buscarEscolas(String cidade) async {
    try {
      final snapshot = await _db
          .collection('colegios')
          .where('cidade', isEqualTo: cidade)
          .where('status', isEqualTo: 'homologado')
          .limit(20)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          ...data,
          'id': doc.id,
        };
      }).toList();
    } catch (e) {
      debugPrint('[EscolaService] Erro ao buscar escolas: $e');
      return [];
    }
  }

  /// Busca escolas por nome (Firestore).
  Future<List<Map<String, dynamic>>> buscarPorNome(String nome, String cidade) async {
    try {
      final snapshot = await _db
          .collection('colegios')
          .where('cidade', isEqualTo: cidade)
          .where('status', isEqualTo: 'homologado')
          .limit(20)
          .get();

      return snapshot.docs
          .where((doc) {
            final nomeEscola = doc.data()['nome'] as String? ?? '';
            return nomeEscola.toLowerCase().contains(nome.toLowerCase());
          })
          .map((doc) => {...doc.data(), 'id': doc.id})
          .toList();
    } catch (e) {
      debugPrint('[EscolaService] Erro ao buscar por nome: $e');
      return [];
    }
  }

  /// Sugere nova escola (motorista/pai sugere, admin homologa).
  Future<void> sugerirEscola({
    required String nome,
    required String bairro,
    required String cidade,
    required String endereco,
    required String uid,
  }) async {
    try {
      await _db.collection('colegios').add({
        'nome': nome,
        'bairro': bairro,
        'cidade': cidade,
        'endereco': endereco,
        'status': 'pendente',
        'sugerido_por_uid': uid,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('[EscolaService] Erro ao sugerir escola: $e');
    }
  }

  /// Homologa uma escola (admin).
  Future<void> homologar(String docId) async {
    try {
      await _db.collection('colegios').doc(docId).update({
        'status': 'homologado',
      });
    } catch (e) {
      debugPrint('[EscolaService] Erro ao homologar: $e');
    }
  }

  /// Lista todos os estados do Brasil (IBGE).
  Future<List<Map<String, dynamic>>> buscarEstados() async {
    try {
      final res = await http
          .get(Uri.parse(ApiConfig.ibgeEstadosUrl))
          .timeout(ApiConfig.requestTimeout);

      if (res.statusCode == 200) {
        final List<dynamic> data = json.decode(res.body);
        return data.map((e) => {
          'id': e['id'],
          'nome': e['nome'],
          'sigla': e['sigla'],
        }).toList();
      }
    } catch (e) {
      debugPrint('[EscolaService] Erro ao buscar estados: $e');
    }
    return [];
  }

  /// Lista cidades de um estado (IBGE).
  Future<List<Map<String, dynamic>>> buscarCidades(String ufId) async {
    try {
      final res = await http
          .get(Uri.parse(ApiConfig.ibgeCidadesUrl(ufId)))
          .timeout(ApiConfig.requestTimeout);

      if (res.statusCode == 200) {
        final List<dynamic> data = json.decode(res.body);
        return data.map((e) => {
          'id': e['id'],
          'nome': e['nome'],
        }).toList();
      }
    } catch (e) {
      debugPrint('[EscolaService] Erro ao buscar cidades: $e');
    }
    return [];
  }
}
