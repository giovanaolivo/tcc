import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import '../services/habitos_service.dart';
import '../widgets/navegacao_principal.dart';

class RegistroHabitosScreen extends StatefulWidget {
  const RegistroHabitosScreen({super.key});

  @override
  State<RegistroHabitosScreen> createState() =>
      _RegistroHabitosScreenState();
}

class _RegistroHabitosScreenState extends State<RegistroHabitosScreen> {
  static const _azulPrincipal = Color(0xFF246FB5);

  final _habitosService = HabitosService();
  final _observacaoController = TextEditingController();

  DateTime _dataHora = DateTime.now();
  bool _evacuou = false;
  int _consistenciaBristol = 3;
  double _horasSono = 7;
  String _qualidadeSono = 'Regular';
  bool _atividadeFisica = false;
  int _duracaoAtividadeMinutos = 30;
  int _nivelEstresse = 3;
  bool _salvando = false;

  @override
  void dispose() {
    _observacaoController.dispose();
    super.dispose();
  }

  String _formatarData(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    return '$dia/$mes/${data.year}';
  }

  String _formatarHoras(double horas) {
    return horas == horas.roundToDouble()
        ? '${horas.toInt()} h'
        : '${horas.toStringAsFixed(1).replaceAll('.', ',')} h';
  }

  Future<void> _selecionarData() async {
    final data = await showDatePicker(
      context: context,
      initialDate: _dataHora,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      helpText: 'Selecione o dia do registro',
    );
    if (data == null) return;

    setState(() {
      _dataHora = DateTime(
        data.year,
        data.month,
        data.day,
        _dataHora.hour,
        _dataHora.minute,
      );
    });
  }

