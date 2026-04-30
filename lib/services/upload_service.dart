import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../core/config/api_config.dart';

/// Serviço centralizado de upload de ficheiros.
/// Unifica upload de fotos de alunos e documentos de motoristas.
class UploadService {
  UploadService._();
  static final UploadService instance = UploadService._();

  /// Upload de foto de aluno.
  /// Retorna a URL da foto no servidor.
  Future<String> uploadFotoAluno({
    required Uint8List bytes,
    required String responsavelUid,
    String? filename,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConfig.uploadFotoUrl),
      );

      request.headers['X-Api-Key'] = ApiConfig.apiKey;
      request.fields['tipo'] = 'alunos';
      request.fields['uid'] = responsavelUid;

      request.files.add(http.MultipartFile.fromBytes(
        'foto',
        bytes,
        filename: filename ??
            '${responsavelUid}_${DateTime.now().millisecondsSinceEpoch}.jpg',
      ));

      final streamed = await request
          .send()
          .timeout(ApiConfig.uploadTimeout);
      final res = await http.Response.fromStream(streamed);

      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        return json['url'] as String? ?? '';
      }

      debugPrint('[UploadService] upload_foto status: ${res.statusCode} body: ${res.body}');
    } catch (e) {
      debugPrint('[UploadService] upload_foto erro: $e');
    }
    return '';
  }

  /// Upload de documento do motorista (CNH, CRLV, Vistoria).
  Future<String> uploadDocumentoMotorista({
    required Uint8List bytes,
    required String uid,
    required String tipoDoc, // 'cnh', 'crlv', 'vistoria'
    String? filename,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConfig.uploadFotoUrl),
      );

      request.headers['X-Api-Key'] = ApiConfig.apiKey;
      request.fields['tipo'] = 'motoristas';
      request.fields['uid'] = uid;
      request.fields['documento_tipo'] = tipoDoc;

      request.files.add(http.MultipartFile.fromBytes(
        'documento',
        bytes,
        filename: filename ??
            '${tipoDoc}_${uid}_${DateTime.now().millisecondsSinceEpoch}.jpg',
      ));

      final streamed = await request
          .send()
          .timeout(ApiConfig.uploadTimeout);
      final res = await http.Response.fromStream(streamed);

      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        return json['url'] as String? ?? '';
      }
    } catch (e) {
      debugPrint('[UploadService] upload_documento erro: $e');
    }
    return '';
  }

  /// Upload de foto de perfil do motorista.
  Future<String> uploadFotoPerfilMotorista({
    required Uint8List bytes,
    required String uid,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConfig.uploadFotoUrl),
      );

      request.headers['X-Api-Key'] = ApiConfig.apiKey;
      request.fields['tipo'] = 'motoristas/perfil';
      request.fields['uid'] = uid;

      request.files.add(http.MultipartFile.fromBytes(
        'foto',
        bytes,
        filename: 'perfil_${uid}_${DateTime.now().millisecondsSinceEpoch}.jpg',
      ));

      final streamed = await request
          .send()
          .timeout(ApiConfig.uploadTimeout);
      final res = await http.Response.fromStream(streamed);

      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        return json['url'] as String? ?? '';
      }
    } catch (e) {
      debugPrint('[UploadService] upload_foto_perfil erro: $e');
    }
    return '';
  }
}
