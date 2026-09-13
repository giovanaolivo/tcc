import 'package:flutter/material.dart';

class RegistroSintomasScreen extends StatefulWidget {
  const RegistroSintomasScreen({super.key});

  @override
  State<RegistroSintomasScreen> createState() => _RegistroSintomasScreenState();
}

class _RegistroSintomasScreenState extends State<RegistroSintomasScreen> {
  static const _azulPrincipal = Color(0xFF246FB5);
  static const _tiposDeSintoma = [
    'Dor abdominal',
    'Inchaço',
    'Diarreia',
    'Náusea',
    'Outro',
  ];

  final _formKey = GlobalKey<FormState>();
  final _outroSintomaController = TextEditingController();
  final _observacaoController = TextEditingController();

  String _tipoSelecionado = 'Dor abdominal';
  int _intensidade = 3;
  DateTime _dataHora = DateTime.now();

  @override
  void dispose() {
    _outroSintomaController.dispose();
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

  void _salvarRegistro() {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Registro preenchido com sucesso!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
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
          'SINTOMAS',
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
                      child: Icon(Icons.edit_outlined, color: _azulPrincipal),
                    ),
                  ),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Novo registro',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 28),
              const _TituloCampo('TIPO DE SINTOMA'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _tiposDeSintoma.map((tipo) {
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
                  controller: _outroSintomaController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Digite o sintoma',
                    hintText: 'Ex.: azia',
                  ),
                  validator: (valor) {
                    if (_tipoSelecionado == 'Outro' &&
                        (valor == null || valor.trim().isEmpty)) {
                      return 'Informe qual sintoma você sentiu';
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 24),
              const _TituloCampo('INTENSIDADE'),
              const SizedBox(height: 4),
              const Text(
                '1 representa leve e 5 representa muito intensa',
                style: TextStyle(color: Color(0xFF667085), fontSize: 13),
              ),
              const SizedBox(height: 10),
              Row(
                children: List.generate(5, (index) {
                  final valor = index + 1;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: valor == 5 ? 0 : 8),
                      child: ChoiceChip(
                        label: SizedBox(
                          width: double.infinity,
                          child: Text('$valor', textAlign: TextAlign.center),
                        ),
                        selected: _intensidade == valor,
                        showCheckmark: false,
                        selectedColor: const Color(0xFFDCEEFF),
                        side: BorderSide(
                          color: _intensidade == valor
                              ? _azulPrincipal
                              : const Color(0xFFD9E0E8),
                        ),
                        onSelected: (_) {
                          setState(() => _intensidade = valor);
                        },
                      ),
                    ),
                  );
                }),
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
                  onPressed: _salvarRegistro,
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text(
                    'Salvar registro',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
        selectedIndex: 1,
        onDestinationSelected: (index) {
          if (index == 1) return;
          if (index == 2) {
            Navigator.pushReplacementNamed(context, '/alimentacao');
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
            icon: Icon(Icons.edit_outlined),
            selectedIcon: Icon(Icons.edit),
            label: 'Registrar',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_outlined),
            selectedIcon: Icon(Icons.restaurant),
            label: 'Dieta',
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
