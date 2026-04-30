import 'package:flutter/material.dart';

/// Página admin: inteligência de dados (placeholder).
class AdminInteligenciaPage extends StatelessWidget {
  const AdminInteligenciaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Inteligência de Dados"),
          backgroundColor: Colors.teal.shade700, foregroundColor: Colors.white),
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.insights, size: 80, color: Colors.teal),
            SizedBox(height: 16),
            Text("Painel de Inteligência", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text("Análise de dados em construção", style: TextStyle(color: Colors.grey)),
            SizedBox(height: 8),
            Text("Métricas, gráficos e insights", style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}