import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:async/async.dart';
import 'admin_escolas_page.dart';
import 'admin_documentos_page.dart';
import 'admin_ranking_page.dart';
import 'admin_inteligencia_page.dart';
import 'admin_brasil_escolas_page.dart';

/// Painel administrativo do VanPro.
class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Central VanPro - Administrativo"),
        backgroundColor: Colors.blueGrey.shade800,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () => _confirmarSaida(context),
            tooltip: "Sair",
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            _buildQuickStats(),
            _buildMenuGrid(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 25),
        decoration: BoxDecoration(color: Colors.blueGrey.shade800),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("PAINEL DE COMANDO",
                style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text("Gestão de Elite VanPro",
                style: TextStyle(
                    color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          ],
        ),
      );

  Widget _buildQuickStats() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      color: Colors.blueGrey.shade800,
      child: StreamBuilder<List<QuerySnapshot>>(
        stream: _streamStats(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Text("Erro ao carregar", style: TextStyle(color: Colors.white));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Colors.white));

          final totalVans = snapshot.data![0].docs.length;
          final totalAlunos = snapshot.data![1].docs.length;

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statItem("VANS ATIVAS", totalVans.toString(), Icons.directions_bus),
              _statItem("ALUNOS TOTAIS", totalAlunos.toString(), Icons.person),
            ],
          );
        },
      ),
    );
  }

  Stream<List<QuerySnapshot>> _streamStats() {
    return StreamZip([
      FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'motorista').snapshots(),
      FirebaseFirestore.instance.collection('alunos').snapshots(),
    ]);
  }

  Widget _statItem(String label, String valor, IconData icone) => Column(
        children: [
          Icon(icone, color: Colors.amber, size: 28),
          const SizedBox(height: 8),
          Text(valor,
              style: const TextStyle(
                  color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      );

  Widget _buildMenuGrid(BuildContext context) {
    final menus = [
      _MenuItem("Novas Escolas", Icons.school, Colors.blue, () =>
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminEscolasPage()))),
      _MenuItem("Documentos", Icons.verified_user, Colors.green, () =>
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminDocumentosPage()))),
      _MenuItem("Ranking", Icons.star, Colors.amber, () =>
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminRankingPage()))),
      _MenuItem("Inteligência", Icons.insights, Colors.teal, () =>
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminInteligenciaPage()))),
      _MenuItem("Brasil Escolas", Icons.public, Colors.orange, () =>
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminBrasilEscolasPage()))),
      _MenuItem("Financeiro", Icons.account_balance_wallet, Colors.deepPurple, null),
      _MenuItem("Anúncios", Icons.ads_click, Colors.redAccent, null),
    ];

    return Padding(
      padding: const EdgeInsets.all(15),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.1,
        ),
        itemCount: menus.length,
        itemBuilder: (context, index) {
          final m = menus[index];
          return InkWell(
            onTap: m.onTap,
            child: Container(
              decoration: BoxDecoration(
                color: m.onTap != null ? Colors.white : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 5,
                      offset: const Offset(0, 2))
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(m.icone,
                      size: 32,
                      color: m.onTap != null ? m.cor : Colors.grey),
                  const SizedBox(height: 8),
                  Text(m.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          color: m.onTap != null ? Colors.black87 : Colors.grey)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _confirmarSaida(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Row(
            children: [Icon(Icons.exit_to_app, color: Colors.redAccent), SizedBox(width: 10), Text("Encerrar Sessão?")]),
        content: const Text("Deseja realmente sair da Central Administrativa VanPro?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("CANCELAR")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) Navigator.pop(ctx);
            },
            child: const Text("SAIR", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _MenuItem {
  final String title;
  final IconData icone;
  final Color cor;
  final VoidCallback? onTap;

  _MenuItem(this.title, this.icone, this.cor, this.onTap);
}
