import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Página admin: gestão de escolas pendentes.
class AdminEscolasPage extends StatelessWidget {
  const AdminEscolasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Escolas Pendentes"),
          backgroundColor: Colors.blue.shade700, foregroundColor: Colors.white),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('colegios')
            .where('status', isEqualTo: 'pendente')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          if (snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Nenhuma escola pendente"));
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;
              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.school)),
                title: Text(data['nome'] ?? ''),
                subtitle: Text('${data['bairro'] ?? ''} - ${data['cidade'] ?? ''}'),
                trailing: IconButton(
                  icon: const Icon(Icons.check_circle, color: Colors.green),
                  onPressed: () => _homologar(context, doc.id),
                ),
                onLongPress: () => _rejeitar(context, doc.id),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _homologar(BuildContext context, String docId) async {
    await FirebaseFirestore.instance.collection('colegios').doc(docId).update({'status': 'homologado'});
    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Escola homologada!"), backgroundColor: Colors.green));
  }

  Future<void> _rejeitar(BuildContext context, String docId) async {
    await FirebaseFirestore.instance.collection('colegios').doc(docId).delete();
    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Escola rejeitada"), backgroundColor: Colors.red));
  }
}