import 'package:firebase_auth/firebase_auth.dart';

class AutenticacaoService {
  AutenticacaoService([this._autenticacao]);

  final FirebaseAuth? _autenticacao;

  FirebaseAuth get _auth => _autenticacao ?? FirebaseAuth.instance;

  Stream<User?> observarUsuario() => _auth.authStateChanges();

  Future<void> entrar({required String email, required String senha}) async {
    await _auth.signInWithEmailAndPassword(email: email, password: senha);
  }

  Future<void> criarConta({
    required String email,
    required String senha,
  }) async {
    await _auth.createUserWithEmailAndPassword(email: email, password: senha);
  }

  Future<void> enviarRecuperacao(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> sair() => _auth.signOut();

  String mensagemDeErro(Object erro) {
    if (erro is! FirebaseAuthException) {
      return 'Não foi possível concluir a operação. Tente novamente.';
    }

    return switch (erro.code) {
      'invalid-email' => 'Digite um e-mail válido.',
      'invalid-credential' ||
      'user-not-found' ||
      'wrong-password' => 'E-mail ou senha incorretos.',
      'email-already-in-use' => 'Este e-mail já possui uma conta.',
      'weak-password' => 'Use uma senha com pelo menos 6 caracteres.',
      'too-many-requests' =>
        'Muitas tentativas. Aguarde um pouco e tente novamente.',
      'network-request-failed' => 'Verifique sua conexão com a internet.',
      _ => 'Não foi possível concluir a operação. Tente novamente.',
    };
  }
}
