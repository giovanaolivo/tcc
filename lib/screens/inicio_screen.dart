import 'package:flutter/material.dart';

import '../models/registro_alimentacao.dart';
import '../models/registro_sintoma.dart';
import '../services/alimentacao_service.dart';
import '../services/sintomas_service.dart';
import '../widgets/navegacao_principal.dart';

class InicioScreen extends StatefulWidget {
  const InicioScreen({super.key, this.sintomasStream, this.refeicoesStream});

  final Stream<List<RegistroSintoma>>? sintomasStream;
  final Stream<List<RegistroAlimentacao>>? refeicoesStream;

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  static const _azulPrincipal = Color(0xFF246FB5);
  static const _minimoDeRegistros = 5;
  static const _janelaDeAssociacao = Duration(hours: 6);

  late final Stream<List<RegistroSintoma>> _sintomas;
  late final Stream<List<RegistroAlimentacao>> _refeicoes;

  @override
  void initState() {
    super.initState();
    _sintomas = widget.sintomasStream ?? SintomasService().observarSintomas();
    _refeicoes =
        widget.refeicoesStream ?? AlimentacaoService().observarRefeicoes();
  }

  bool _aconteceuHoje(DateTime dataHora) {
    final hoje = DateTime.now();
    return dataHora.year == hoje.year &&
        dataHora.month == hoje.month &&
        dataHora.day == hoje.day;
  }

  String _formatarHorario(DateTime dataHora) {
    final hora = dataHora.hour.toString().padLeft(2, '0');
    final minuto = dataHora.minute.toString().padLeft(2, '0');
    return '$hora:$minuto';
  }

  List<_AtividadeRecente> _reunirAtividades(
    List<RegistroSintoma> sintomas,
    List<RegistroAlimentacao> refeicoes,
  ) {
    final atividades = <_AtividadeRecente>[
      ...sintomas.map(
        (sintoma) => _AtividadeRecente(
          dataHora: sintoma.dataHora,
          icon: Icons.health_and_safety_outlined,
          cor: const Color(0xFFE45858),
          titulo: sintoma.nomeExibido,
          descricao: 'Sintoma • intensidade ${sintoma.intensidade}/5',
        ),
      ),
      ...refeicoes.map(
        (refeicao) => _AtividadeRecente(
          dataHora: refeicao.dataHora,
          icon: Icons.restaurant_outlined,
          cor: _azulPrincipal,
          titulo: refeicao.tipoRefeicao,
          descricao: refeicao.alimentos.join(', '),
        ),
      ),
    ];

    atividades.sort((a, b) => b.dataHora.compareTo(a.dataHora));
    return atividades.take(3).toList();
  }

  _PadraoDescritivo? _identificarPadrao(
    List<RegistroSintoma> sintomas,
    List<RegistroAlimentacao> refeicoes,
  ) {
    if (sintomas.length < _minimoDeRegistros ||
        refeicoes.length < _minimoDeRegistros) {
      return null;
    }

    final frequenciaDosSintomas = <String, int>{};
    for (final sintoma in sintomas) {
      frequenciaDosSintomas.update(
        sintoma.nomeExibido,
        (quantidade) => quantidade + 1,
        ifAbsent: () => 1,
      );
    }

    final sintomaMaisFrequente = frequenciaDosSintomas.entries.reduce(
      (atual, proximo) => atual.value >= proximo.value ? atual : proximo,
    );

    final alimentosAntesDosSintomas = <String, int>{};
    for (final sintoma in sintomas) {
      for (final refeicao in refeicoes) {
        final intervalo = sintoma.dataHora.difference(refeicao.dataHora);
        final ocorreuAntes = !intervalo.isNegative;
        if (!ocorreuAntes || intervalo > _janelaDeAssociacao) continue;

        for (final alimento in refeicao.alimentos.toSet()) {
          alimentosAntesDosSintomas.update(
            alimento,
            (quantidade) => quantidade + 1,
            ifAbsent: () => 1,
          );
        }
      }
    }

    MapEntry<String, int>? alimentoMaisAssociado;
    if (alimentosAntesDosSintomas.isNotEmpty) {
      alimentoMaisAssociado = alimentosAntesDosSintomas.entries.reduce(
        (atual, proximo) => atual.value >= proximo.value ? atual : proximo,
      );
    }

    return _PadraoDescritivo(
      sintoma: sintomaMaisFrequente.key,
      quantidadeDoSintoma: sintomaMaisFrequente.value,
      alimento: alimentoMaisAssociado?.key,
      quantidadeDoAlimento: alimentoMaisAssociado?.value ?? 0,
    );
  }

