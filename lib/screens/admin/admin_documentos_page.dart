import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Página admin: verificação de documentos de motoristas.
class AdminDocumentosPage extends StatelessWidget {
  const AdminDocumentosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Documentos Pendentes"),
          backgroundColor: Colors.green.shade700, foregroundColor: Colors.white),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'motorista')
            .where('documentosVerificados', isEqualTo: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          if (snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Todos os documentos verificados! ✅"));
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.badge)),
                  title: Text(data['nome'] ?? ''),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Van: ${data['vanCode'] ?? ''}"),
                      Row(children: [
                        _docStatus("CNH", data['cnhUrl'] as String?),
                        _docStatus("CRLV", data['crlvUrl'] as String?),
                        _docStatus("Vistoria", data['vistoriaUrl'] as String?),
                      ]),
                    ],
                  ),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    onPressed: () => _homologar(context, doc.id),
                    child: const Text("VERIFICAR", style: TextStyle(color: Colors.white)),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _docStatus(String label, String? url) {
    final ok = url != null && url.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(label, style: const TextStyle(fontSize: 10)),
        backgroundColor: ok ? Colors.green.shade100 : Colors.red.shade100,
      ),
    );
  }

  Future<void> _homologar(BuildContext context, String docId) async {
    await FirebaseFirestore.instance.collection('users').doc(docId).update({
      'documentosVerificados': true,
      'dataVerificacao': DateTime.now().toIso8601String().split('T')[0],
    });
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Documentos verificados!"), backgroundColor: Colors.green),
      );
    }
  }
}