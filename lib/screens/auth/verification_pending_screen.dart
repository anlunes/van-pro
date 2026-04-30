import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

/// Tela de espera de verificação de e-mail.
class VerificationPendingScreen extends StatefulWidget {
  final String? email;

  const VerificationPendingScreen({super.key, this.email});

  @override
  State<VerificationPendingScreen> createState() =>
      _VerificationPendingScreenState();
}

class _VerificationPendingScreenState extends State<VerificationPendingScreen> {
  bool _loading = false;
  String? _message;

  Future<void> _checkVerification() async {
    setState(() {
      _loading = true;
      _message = null;
    });

    try {
      await AuthService.instance.currentUser?.reload();
      final verified = await AuthService.instance.isEmailVerified();

      if (verified) {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/');
        }
      } else {
        setState(() =>
            _message = 'Ainda não verificado. Verifique sua caixa de entrada.');
      }
    } catch (e) {
      setState(() => _message = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resendEmail() async {
    setState(() => _loading = true);
    try {
      await AuthService.instance.sendVerificationEmail();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('E-mail reenviado!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verificação de E-mail')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.mark_email_unread,
                  size: 80, color: Colors.amber.shade700),
              const SizedBox(height: 24),
              Text(
                'Verifique seu e-mail',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              if (widget.email != null) ...[
                const SizedBox(height: 8),
                Text(widget.email!,
                    style: const TextStyle(color: Colors.grey)),
              ],
              const SizedBox(height: 16),
              const Text(
                'Enviamos um link de verificação. Clique no link do e-mail para ativar sua conta.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              if (_message != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(_message!),
                ),
                const SizedBox(height: 16),
              ],
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _checkVerification,
                  child: _loading
                      ? const CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2)
                      : const Text('JÁ VERIFIQUEI'),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _loading ? null : _resendEmail,
                child: const Text('Reenviar e-mail'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