  Widget _conteudoComDados(
    List<RegistroSintoma> sintomas,
    List<RegistroAlimentacao> refeicoes,
  ) {
    final sintomasHoje = sintomas.where(
      (item) => _aconteceuHoje(item.dataHora),
    );
    final refeicoesHoje = refeicoes.where(
      (item) => _aconteceuHoje(item.dataHora),
    );
    final atividades = _reunirAtividades(sintomas, refeicoes);
    final padrao = _identificarPadrao(sintomas, refeicoes);

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 32),
      children: [
        const Text(
          'Olá!',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        const Text(
          'Acompanhe seus registros em um só lugar.',
          style: TextStyle(color: Color(0xFF667085), fontSize: 15),
        ),
        const SizedBox(height: 26),
        const _TituloSecao('Resumo de hoje'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _CartaoResumo(
                icon: Icons.health_and_safety_outlined,
                cor: const Color(0xFFE45858),
                valor: sintomasHoje.length.toString(),
                rotulo: sintomasHoje.length == 1 ? 'sintoma' : 'sintomas',
                onTap: () => Navigator.pushNamed(context, '/sintomas'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _CartaoResumo(
                icon: Icons.restaurant_outlined,
                cor: _azulPrincipal,
                valor: refeicoesHoje.length.toString(),
                rotulo: refeicoesHoje.length == 1 ? 'refeição' : 'refeições',
                onTap: () => Navigator.pushNamed(context, '/alimentacao'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _BotaoAtalho(
          icon: Icons.favorite_outline,
          texto: 'Hábitos do dia',
          onTap: () => Navigator.pushNamed(context, '/habitos'),
        ),
        const SizedBox(height: 26),
        const _TituloSecao('Frequência dos sintomas'),
        const SizedBox(height: 12),
        _CartaoFrequenciaSintomas(
          sintomas: sintomas,
          minimoDeRegistros: _minimoDeRegistros,
        ),
        const SizedBox(height: 26),
        const _TituloSecao('Registrar'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _BotaoAtalho(
                icon: Icons.add_circle_outline,
                texto: 'Novo sintoma',
                onTap: () => Navigator.pushNamed(context, '/novo-sintoma'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _BotaoAtalho(
                icon: Icons.add_circle_outline,
                texto: 'Nova refeição',
                onTap: () => Navigator.pushNamed(context, '/nova-refeicao'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 26),
        const _TituloSecao('Possíveis padrões'),
        const SizedBox(height: 12),
        _CartaoPadroes(
          quantidadeDeSintomas: sintomas.length,
          quantidadeDeRefeicoes: refeicoes.length,
          minimoDeRegistros: _minimoDeRegistros,
          padrao: padrao,
        ),
        const SizedBox(height: 26),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const _TituloSecao('Atividade recente'),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/historico'),
              child: const Text('Ver histórico'),
            ),
          ],
        ),
        const SizedBox(height: 6),
        if (atividades.isEmpty)
          const _EstadoVazio()
        else
          Card(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: const BorderSide(color: Color(0xFFE1E7EF)),
            ),
            child: Column(
              children: List.generate(atividades.length, (index) {
                final atividade = atividades[index];
                return Column(
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: atividade.cor.withValues(alpha: 0.12),
                        foregroundColor: atividade.cor,
                        child: Icon(atividade.icon),
                      ),
                      title: Text(
                        atividade.titulo,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(atividade.descricao),
                      trailing: Text(
                        _formatarHorario(atividade.dataHora),
                        style: const TextStyle(
                          color: Color(0xFF667085),
                          fontSize: 12,
                        ),
                      ),
                    ),
                    if (index < atividades.length - 1)
                      const Divider(height: 1, indent: 72),
                  ],
                );
              }),
            ),
          ),
        const SizedBox(height: 22),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFEAF4FD),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, color: _azulPrincipal),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Os registros ajudam a organizar seu histórico, mas não substituem avaliação profissional.',
                  style: TextStyle(color: Color(0xFF344054), height: 1.35),
                ),
              ),
            ],
          ),
        ),
      ],
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
          'SAÚDE INTESTINAL',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      body: StreamBuilder<List<RegistroSintoma>>(
        stream: _sintomas,
        builder: (context, sintomasSnapshot) {
          return StreamBuilder<List<RegistroAlimentacao>>(
            stream: _refeicoes,
            builder: (context, refeicoesSnapshot) {
              if (sintomasSnapshot.hasError || refeicoesSnapshot.hasError) {
                return const _ErroCarregamento();
              }
              if (!sintomasSnapshot.hasData || !refeicoesSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              return _conteudoComDados(
                sintomasSnapshot.data!,
                refeicoesSnapshot.data!,
              );
            },
          );
        },
      ),
      bottomNavigationBar: const NavegacaoPrincipal(indiceAtual: 0),
    );
  }
}

