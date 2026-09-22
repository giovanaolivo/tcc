import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluttertcc/services/autenticacao_service.dart';

void main() {
  test('traduz erros comuns de autenticação', () {
    final service = AutenticacaoService();

    expect(
      service.mensagemDeErro(
        FirebaseAuthException(code: 'email-already-in-use'),
      ),
      'Este e-mail já possui uma conta.',
    );
    expect(
      service.mensagemDeErro(FirebaseAuthException(code: 'weak-password')),
      'Use uma senha com pelo menos 6 caracteres.',
    );
    expect(
      service.mensagemDeErro(FirebaseAuthException(code: 'invalid-credential')),
      'E-mail ou senha incorretos.',
    );
  });
}
