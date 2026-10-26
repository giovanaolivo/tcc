import 'package:flutter/material.dart';

import '../models/registro_alimentacao.dart';
import '../models/registro_habito.dart';
import '../models/registro_sintoma.dart';
import '../services/alimentacao_service.dart';
import '../services/habitos_service.dart';
import '../services/sintomas_service.dart';
import '../widgets/navegacao_principal.dart';

class HistoricoScreen extends StatefulWidget {
  const HistoricoScreen({super.key});

  @override
  State<HistoricoScreen> createState() => _HistoricoScreenState();
}

class _HistoricoScreenState extends State<HistoricoScreen> {
  static const _azulPrincipal = Color(0xFF246FB5);
  static const _filtros = ['Todos', 'Sintomas', 'Alimentação', 'Hábitos'];

  final _sintomasService = SintomasService();
  final _alimentacaoService = AlimentacaoService();
  final _habitosService = HabitosService();
  late final Stream<List<RegistroSintoma>> _sintomas;
  late final Stream<List<RegistroAlimentacao>> _refeicoes;
  late final Stream<List<RegistroHabito>> _habitos;
  String _filtroSelecionado = 'Todos';

  @override
  void initState() {
    super.initState();
    _sintomas = _sintomasService.observarSintomas();
    _refeicoes = _alimentacaoService.observarRefeicoes();
    _habitos = _habitosService.observarHabitos();
  }

  String _formatarDataHora(DateTime dataHora) {
    final dia = dataHora.day.toString().padLeft(2, '0');
    final mes = dataHora.month.toString().padLeft(2, '0');
    final hora = dataHora.hour.toString().padLeft(2, '0');
    final minuto = dataHora.minute.toString().padLeft(2, '0');
    return '$dia/$mes/${dataHora.year} às $hora:$minuto';
  }

  List<_ItemHistorico> _unirRegistros(
    List<RegistroSintoma> sintomas,
    List<RegistroAlimentacao> refeicoes,
    List<RegistroHabito> habitos,
  ) {
    final itens = <_ItemHistorico>[
      ...sintomas.map(
        (registro) => _ItemHistorico(
          dataHora: registro.dataHora,
          icon: Icons.health_and_safety_outlined,
          cor: const Color(0xFFDC3545),
          categoria: 'Sintoma',
          titulo: registro.nomeExibido,
          descricao: registro.observacao.isEmpty
              ? 'Intensidade ${registro.intensidade}/5'
              : 'Intensidade ${registro.intensidade}/5 • ${registro.observacao}',
        ),
      ),
      ...refeicoes.map(
        (registro) => _ItemHistorico(
          dataHora: registro.dataHora,
          icon: Icons.restaurant_outlined,
          cor: const Color(0xFF246FB5),
          categoria: 'Alimentação',
          titulo: registro.tipoRefeicao,
          descricao: registro.observacao.isEmpty
              ? registro.alimentos.join(', ')
              : '${registro.alimentos.join(', ')} • ${registro.observacao}',
        ),
      ),
      ...habitos.map(
        (registro) => _ItemHistorico(
          dataHora: registro.dataHora,
          icon: Icons.favorite_outline,
          cor: const Color(0xFF2E8B57),
          categoria: 'Hábitos',
          titulo: 'Hábitos do dia',
          descricao: _descricaoHabito(registro),
        ),
      ),
    ];

    itens.sort((a, b) => b.dataHora.compareTo(a.dataHora));
    return itens;
  }