class _TituloSecao extends StatelessWidget {
  const _TituloSecao(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Text(
      texto,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
    );
  }
}

class _CartaoResumo extends StatelessWidget {
  const _CartaoResumo({
    required this.icon,
    required this.cor,
    required this.valor,
    required this.rotulo,
    required this.onTap,
  });

  final IconData icon;
  final Color cor;
  final String valor;
  final String rotulo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFE1E7EF)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: cor),
              const SizedBox(height: 14),
              Text(
                valor,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(rotulo, style: const TextStyle(color: Color(0xFF667085))),
            ],
          ),
        ),
      ),
    );
  }
}

class _BotaoAtalho extends StatelessWidget {
  const _BotaoAtalho({
    required this.icon,
    required this.texto,
    required this.onTap,
  });

  final IconData icon;
  final String texto;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(texto, textAlign: TextAlign.center),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _EstadoVazio extends StatelessWidget {
  const _EstadoVazio();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE1E7EF)),
      ),
      child: const Row(
        children: [
          Icon(Icons.history, color: Color(0xFF98A2B3)),
          SizedBox(width: 12),
          Expanded(child: Text('Seus registros recentes aparecerão aqui.')),
        ],
      ),
    );
  }
}

class _ErroCarregamento extends StatelessWidget {
  const _ErroCarregamento();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_outlined, size: 52, color: Color(0xFF98A2B3)),
            SizedBox(height: 12),
            Text(
              'Não foi possível carregar o resumo.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _CartaoPadroes extends StatelessWidget {
  const _CartaoPadroes({
    required this.quantidadeDeSintomas,
    required this.quantidadeDeRefeicoes,
    required this.minimoDeRegistros,
    required this.padrao,
  });

  final int quantidadeDeSintomas;
  final int quantidadeDeRefeicoes;
  final int minimoDeRegistros;
  final _PadraoDescritivo? padrao;

  @override
  Widget build(BuildContext context) {
    final possuiQuantidadeMinima =
        quantidadeDeSintomas >= minimoDeRegistros &&
        quantidadeDeRefeicoes >= minimoDeRegistros;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE1E7EF)),
      ),
      child: possuiQuantidadeMinima
          ? _PadraoDisponivel(padrao: padrao)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.auto_graph_outlined, color: Color(0xFF246FB5)),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Continue registrando',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'São necessários registros suficientes para apresentar associações temporais descritivas.',
                  style: TextStyle(color: Color(0xFF667085), height: 1.35),
                ),
                const SizedBox(height: 14),
                _ProgressoRegistros(
                  rotulo: 'Sintomas',
                  quantidade: quantidadeDeSintomas,
                  minimo: minimoDeRegistros,
                ),
                const SizedBox(height: 10),
                _ProgressoRegistros(
                  rotulo: 'Refeições',
                  quantidade: quantidadeDeRefeicoes,
                  minimo: minimoDeRegistros,
                ),
              ],
            ),
    );
  }
}

class _CartaoFrequenciaSintomas extends StatelessWidget {
  const _CartaoFrequenciaSintomas({
    required this.sintomas,
    required this.minimoDeRegistros,
  });

  final List<RegistroSintoma> sintomas;
  final int minimoDeRegistros;

  List<DateTime> _ultimosSeteDias() {
    final agora = DateTime.now();
    final hoje = DateTime(agora.year, agora.month, agora.day);
    return List.generate(
      7,
      (index) => hoje.subtract(Duration(days: 6 - index)),
    );
  }

  bool _mesmoDia(DateTime primeira, DateTime segunda) {
    return primeira.year == segunda.year &&
        primeira.month == segunda.month &&
        primeira.day == segunda.day;
  }

  String _inicialDoDia(DateTime data) {
    const iniciais = ['S', 'T', 'Q', 'Q', 'S', 'S', 'D'];
    return iniciais[data.weekday - 1];
  }

