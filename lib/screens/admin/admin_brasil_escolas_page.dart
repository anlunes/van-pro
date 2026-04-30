import 'package:flutter/material.dart';

/// Página admin: gestão de escolas do Brasil (IBGE + Firestore).
class AdminBrasilEscolasPage extends StatelessWidget {
  const AdminBrasilEscolasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Escolas do Brasil - IBGE"),
          backgroundColor: Colors.orange.shade700, foregroundColor: Colors.white),
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.public, size: 80, color: Colors.orange),
            SizedBox(height: 16),
            Text("Escolas por Cidade", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text("Selecione UF e cidade para ver escolas", style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}