  Widget _montarHistorico(
    List<RegistroSintoma> sintomas,
    List<RegistroAlimentacao> refeicoes,
    List<RegistroHabito> habitos,
  ) {
    final todosOsItens = _unirRegistros(sintomas, refeicoes, habitos);
    final itens = _filtroSelecionado == 'Todos'
        ? todosOsItens
        : todosOsItens
              .where(
                (item) =>
                    item.categoria == _filtroSelecionado ||
                    (_filtroSelecionado == 'Sintomas' &&
                        item.categoria == 'Sintoma'),
              )
              .toList();
    if (itens.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.history, size: 54, color: Color(0xFF98A2B3)),
              const SizedBox(height: 14),
              Text(
                _filtroSelecionado == 'Todos'
                    ? 'Nenhum registro no histórico'
                    : 'Nenhum registro de ${_filtroSelecionado.toLowerCase()}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Os sintomas, as refeições e os hábitos aparecerão juntos aqui.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF667085)),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
      itemCount: itens.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = itens[index];
        return Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
            side: const BorderSide(color: Color(0xFFE1E7EF)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: item.cor.withValues(alpha: 0.12),
                  foregroundColor: item.cor,
                  child: Icon(item.icon),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.categoria.toUpperCase(),
                        style: TextStyle(
                          color: item.cor,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.titulo,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _formatarDataHora(item.dataHora),
                        style: const TextStyle(
                          color: Color(0xFF667085),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        item.descricao,
                        style: const TextStyle(color: Color(0xFF475467)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _descricaoHabito(RegistroHabito registro) {
    final horas = registro.horasSono == registro.horasSono.roundToDouble()
        ? registro.horasSono.toInt().toString()
        : registro.horasSono.toStringAsFixed(1).replaceAll('.', ',');
    final partes = <String>[
      'Sono: $horas h (${registro.qualidadeSono.toLowerCase()})',
      'estresse ${registro.nivelEstresse}/5',
      registro.evacuou
          ? 'evacuação Bristol ${registro.consistenciaBristol ?? '-'}'
          : 'sem evacuação',
    ];

    if (registro.atividadeFisica) {
      partes.add('atividade ${registro.duracaoAtividadeMinutos} min');
    }
    if (registro.observacao.isNotEmpty) {
      partes.add(registro.observacao);
    }
    return partes.join(' • ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFFE6F1FB),
        foregroundColor: _azulPrincipal,
        title: const Text(
          'HISTÓRICO',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      body: StreamBuilder<List<RegistroSintoma>>(
        stream: _sintomas,
        builder: (context, sintomasSnapshot) {
          return StreamBuilder<List<RegistroAlimentacao>>(
            stream: _refeicoes,
            builder: (context, refeicoesSnapshot) {
              return StreamBuilder<List<RegistroHabito>>(
                stream: _habitos,
                builder: (context, habitosSnapshot) {
                  if (sintomasSnapshot.hasError ||
                      refeicoesSnapshot.hasError ||
                      habitosSnapshot.hasError) {
                    return const Center(
                      child: Text('Não foi possível carregar o histórico.'),
                    );
                  }
                  if (!sintomasSnapshot.hasData ||
                      !refeicoesSnapshot.hasData ||
                      (!habitosSnapshot.hasData && !habitosSnapshot.hasError)) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return Column(
                    children: [
                      SizedBox(
                        height: 58,
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(18, 10, 18, 6),
                          scrollDirection: Axis.horizontal,
                          itemCount: _filtros.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final filtro = _filtros[index];
                            return FilterChip(
                              label: Text(filtro),
                              selected: _filtroSelecionado == filtro,
                              onSelected: (_) {
                                setState(() => _filtroSelecionado = filtro);
                              },
                            );
                          },
                        ),
                      ),
                      Expanded(
                        child: _montarHistorico(
                          sintomasSnapshot.data!,
                          refeicoesSnapshot.data!,
                          habitosSnapshot.data ?? const <RegistroHabito>[],
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
      bottomNavigationBar: const NavegacaoPrincipal(indiceAtual: 3),
    );
  }
}

class _ItemHistorico {
  const _ItemHistorico({
    required this.dataHora,
    required this.icon,
    required this.cor,
    required this.categoria,
    required this.titulo,
    required this.descricao,
  });

  final DateTime dataHora;
  final IconData icon;
  final Color cor;
  final String categoria;
  final String titulo;
  final String descricao;
}
