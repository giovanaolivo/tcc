import 'package:flutter/material.dart';

import '../services/alimentacao_service.dart';

class RegistroAlimentacaoScreen extends StatefulWidget {
  const RegistroAlimentacaoScreen({super.key});

  @override
  State<RegistroAlimentacaoScreen> createState() =>
      _RegistroAlimentacaoScreenState();
}

class _RegistroAlimentacaoScreenState extends State<RegistroAlimentacaoScreen> {
  static const _azulPrincipal = Color(0xFF246FB5);
  static const _tiposDeRefeicao = [
    'Café da manhã',
    'Almoço',
    'Lanche',
    'Jantar',
    'Ceia',
    'Outro',
  ];

  final _formKey = GlobalKey<FormState>();
  final _alimentacaoService = AlimentacaoService();
  final _outroTipoController = TextEditingController();
  final _alimentosController = TextEditingController();
  final _observacaoController = TextEditingController();

  String _tipoSelecionado = 'Café da manhã';
  DateTime _dataHora = DateTime.now();
  bool _salvando = false;

  @override
  void dispose() {
    _outroTipoController.dispose();
    _alimentosController.dispose();
    _observacaoController.dispose();
    super.dispose();
  }

  String _formatarDataHora(DateTime dataHora) {
    final dia = dataHora.day.toString().padLeft(2, '0');
    final mes = dataHora.month.toString().padLeft(2, '0');
    final hora = dataHora.hour.toString().padLeft(2, '0');
    final minuto = dataHora.minute.toString().padLeft(2, '0');
    return '$dia/$mes/${dataHora.year} às $hora:$minuto';
  }

  Future<void> _selecionarDataHora() async {
    final data = await showDatePicker(
      context: context,
      initialDate: _dataHora,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      helpText: 'Selecione a data',
    );

    if (data == null || !mounted) return;

    final horario = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dataHora),
      helpText: 'Selecione o horário',
    );

    if (horario == null) return;

    setState(() {
      _dataHora = DateTime(
        data.year,
        data.month,
        data.day,
        horario.hour,
        horario.minute,
      );
    });
  }

  List<String> _separarAlimentos(String texto) {
    return texto
        .split(',')
        .map((alimento) => alimento.trim())
        .where((alimento) => alimento.isNotEmpty)
        .toList();
  }

  Future<void> _salvarRegistro() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() => _salvando = true);

    try {
      final tipoRefeicao = _tipoSelecionado == 'Outro'
          ? _outroTipoController.text.trim()
          : _tipoSelecionado;

      await _alimentacaoService.adicionarRefeicao(
        tipoRefeicao: tipoRefeicao,
        alimentos: _separarAlimentos(_alimentosController.text),
        dataHora: _dataHora,
        observacao: _observacaoController.text.trim(),
      );

      if (!mounted) return;

      _formKey.currentState!.reset();
      _outroTipoController.clear();
      _alimentosController.clear();
      _observacaoController.clear();
      setState(() {
        _tipoSelecionado = 'Café da manhã';
        _dataHora = DateTime.now();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Refeição salva com sucesso!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (erro) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível salvar a refeição. Tente novamente.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _salvando = false);
      }
    }
  }

  void _mostrarModuloEmConstrucao(String modulo) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$modulo será desenvolvido nas próximas etapas.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFFE6F1FB),
        foregroundColor: _azulPrincipal,
        title: const Text(
          'ALIMENTAÇÃO',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            children: [
              const Row(
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: Color(0xFFE6F1FB),
                      shape: BoxShape.circle,
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Icon(
                        Icons.restaurant_outlined,
                        color: _azulPrincipal,
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Nova refeição',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              const _TituloCampo('TIPO DE REFEIÇÃO'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _tiposDeRefeicao.map((tipo) {
                  return ChoiceChip(
                    label: Text(tipo),
                    selected: _tipoSelecionado == tipo,
                    showCheckmark: false,
                    selectedColor: const Color(0xFFDCEEFF),
                    side: BorderSide(
                      color: _tipoSelecionado == tipo
                          ? _azulPrincipal
                          : const Color(0xFFD9E0E8),
                    ),
                    labelStyle: TextStyle(
                      color: _tipoSelecionado == tipo
                          ? _azulPrincipal
                          : const Color(0xFF475467),
                      fontWeight: _tipoSelecionado == tipo
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                    onSelected: (_) {
                      setState(() => _tipoSelecionado = tipo);
                    },
                  );
                }).toList(),
              ),
              if (_tipoSelecionado == 'Outro') ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _outroTipoController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Digite o tipo de refeição',
                    hintText: 'Ex.: lanche da madrugada',
                  ),
                  validator: (valor) {
                    if (_tipoSelecionado == 'Outro' &&
                        (valor == null || valor.trim().isEmpty)) {
                      return 'Informe o tipo de refeição';
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 24),
              const _TituloCampo('ALIMENTOS'),
              const SizedBox(height: 10),
              TextFormField(
                controller: _alimentosController,
                minLines: 2,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: 'Ex.: arroz, feijão e frango',
                  helperText: 'Separe os alimentos por vírgulas.',
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(bottom: 28),
                    child: Icon(Icons.lunch_dining_outlined),
                  ),
                ),
                validator: (valor) {
                  if (valor == null || _separarAlimentos(valor).isEmpty) {
                    return 'Informe pelo menos um alimento';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              const _TituloCampo('DATA E HORA'),
              const SizedBox(height: 10),
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: _selecionarDataHora,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.calendar_today_outlined),
                    suffixIcon: Icon(Icons.chevron_right),
                  ),
                  child: Text(
                    _formatarDataHora(_dataHora),
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const _TituloCampo('OBSERVAÇÃO (OPCIONAL)'),
              const SizedBox(height: 10),
              TextFormField(
                controller: _observacaoController,
                minLines: 3,
                maxLines: 5,
                maxLength: 300,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: 'Descreva alguma observação...',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 52,
                child: FilledButton.icon(
                  onPressed: _salvando ? null : _salvarRegistro,
                  icon: _salvando
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check_circle_outline),
                  label: Text(
                    _salvando ? 'Salvando...' : 'Salvar refeição',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: _azulPrincipal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 2,
        onDestinationSelected: (index) {
          if (index == 2) {
            Navigator.pushReplacementNamed(context, '/alimentacao');
            return;
          }
          if (index == 1) {
            Navigator.pushReplacementNamed(context, '/sintomas');
            return;
          }
          if (index == 3) {
            Navigator.pushReplacementNamed(context, '/historico');
            return;
          }
          const modulos = ['Início', 'Registrar', 'Dieta', 'Histórico'];
          _mostrarModuloEmConstrucao(modulos[index]);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Início',
          ),
          NavigationDestination(
            icon: Icon(Icons.health_and_safety_outlined),
            selectedIcon: Icon(Icons.health_and_safety),
            label: 'Sintomas',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_outlined),
            selectedIcon: Icon(Icons.restaurant),
            label: 'Alimentação',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights),
            label: 'Histórico',
          ),
        ],
      ),
    );
  }
}

class _TituloCampo extends StatelessWidget {
  const _TituloCampo(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Text(
      texto,
      style: const TextStyle(
        color: Color(0xFF344054),
        fontSize: 13,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.4,
      ),
    );
  }
}
