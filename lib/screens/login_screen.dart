import 'package:flutter/material.dart';

import '../services/autenticacao_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.autenticacaoService});

  final AutenticacaoService? autenticacaoService;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const _azulPrincipal = Color(0xFF246FB5);

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmacaoController = TextEditingController();

  late final AutenticacaoService _autenticacaoService;
  bool _criandoConta = false;
  bool _ocultarSenha = true;
  bool _carregando = false;

  @override
  void initState() {
    super.initState();
    _autenticacaoService = widget.autenticacaoService ?? AutenticacaoService();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    _confirmacaoController.dispose();
    super.dispose();
  }

  String? _validarEmail(String? valor) {
    final email = valor?.trim() ?? '';
    if (email.isEmpty) return 'Informe seu e-mail';
    if (!email.contains('@') || !email.contains('.')) {
      return 'Digite um e-mail válido';
    }
    return null;
  }

  String? _validarSenha(String? valor) {
    if (valor == null || valor.isEmpty) return 'Informe sua senha';
    if (valor.length < 6) return 'A senha deve ter pelo menos 6 caracteres';
    return null;
  }

  Future<void> _enviar() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _carregando = true);

    try {
      if (_criandoConta) {
        await _autenticacaoService.criarConta(
          email: _emailController.text.trim(),
          senha: _senhaController.text,
        );
      } else {
        await _autenticacaoService.entrar(
          email: _emailController.text.trim(),
          senha: _senhaController.text,
        );
      }
    } catch (erro) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_autenticacaoService.mensagemDeErro(erro)),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  Future<void> _recuperarSenha() async {
    final email = _emailController.text.trim();
    if (_validarEmail(email) != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Digite seu e-mail antes de recuperar a senha.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _carregando = true);
    try {
      await _autenticacaoService.enviarRecuperacao(email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Enviamos as instruções de recuperação para seu e-mail.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (erro) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_autenticacaoService.mensagemDeErro(erro)),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  void _alternarModo() {
    setState(() {
      _criandoConta = !_criandoConta;
      _senhaController.clear();
      _confirmacaoController.clear();
      _ocultarSenha = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const CircleAvatar(
                      radius: 38,
                      backgroundColor: Color(0xFFE6F1FB),
                      foregroundColor: _azulPrincipal,
                      child: Icon(Icons.health_and_safety_outlined, size: 38),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Saúde Intestinal',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _criandoConta
                          ? 'Crie sua conta para começar seus registros.'
                          : 'Entre para acessar seus registros.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF667085),
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'E-mail',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: _validarEmail,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _senhaController,
                      obscureText: _ocultarSenha,
                      autofillHints: _criandoConta
                          ? const [AutofillHints.newPassword]
                          : const [AutofillHints.password],
                      textInputAction: _criandoConta
                          ? TextInputAction.next
                          : TextInputAction.done,
                      onFieldSubmitted: (_) {
                        if (!_criandoConta && !_carregando) _enviar();
                      },
                      decoration: InputDecoration(
                        labelText: 'Senha',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() => _ocultarSenha = !_ocultarSenha);
                          },
                          icon: Icon(
                            _ocultarSenha
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          tooltip: _ocultarSenha
                              ? 'Mostrar senha'
                              : 'Ocultar senha',
                        ),
                      ),
                      validator: _validarSenha,
                    ),
                    if (_criandoConta) ...[
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _confirmacaoController,
                        obscureText: _ocultarSenha,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) {
                          if (!_carregando) _enviar();
                        },
                        decoration: const InputDecoration(
                          labelText: 'Confirmar senha',
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                        validator: (valor) {
                          if (valor != _senhaController.text) {
                            return 'As senhas não são iguais';
                          }
                          return null;
                        },
                      ),
                    ],
                    if (!_criandoConta)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _carregando ? null : _recuperarSenha,
                          child: const Text('Esqueci minha senha'),
                        ),
                      )
                    else
                      const SizedBox(height: 24),
                    SizedBox(
                      height: 52,
                      child: FilledButton(
                        onPressed: _carregando ? null : _enviar,
                        style: FilledButton.styleFrom(
                          backgroundColor: _azulPrincipal,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _carregando
                            ? const SizedBox.square(
                                dimension: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                _criandoConta ? 'Criar conta' : 'Entrar',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _carregando ? null : _alternarModo,
                      child: Text(
                        _criandoConta
                            ? 'Já tenho uma conta'
                            : 'Ainda não tenho uma conta',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
