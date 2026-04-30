import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/utils/logger.dart';

/// Serviço de tracking GPS em tempo real.
/// Usa Firestore para posição ao vivo + MySQL para histórico.
class TrackingService {
  TrackingService._();
  static final TrackingService instance = TrackingService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  Timer? _gpsTimer;

  /// Inicia o tracking GPS do motorista.
  /// Atualiza Firestore a cada 30 segundos enquanto há alunos embarcados.
  void iniciarTracking(String uid, String vanCode) {
    _gpsTimer?.cancel();
    _gpsTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _enviarPosicao(uid, vanCode);
    });
  }

  /// Para o tracking GPS.
  void pararTracking() {
    _gpsTimer?.cancel();
    _gpsTimer = null;
  }

  /// Envia posição atual (placeholder — usar geolocator no app real).
  Future<void> _enviarPosicao(String uid, String vanCode) async {
    // TODO: Integrar com geolocator para pegar lat/lng real
    // Por agora, não faz nada — placeholder
  }

  /// Salva posição no Firestore (tempo real).
  Future<void> salvarPosicaoFirestore({
    required String vanCode,
    required double latitude,
    required double longitude,
    required List<String> alunosEmbarcados,
  }) async {
    try {
      await _db.collection('motorista_localizacao').doc(vanCode).set({
        'uid': FirebaseAuth.instance.currentUser?.uid,
        'latitude': latitude,
        'longitude': longitude,
        'timestamp': FieldValue.serverTimestamp(),
        'alunosEmbarcados': alunosEmbarcados,
      }, SetOptions(merge: true));
    } catch (e) {
      AppLogger.log('Erro ao salvar posição Firestore: $e', tag: 'Tracking');
    }
  }

  /// Remove posição do Firestore (quando última criança chega).
  Future<void> removerPosicaoFirestore(String vanCode) async {
    try {
      await _db.collection('motorista_localizacao').doc(vanCode).delete();
    } catch (e) {
      AppLogger.log('Erro ao remover posição Firestore: $e', tag: 'Tracking');
    }
  }

  /// Stream da posição ao vivo de uma van (para o app dos pais).
  Stream<DocumentSnapshot> getPosicaoVan(String vanCode) {
    return _db.collection('motorista_localizacao').doc(vanCode).snapshots();
  }

  /// Salva ponto GPS no histórico MySQL (para replay do trajeto).
  Future<void> salvarHistoricoGps({
    required int motoristaId,
    required String vanCode,
    required double latitude,
    required double longitude,
    double? velocidadeMs,
    double? precisaoGps,
  }) async {
    await AppLogger.registrarEvento(
      alunoId: 'GPS_TRACKING',
      nomeAluno: vanCode,
      evento: 'POSICAO_GPS',
      motoristaId: motoristaId,
      vanCode: vanCode,
      origem: 'motorista',
    );
    // TODO: POST para /api/tracking no servidor MySQL
  }
}
