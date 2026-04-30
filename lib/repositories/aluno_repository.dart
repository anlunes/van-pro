import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/aluno_model.dart';
import '../services/aluno_api_service.dart';
import '../core/utils/logger.dart';

/// Repository de alunos.
/// Une dados do servidor MySQL (snake_case) com dados operacionais do Firestore (camelCase).
/// Este é o único lugar onde o merge acontece — eliminando a duplicação anterior.
class AlunoRepository {
  AlunoRepository._();
  static final AlunoRepository instance = AlunoRepository._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final AlunoApiService _api = AlunoApiService.instance;

  /// Busca alunos de uma van (motorista).
  /// Combina dados do servidor com status operacional do Firestore.
  Future<List<Aluno>> buscarPorVanCode(String vanCode) async {
    // 1. Busca dados completos do servidor
    final alunosServidor = await _api.buscarPorVanCode(vanCode);

    if (alunosServidor.isEmpty) return [];

    // 2. Para cada aluno, busca status operacional do Firestore
    final List<Aluno> resultado = [];

    for (final aluno in alunosServidor) {
      final firestoreData = await _buscarStatusFirestore(aluno);
      resultado.add(firestoreData);
    }

    return resultado;
  }

  /// Busca alunos de um responsável (pai).
  Future<List<Aluno>> buscarPorResponsavel(String responsavelUid) async {
    final alunosServidor = await _api.buscarPorResponsavel(responsavelUid);

    if (alunosServidor.isEmpty) return [];

    final List<Aluno> resultado = [];
    for (final aluno in alunosServidor) {
      final firestoreData = await _buscarStatusFirestore(aluno);
      resultado.add(firestoreData);
    }

    return resultado;
  }

  /// Salva aluno: servidor MySQL + atualiza Firestore.
  /// Retorna o ID do Firestore criado.
  Future<String> salvar({
    required Aluno aluno,
    required String responsavelUid,
    required String nomeResponsavel,
    required String vanCode,
    String? fotoUrl,
  }) async {
    // 1. Salva no servidor MySQL
    final servidorId = await _api.criar(aluno);

    // 2. Cria/atualiza documento no Firestore (só campos operacionais)
    final col = _db.collection('alunos');
    String firebaseDocId = '';

    final dadosFirestore = {
      'responsavelUid': responsavelUid,
      if (servidorId != null) 'servidorId': servidorId,
      'status': aluno.status,
      'vaiHoje': aluno.vaiHoje,
      'cienteMotorista': aluno.cienteMotorista,
      'createdAt': FieldValue.serverTimestamp(),
    };

    if (aluno.firebaseStatusId != null) {
      await col.doc(aluno.firebaseStatusId).update(dadosFirestore);
      firebaseDocId = aluno.firebaseStatusId!;
    } else {
      final docRef = await col.add(dadosFirestore);
      firebaseDocId = docRef.id;
      // Atualiza com o firebaseStatusId
      await docRef.update({'firebaseStatusId': firebaseDocId});
    }

    // 3. Registra log de criação
    await AppLogger.registrarEvento(
      alunoId: firebaseDocId,
      nomeAluno: aluno.nome,
      evento: 'ALUNO_CRIADO',
      vanCode: vanCode,
      origem: 'motorista',
    );

    return firebaseDocId;
  }

  /// Atualiza status de embarque no Firestore (tempo real).
  Future<void> atualizarStatusFirestore(String firebaseDocId, String status) async {
    try {
      await _db.collection('alunos').doc(firebaseDocId).update({
        'status': status,
        'timestampEmbarque': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      AppLogger.log('Erro ao atualizar status Firestore: $e', tag: 'AlunoRepo');
    }
  }

  /// Atualiza campo vaiHoje no Firestore.
  Future<void> atualizarVaiHoje(String firebaseDocId, bool vaiHoje) async {
    try {
      await _db.collection('alunos').doc(firebaseDocId).update({
        'vaiHoje': vaiHoje,
      });
    } catch (e) {
      AppLogger.log('Erro ao atualizar vaiHoje: $e', tag: 'AlunoRepo');
    }
  }

  /// Atualiza pagamento no servidor MySQL.
  Future<bool> atualizarPagamento(int servidorId, bool pago) async {
    return await _api.atualizarPagamento(servidorId, pago);
  }

  // ── Helpers privados ────────────────────────────────────────────────

  /// Busca status operacional do Firestore e faz merge com dados do servidor.
  Future<Aluno> _buscarStatusFirestore(Aluno aluno) async {
    try {
      // Busca pelo firebaseStatusId ou servidorId
      QuerySnapshot<Map<String, dynamic>> snapshot;

      if (aluno.firebaseStatusId != null) {
        snapshot = await _db
            .collection('alunos')
            .where('firebaseStatusId', isEqualTo: aluno.firebaseStatusId)
            .limit(1)
            .get();
      } else if (aluno.servidorId != null) {
        snapshot = await _db
            .collection('alunos')
            .where('servidorId', isEqualTo: aluno.servidorId)
            .limit(1)
            .get();
      } else {
        // Fallback: busca por responsavelUid + nome
        snapshot = await _db
            .collection('alunos')
            .where('responsavelUid', isEqualTo: aluno.responsavelUid)
            .limit(1)
            .get();
      }

      if (snapshot.docs.isEmpty) return aluno;

      final firestoreData = snapshot.docs.first.data();
      return _buildMergedMap(aluno, firestoreData);
    } catch (e) {
      AppLogger.log('Erro ao buscar Firestore: $e', tag: 'AlunoRepo');
      return aluno;
    }
  }

  /// Constrói o mapa mesclado: dados do servidor + dados operacionais do Firestore.
  /// Este método centraliza a lógica que antes estava duplicada em 2 lugares.
  Aluno _buildMergedMap(Aluno alunoServidor, Map<String, dynamic> firestoreData) {
    return alunoServidor.copyWith(
      firebaseStatusId: firestoreData['firebaseStatusId'] as String? ??
          alunoServidor.firebaseStatusId,
      servidorId: firestoreData['servidorId'] as int? ?? alunoServidor.servidorId,
      status: firestoreData['status'] as String? ?? alunoServidor.status,
      vaiHoje: firestoreData['vaiHoje'] != false,
      cienteMotorista: firestoreData['cienteMotorista'] == true,
    );
  }
}
