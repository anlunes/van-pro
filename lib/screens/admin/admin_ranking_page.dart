import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Página admin: ranking de motoristas por avaliação.
class AdminRankingPage extends StatelessWidget {
  const AdminRankingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ranking de Motoristas"),
          backgroundColor: Colors.amber.shade700, foregroundColor: Colors.white),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'motorista')
            .orderBy('mediaAvaliacoes', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          if (snapshot.data!.docs.isEmpty) return const Center(child: Text("Nenhum motorista"));

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final media = (data['mediaAvaliacoes'] ?? 0.0).toDouble();
              final total = data['totalAvaliacoes'] as int? ?? 0;
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: index == 0 ? Colors.amber : Colors.grey.shade300,
                  child: Text('${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
                title: Text(data['nome'] ?? ''),
                subtitle: Text('Van ${data['vanCode'] ?? ''} - $total avaliações'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, color: Colors.amber.shade700, size: 20),
                    const SizedBox(width: 4),
                    Text(media.toStringAsFixed(1),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}