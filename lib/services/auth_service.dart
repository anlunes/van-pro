import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/status_constants.dart';
import '../models/responsavel_model.dart';
import '../models/motorista_model.dart';
import 'responsavel_api_service.dart';
import 'motorista_api_service.dart';

/// Serviço de autenticação Firebase.
/// Fluxo de cadastro:
/// 1. Firebase Auth cria a conta (email/password)
/// 2. Servidor MySQL recebe os dados completos (responsavel ou motorista)
/// 3. Firestore recebe SOMENTE uid + role (enxuto)
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Getters ────────────────────────────────────────────────────────
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;
  String? get uid => _auth.currentUser?.uid;

  // ── Login ─────────────────────────────────────────────────────────
  /// Login com email + senha (Firebase Auth).
  Future<User> login(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (cred.user == null) throw Exception('Login falhou');
    return cred.user!;
  }

  // ── Cadastro: Responsável ──────────────────────────────────────────
  /// Cadastra novo responsável.
  /// 1. Cria conta no Firebase Auth
  /// 2. Salva dados completos no servidor MySQL
  /// 3. Salva SOMENTE uid+role no Firestore (enxuto)
  Future<User> signupResponsavel({
    required String email,
    required String password,
    required String nome,
    required String telefone,
  }) async {
    // 1. Firebase Auth
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = cred.user;
    if (user == null) throw Exception('Cadastro falhou');
    await user.updateDisplayName(nome);

    // 2. Servidor MySQL (dados completos)
    final responsavel = Responsavel(
      uid: user.uid,
      nome: nome,
      email: email,
      telefone: telefone,
    );
    await ResponsavelApiService.instance.criar(responsavel);

    // 3. Firestore (SOMENTE uid + role — enxuto)
    await _db.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'role': 'responsavel',
      'email': email,
      'nome': nome,
      'telefone': telefone,
      'createdAt': FieldValue.serverTimestamp(),
      'emailVerified': false,
    });

    // Envia email de verificação
    await user.sendEmailVerification();

    return user;
  }

  // ── Cadastro: Motorista ───────────────────────────────────────────
  /// Cadastra novo motorista.
  /// 1. Firebase Auth
  /// 2. Servidor MySQL (dados completos + vanCode)
  /// 3. Firestore (uid + role — enxuto)
  Future<User> signupMotorista({
    required String email,
    required String password,
    required String nome,
    required String telefone,
    required String vanCode,
    required String cpf,
  }) async {
    // 1. Firebase Auth
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = cred.user;
    if (user == null) throw Exception('Cadastro falhou');
    await user.updateDisplayName(nome);

    // 2. Servidor MySQL (dados completos)
    final motorista = Motorista(
      uid: user.uid,
      nome: nome,
      email: email,
      telefone: telefone,
      vanCode: vanCode,
      cpf: cpf, // Cifrado no servidor
      ativo: true,
    );
    await MotoristaApiService.instance.criar(motorista);

    // 3. Firestore (SOMENTE uid + role — enxuto)
    await _db.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'role': 'motorista',
      'email': email,
      'nome': nome,
      'telefone': telefone,
      'vanCode': vanCode,
      'createdAt': FieldValue.serverTimestamp(),
      'emailVerified': false,
    });

    // Envia email de verificação
    await user.sendEmailVerification();

    return user;
  }

  // ── Logout ────────────────────────────────────────────────────────
  Future<void> logout() async {
    await _auth.signOut();
  }

  // ── Role ─────────────────────────────────────────────────────────
  /// Busca o role do utilizador no Firestore (enxuto).
  Future<UserRole> getRole(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (!doc.exists) return UserRole.responsavel;
      final roleStr = doc.data()?['role'] as String?;
      return UserRole.fromString(roleStr);
    } catch (_) {
      return UserRole.responsavel;
    }
  }

  /// Atualiza dados do utilizador no Firestore (enxuto).
  Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).update(data);
  }

  /// Busca dados do utilizador no Firestore (enxuto).
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.data();
  }

  /// Verifica se o email está verificado.
  Future<bool> isEmailVerified() async {
    await _auth.currentUser?.reload();
    return _auth.currentUser?.emailVerified ?? false;
  }

  /// Reenvia email de verificação.
  Future<void> sendVerificationEmail() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Não logado');
    await user.sendEmailVerification();
  }
}
