import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../core/constants/status_constants.dart';

/// Tela de autenticação: Login + Cadastro.
/// Fluxo de cadastro:
/// - Responsável: nome, email, telefone → Firebase Auth + Servidor MySQL + Firestore (enxuto)
/// - Motorista: nome, email, telefone, vanCode, CPF → Firebase Auth + Servidor MySQL + Firestore (enxuto)
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;
  bool _loading = false;
  String? _error;
  String? _successMessage;

  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _nomeCtrl = TextEditingController();
  final _telefoneCtrl = TextEditingController();
  final _vanCodeCtrl = TextEditingController();
  final _cpfCtrl = TextEditingController();

  UserRole _role = UserRole.responsavel;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _nomeCtrl.dispose();
    _telefoneCtrl.dispose();
    _vanCodeCtrl.dispose();
    _cpfCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
      _successMessage = null;
    });

    try {
      if (_isLogin) {
        // Login — Firebase Auth
        await AuthService.instance.login(
          _emailCtrl.text.trim(),
          _passCtrl.text,
        );
      } else {
        // Cadastro
        if (_role == UserRole.responsavel) {
          await AuthService.instance.signupResponsavel(
            email: _emailCtrl.text.trim(),
            password: _passCtrl.text,
            nome: _nomeCtrl.text.trim(),
            telefone: _telefoneCtrl.text.trim(),
          );
        } else {
          await AuthService.instance.signupMotorista(
            email: _emailCtrl.text.trim(),
            password: _passCtrl.text,
            nome: _nomeCtrl.text.trim(),
            telefone: _telefoneCtrl.text.trim(),
            vanCode: _vanCodeCtrl.text.trim().toUpperCase(),
            cpf: _cpfCtrl.text.trim(),
          );
        }

        if (mounted) {
          setState(() {
            _successMessage = 'Conta criada! Verifique seu e-mail para ativar.';
            _isLogin = true;
          });
        }
        return;
      }
    } on Exception catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 40),
                  Icon(Icons.directions_bus,
                      size: 80, color: Colors.amber.shade700),
                  const SizedBox(height: 12),
                  const Text('VanPro',
                      style: TextStyle(
                          fontSize: 28, fontWeight: FontWeight.bold)),
                  const Text('Transporte Escolar Inteligente',
                      style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 40),

                  // Toggle login/cadastro
                  SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(value: true, label: Text('Entrar')),
                      ButtonSegment(value: false, label: Text('Cadastrar')),
                    ],
                    selected: {_isLogin},
                    onSelectionChanged: (s) =>
                        setState(() => _isLogin = s.first),
                  ),
                  const SizedBox(height: 24),

                  // Mensagem de sucesso
                  if (_successMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle,
                              color: Colors.green, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(_successMessage!,
                                style: const TextStyle(
                                    color: Colors.green, fontSize: 13)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Formulário
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Campos de cadastro
                        if (!_isLogin) ...[
                          TextFormField(
                            controller: _nomeCtrl,
                            decoration: const InputDecoration(
                                labelText: 'Nome completo',
                                prefixIcon: Icon(Icons.person)),
                            validator: (v) =>
                                v == null || v.trim().isEmpty ? 'Obrigatório' : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _telefoneCtrl,
                            decoration: const InputDecoration(
                                labelText: 'Telefone / WhatsApp',
                                prefixIcon: Icon(Icons.phone)),
                            keyboardType: TextInputType.phone,
                            validator: (v) =>
                                v == null || v.trim().isEmpty ? 'Obrigatório' : null,
                          ),
                          const SizedBox(height: 12),

                          // Tipo de utilizador
                          DropdownButtonFormField<UserRole>(
                            value: _role,
                            decoration: const InputDecoration(
                              labelText: 'Você é...',
                              prefixIcon: Icon(Icons.badge),
                            ),
                            items: const [
                              DropdownMenuItem(
                                  value: UserRole.responsavel,
                                  child: Text('Responsável (pai/mãe)')),
                              DropdownMenuItem(
                                  value: UserRole.motorista,
                                  child: Text('Motorista')),
                            ],
                            onChanged: (v) =>
                                setState(() => _role = v ?? UserRole.responsavel),
                          ),

                          // Campos extras do motorista
                          if (_role == UserRole.motorista) ...[
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _vanCodeCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Código da Van',
                                prefixIcon: Icon(Icons.directions_bus),
                                helperText: 'Ex: ABC1234',
                              ),
                              textCapitalization: TextCapitalization.characters,
                              validator: (v) => v == null || v.trim().isEmpty
                                  ? 'Obrigatório'
                                  : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _cpfCtrl,
                              decoration: const InputDecoration(
                                labelText: 'CPF (motorista)',
                                prefixIcon: Icon(Icons.badge),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (v) {
                                if (_role != UserRole.motorista) return null;
                                if (v == null || v.trim().isEmpty) return 'Obrigatório';
                                if (v.replaceAll(RegExp(r'\D'), '').length != 11)
                                  return 'CPF inválido';
                                return null;
                              },
                            ),
                          ],

                          const SizedBox(height: 12),
                        ],

                        // Email
                        TextFormField(
                          controller: _emailCtrl,
                          decoration: const InputDecoration(
                              labelText: 'E-mail',
                              prefixIcon: Icon(Icons.email)),
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) =>
                              v == null || v.trim().isEmpty ? 'Obrigatório' : null,
                        ),
                        const SizedBox(height: 12),

                        // Senha
                        TextFormField(
                          controller: _passCtrl,
                          decoration: const InputDecoration(
                              labelText: 'Senha',
                              prefixIcon: Icon(Icons.lock)),
                          obscureText: true,
                          validator: (v) => v == null || v.length < 6
                              ? 'Mínimo 6 caracteres'
                              : null,
                        ),

                        // Erro
                        if (_error != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline,
                                    color: Colors.red, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(_error!,
                                      style:
                                          const TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),

                        // Botão
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isLogin
                                  ? Colors.amber.shade700
                                  : Colors.green.shade700,
                            ),
                            onPressed: _loading ? null : _submit,
                            child: _loading
                                ? const CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2)
                                : Text(
                                    _isLogin
                                        ? 'ENTRAR'
                                        : 'CADASTRAR E ENVIAR E-MAIL',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
