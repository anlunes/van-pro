import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../repositories/aluno_repository.dart';
import '../../models/aluno_model.dart';

/// Tela principal do responsável (pai/mãe).
class ResponsavelHomeScreen extends StatefulWidget {
  final String uid;

  const ResponsavelHomeScreen({super.key, required this.uid});

  @override
  State<ResponsavelHomeScreen> createState() => _ResponsavelHomeScreenState();
}

class _ResponsavelHomeScreenState extends State<ResponsavelHomeScreen> {
  List<Aluno> _alunos = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _carregarAlunos();
  }

  Future<void> _carregarAlunos() async {
    setState(() => _loading = true);
    try {
      final alunos = await AlunoRepository.instance.buscarPorResponsavel(widget.uid);
      if (mounted) setState(() { _alunos = alunos; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VanPro - Meus Filhos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _confirmarLogout(context),
            tooltip: 'Sair',
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _adicionarFilho,
        backgroundColor: Colors.amber.shade700,
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _carregarAlunos,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    if (_alunos.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.child_care, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 24),
            const Text('Nenhum filho cadastrado',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Toque em + para adicionar'),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _adicionarFilho,
              icon: const Icon(Icons.person_add),
              label: const Text('CADASTRAR FILHO'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _carregarAlunos,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _alunos.length,
        itemBuilder: (context, index) {
          final aluno = _alunos[index];
          return _buildAlunoCard(aluno);
        },
      ),
    );
  }

  Widget _buildAlunoCard(Aluno aluno) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: Colors.amber.shade200,
          backgroundImage: aluno.fotoUrl.isNotEmpty
              ? NetworkImage(aluno.fotoUrl) as ImageProvider
              : null,
          child: aluno.fotoUrl.isEmpty
              ? const Icon(Icons.person, size: 28)
              : null,
        ),
        title: Text(aluno.nome,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(aluno.nomeEscola.isNotEmpty
                ? aluno.nomeEscola
                : 'Escola não informada'),
            Row(
              children: [
                Icon(Icons.circle,
                    size: 10,
                    color: _getCorStatus(aluno.status)),
                const SizedBox(width: 4),
                Text(aluno.status,
                    style: TextStyle(
                        fontSize: 11, color: _getCorStatus(aluno.status))),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: aluno.pago ? Colors.green.shade50 : Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    aluno.pago ? 'Pago' : 'Pendente',
                    style: TextStyle(
                      fontSize: 10,
                      color: aluno.pago ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _abrirDetalhesAluno(aluno),
      ),
    );
  }

  Color _getCorStatus(String status) {
    switch (status) {
      case 'Embarcou ida':
      case 'Embarcou volta':
        return Colors.green;
      case 'Chegou na Escola':
      case 'Chegou em Casa':
        return Colors.blue;
      case 'Não vai hoje':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _adicionarFilho() {
    // TODO: Abrir dialog de cadastro de filho
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funcionalidade em construção')),
    );
  }

  void _abrirDetalhesAluno(Aluno aluno) {
    // TODO: Abrir tela de detalhes do filho
  }

  void _confirmarLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sair?'),
        content: const Text('Deseja realmente sair?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('CANCELAR')),
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
