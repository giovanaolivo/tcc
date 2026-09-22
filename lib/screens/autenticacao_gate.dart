import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/autenticacao_service.dart';
import 'inicio_screen.dart';
import 'login_screen.dart';

class AutenticacaoGate extends StatefulWidget {
  const AutenticacaoGate({super.key});

  @override
  State<AutenticacaoGate> createState() => _AutenticacaoGateState();
}

class _AutenticacaoGateState extends State<AutenticacaoGate> {
  final _autenticacaoService = AutenticacaoService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _autenticacaoService.observarUsuario(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final usuario = snapshot.data;
        if (usuario == null || usuario.isAnonymous) {
          return LoginScreen(autenticacaoService: _autenticacaoService);
        }

        return const InicioScreen();
      },
    );
  }
}