  Future<void> _salvar() async {
    FocusScope.of(context).unfocus();
    setState(() => _salvando = true);

    try {
      await _habitosService.salvarHabitosDoDia(
        dataHora: _dataHora,
        evacuou: _evacuou,
        consistenciaBristol: _evacuou ? _consistenciaBristol : null,
        horasSono: _horasSono,
        qualidadeSono: _qualidadeSono,
        atividadeFisica: _atividadeFisica,
        duracaoAtividadeMinutos: _duracaoAtividadeMinutos,
        nivelEstresse: _nivelEstresse,
        observacao: _observacaoController.text.trim(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hábitos do dia salvos com sucesso!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (erro) {
      if (!mounted) return;
      final mensagem = erro is FirebaseException &&
              erro.code == 'permission-denied'
          ? 'O Firebase bloqueou o acesso. Publique a regra de registros_habitos.'
          : 'Não foi possível salvar os hábitos. Tente novamente.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensagem),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFFE6F1FB),
        foregroundColor: _azulPrincipal,
        title: const Text(
          'HÁBITOS',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
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
                    child: Icon(Icons.favorite_outline, color: _azulPrincipal),
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  'Registro de hábitos',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 28),
            const _TituloCampo('DATA DO REGISTRO'),
            const SizedBox(height: 10),
            InkWell(
              onTap: _selecionarData,
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.calendar_today_outlined),
                  suffixIcon: Icon(Icons.chevron_right),
                ),
                child: Text(
                  _formatarData(_dataHora),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const _TituloCampo('EVACUAÇÃO'),
            const SizedBox(height: 10),
            _EscolhaBinaria(
              valor: _evacuou,
              aoAlterar: (valor) => setState(() => _evacuou = valor),
            ),
            if (_evacuou) ...[
              const SizedBox(height: 20),
              const _TituloCampo('CONSISTÊNCIA (ESCALA DE BRISTOL)'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(7, (index) {
                  final valor = index + 1;
                  return ChoiceChip(
                    label: Text('$valor'),
                    selected: _consistenciaBristol == valor,
                    showCheckmark: false,
                    selectedColor: const Color(0xFFDCEEFF),
                    side: BorderSide(
                      color: _consistenciaBristol == valor
                          ? _azulPrincipal
                          : const Color(0xFFD9E0E8),
                    ),
                    onSelected: (_) {
                      setState(() => _consistenciaBristol = valor);
                    },
                  );
                }),
              ),
            ],
            const SizedBox(height: 28),
            const Divider(),
            const SizedBox(height: 20),
            const _TituloCampo('SONO'),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.bedtime_outlined, color: _azulPrincipal),
                const SizedBox(width: 8),
                const Expanded(child: Text('Horas dormidas')),
                Text(
                  _formatarHoras(_horasSono),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            Slider(
              value: _horasSono,
              min: 0,
              max: 12,
              divisions: 24,
              label: _formatarHoras(_horasSono),
              onChanged: (valor) => setState(() => _horasSono = valor),
            ),
            const SizedBox(height: 8),
            const Text('Qualidade do sono'),
            const SizedBox(height: 10),
            Row(
              children: ['Ruim', 'Regular', 'Boa'].map((qualidade) {
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: qualidade == 'Boa' ? 0 : 8,
                    ),
                    child: ChoiceChip(
                      label: SizedBox(
                        width: double.infinity,
                        child: Text(qualidade, textAlign: TextAlign.center),
                      ),
                      selected: _qualidadeSono == qualidade,
                      showCheckmark: false,
                      selectedColor: const Color(0xFFDCEEFF),
                      onSelected: (_) {
                        setState(() => _qualidadeSono = qualidade);
                      },
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 28),
            const Divider(),
            const SizedBox(height: 20),
            const _TituloCampo('ATIVIDADE FÍSICA'),
            const SizedBox(height: 10),
            _EscolhaBinaria(
              valor: _atividadeFisica,
              aoAlterar: (valor) {
                setState(() => _atividadeFisica = valor);
              },
            ),
            if (_atividadeFisica) ...[
              const SizedBox(height: 18),
              Row(
                children: [
                  const Icon(Icons.timer_outlined, color: _azulPrincipal),
                  const SizedBox(width: 8),
                  const Expanded(child: Text('Duração')),
                  Text(
                    '$_duracaoAtividadeMinutos min',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              Slider(
                value: _duracaoAtividadeMinutos.toDouble(),
                min: 10,
                max: 180,
                divisions: 17,
                label: '$_duracaoAtividadeMinutos min',
                onChanged: (valor) {
                  setState(() => _duracaoAtividadeMinutos = valor.round());
                },
              ),
            ],
            const SizedBox(height: 28),
            const Divider(),
            const SizedBox(height: 20),
            const _TituloCampo('NÍVEL DE ESTRESSE'),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Como você se sentiu hoje?'),
                Text(
                  '$_nivelEstresse/5',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            Slider(
              value: _nivelEstresse.toDouble(),
              min: 1,
              max: 5,
              divisions: 4,
              label: '$_nivelEstresse',
              onChanged: (valor) {
                setState(() => _nivelEstresse = valor.round());
              },
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [Text('calmo'), Text('muito estressado')],
              ),
            ),
            const SizedBox(height: 24),
            const _TituloCampo('OBSERVAÇÃO (OPCIONAL)'),
            const SizedBox(height: 10),
            TextField(
              controller: _observacaoController,
              minLines: 3,
              maxLines: 5,
              maxLength: 300,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'Algo que queira registrar sobre o dia...',
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 52,
              child: FilledButton.icon(
                onPressed: _salvando ? null : _salvar,
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
                  _salvando ? 'Salvando...' : 'Salvar hábitos do dia',
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
      bottomNavigationBar: const NavegacaoPrincipal(indiceAtual: 0),
    );
  }
}

class _EscolhaBinaria extends StatelessWidget {
  const _EscolhaBinaria({required this.valor, required this.aoAlterar});

  final bool valor;
  final ValueChanged<bool> aoAlterar;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final opcao in [true, false])
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: opcao ? 8 : 0),
              child: ChoiceChip(
                label: SizedBox(
                  width: double.infinity,
                  child: Text(
                    opcao ? 'Sim' : 'Não',
                    textAlign: TextAlign.center,
                  ),
                ),
                selected: valor == opcao,
                showCheckmark: false,
                selectedColor: const Color(0xFFDCEEFF),
                onSelected: (_) => aoAlterar(opcao),
              ),
            ),
          ),
      ],
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
