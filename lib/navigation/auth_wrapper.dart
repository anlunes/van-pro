import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../core/constants/status_constants.dart';
import '../screens/auth/auth_screen.dart';
import '../screens/motorista/motorista_home_screen.dart';
import '../screens/responsavel/responsavel_home_screen.dart';
import '../screens/admin/admin_dashboard.dart';

/// Wrapper de autenticação — decide a tela inicial com base no estado do utilizador.
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // A carregar — mostra splash
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.directions_bus, size: 72, color: Colors.amber),
                  SizedBox(height: 16),
                  Text('VanPro',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  CircularProgressIndicator(),
                ],
              ),
            ),
          );
        }

        final user = snapshot.data;

        // Não logado → tela de login/cadastro
        if (user == null) {
          return const AuthScreen();
        }

        // Logado → buscar role no Firestore (enxuto)
        return FutureBuilder<String?>(
          future: _obterRole(user.uid),
          builder: (context, roleSnapshot) {
            if (!roleSnapshot.hasData || roleSnapshot.data == null) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            switch (roleSnapshot.data) {
              case 'admin':
                return const AdminDashboard();
              case 'motorista':
                return MotoristaHomeScreen(uid: user.uid);
              case 'responsavel':
              default:
                return ResponsavelHomeScreen(uid: user.uid);
            }
          },
        );
      },
    );
  }

  /// Busca o role do utilizador no Firestore (enxuto).
  Future<String?> _obterRole(String uid) async {
    try {
      final role = await AuthService.instance.getRole(uid);
      return role.value;
    } catch (_) {
      return 'responsavel';
    }
  }
}
