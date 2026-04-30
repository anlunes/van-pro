import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../repositories/motorista_repository.dart';
import '../../models/motorista_model.dart';
import '../../services/notification_service.dart';

/// Tela principal do motorista — TabBar com lista de chamada, perfil, financeiro.
class MotoristaHomeScreen extends StatefulWidget {
  final String uid;

  const MotoristaHomeScreen({super.key, required this.uid});

  @override
  State<MotoristaHomeScreen> createState() => _MotoristaHomeScreenState();
}

class _MotoristaHomeScreenState extends State<MotoristaHomeScreen> {
  Motorista? _motorista;
  bool _loading = true;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _carregarMotorista();
  }

  Future<void> _carregarMotorista() async {
    final m = await MotoristaRepository.instance.buscarPorUid(widget.uid);
    if (mounted) {
      setState(() {
        _motorista = m;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_motorista == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('Motorista não encontrado.'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  await AuthService.instance.logout();
                },
                child: const Text('Sair'),
              ),
            ],
          ),
        ),
      );
    }

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_motorista!.nome,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text('Van ${_motorista!.vanCode}',
                  style: const TextStyle(fontSize: 11, color: Colors.white70)),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => _confirmarLogout(context),
              tooltip: 'Sair',
            ),
          ],
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(icon: Icon(Icons.checklist), text: 'Chamada'),
              Tab(icon: Icon(Icons.person), text: 'Perfil'),
              Tab(icon: Icon(Icons.account_balance_wallet), text: 'Financeiro'),
              Tab(icon: Icon(Icons.settings), text: 'Operação'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildTabChamada(),
            _buildTabPerfil(),
            _buildTabFinanceiro(),
            _buildTabOperacao(),
          ],
        ),
      ),
    );
  }

  Widget _buildTabChamada() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.checklist, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text('Lista de Chamada'),
          const SizedBox(height: 8),
          const Text('Widget de chamada aqui',
              style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildTabPerfil() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.amber.shade200,
            backgroundImage: _motorista!.fotoUrl.isNotEmpty
                ? NetworkImage(_motorista!.fotoUrl) as ImageProvider
                : null,
            child: _motorista!.fotoUrl.isEmpty
                ? const Icon(Icons.person, size: 50)
                : null,
          ),
          const SizedBox(height: 16),
          Text(_motorista!.nome,
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold)),
          Text(_motorista!.email, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 8),
          Text('Van: ${_motorista!.vanCode}',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.star, color: Colors.amber.shade700),
              const SizedBox(width: 4),
              Text(_motorista!.avaliacaoFormatada),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _motorista!.docsVerificados
                      ? Colors.green
                      : Colors.orange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _motorista!.badgeStatus,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 11),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabFinanceiro() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.account_balance_wallet,
              size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Gestão de Pagamentos'),
          SizedBox(height: 8),
          Text('Widget financeiro aqui',
              style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildTabOperacao() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.settings, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Configurações de Operação'),
          SizedBox(height: 8),
          Text('Bairros, escolas, operacional aqui',
              style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  void _confirmarLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sair?'),
        content: const Text('Deseja realmente sair da sua conta?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCELAR')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await AuthService.instance.logout();
            },
            child: const Text('SAIR'),
          ),
        ],
      ),
    );
  }
}