  List<MapEntry<String, int>> _maisFrequentes() {
    final frequencias = <String, int>{};
    for (final sintoma in sintomas) {
      frequencias.update(
        sintoma.nomeExibido,
        (quantidade) => quantidade + 1,
        ifAbsent: () => 1,
      );
    }

    final ordenadas = frequencias.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return ordenadas.take(3).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (sintomas.length < minimoDeRegistros) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE1E7EF)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'O gráfico aparecerá quando houver mais dados registrados.',
              style: TextStyle(color: Color(0xFF667085), height: 1.35),
            ),
            const SizedBox(height: 14),
            _ProgressoRegistros(
              rotulo: 'Sintomas',
              quantidade: sintomas.length,
              minimo: minimoDeRegistros,
            ),
          ],
        ),
      );
    }

    final dias = _ultimosSeteDias();
    final frequencias = dias
        .map(
          (dia) => sintomas
              .where((sintoma) => _mesmoDia(sintoma.dataHora, dia))
              .length,
        )
        .toList();
    final maiorFrequencia = frequencias.reduce(
      (atual, proxima) => atual > proxima ? atual : proxima,
    );
    final sintomasMaisFrequentes = _maisFrequentes();

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE1E7EF)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Últimos 7 dias',
                style: TextStyle(
                  color: Color(0xFF667085),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 125,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(7, (index) {
                    final quantidade = frequencias[index];
                    final proporcao = maiorFrequencia == 0
                        ? 0.0
                        : quantidade / maiorFrequencia;
                    final altura = quantidade == 0 ? 5.0 : 75.0 * proporcao;

                    return Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            '$quantidade',
                            style: const TextStyle(
                              color: Color(0xFF667085),
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 4),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 350),
                            width: 24,
                            height: altura,
                            decoration: BoxDecoration(
                              color: quantidade == 0
                                  ? const Color(0xFFDCEEFF)
                                  : const Color(0xFF246FB5),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                            ),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            _inicialDoDia(dias[index]),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE1E7EF)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sintomas mais frequentes',
                style: TextStyle(
                  color: Color(0xFF667085),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: sintomasMaisFrequentes.map((item) {
                  return Chip(
                    avatar: const Icon(
                      Icons.circle,
                      size: 9,
                      color: Color(0xFFE45858),
                    ),
                    label: Text('${item.key} (${item.value})'),
                    side: BorderSide.none,
                    backgroundColor: const Color(0xFFFFEEEE),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PadraoDisponivel extends StatelessWidget {
  const _PadraoDisponivel({required this.padrao});

  final _PadraoDescritivo? padrao;

  @override
  Widget build(BuildContext context) {
    if (padrao == null) {
      return const Text('Ainda não foi possível identificar recorrências.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.auto_graph_outlined, color: Color(0xFF246FB5)),
            SizedBox(width: 10),
            Text(
              'Resumo descritivo',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          '${padrao!.sintoma} foi o sintoma mais registrado (${padrao!.quantidadeDoSintoma} vezes).',
        ),
        const SizedBox(height: 8),
        Text(
          padrao!.alimento == null
              ? 'Não houve refeição registrada nas 6 horas anteriores aos sintomas.'
              : '${padrao!.alimento} apareceu em refeições registradas nas 6 horas anteriores a ${padrao!.quantidadeDoAlimento} ocorrência(s) de sintomas.',
        ),
        const SizedBox(height: 12),
        const Text(
          'Essas informações representam recorrências temporais e não indicam causa, diagnóstico ou recomendação clínica.',
          style: TextStyle(
            color: Color(0xFF667085),
            fontSize: 12,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

class _ProgressoRegistros extends StatelessWidget {
  const _ProgressoRegistros({
    required this.rotulo,
    required this.quantidade,
    required this.minimo,
  });

  final String rotulo;
  final int quantidade;
  final int minimo;

  @override
  Widget build(BuildContext context) {
    final progresso = (quantidade / minimo).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text(rotulo), Text('$quantidade/$minimo')],
        ),
        const SizedBox(height: 5),
        LinearProgressIndicator(
          value: progresso,
          minHeight: 7,
          borderRadius: BorderRadius.circular(8),
        ),
      ],
    );
  }
}

class _AtividadeRecente {
  const _AtividadeRecente({
    required this.dataHora,
    required this.icon,
    required this.cor,
    required this.titulo,
    required this.descricao,
  });

  final DateTime dataHora;
  final IconData icon;
  final Color cor;
  final String titulo;
  final String descricao;
}

class _PadraoDescritivo {
  const _PadraoDescritivo({
    required this.sintoma,
    required this.quantidadeDoSintoma,
    required this.alimento,
    required this.quantidadeDoAlimento,
  });

  final String sintoma;
  final int quantidadeDoSintoma;
  final String? alimento;
  final int quantidadeDoAlimento;
}
