import 'package:flutter/material.dart';

import '../models/registro_alimentacao.dart';
import '../services/alimentacao_service.dart';
import '../widgets/navegacao_principal.dart';

class ListaAlimentacaoScreen extends StatefulWidget {
  const ListaAlimentacaoScreen({super.key});

  @override
  State<ListaAlimentacaoScreen> createState() => _ListaAlimentacaoScreenState();
}

class _ListaAlimentacaoScreenState extends State<ListaAlimentacaoScreen> {
  static const _azulPrincipal = Color(0xFF246FB5);

  final _service = AlimentacaoService();
  final _buscaController = TextEditingController();
  late final Stream<List<RegistroAlimentacao>> _registros;

  @override
  void initState() {
    super.initState();
    _registros = _service.observarRefeicoes();
  }

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  String _formatarDataHora(DateTime dataHora) {
    final dia = dataHora.day.toString().padLeft(2, '0');
    final mes = dataHora.month.toString().padLeft(2, '0');
    final hora = dataHora.hour.toString().padLeft(2, '0');
    final minuto = dataHora.minute.toString().padLeft(2, '0');
    return '$dia/$mes/${dataHora.year} às $hora:$minuto';
  }

  List<RegistroAlimentacao> _filtrar(List<RegistroAlimentacao> registros) {
    final busca = _buscaController.text.trim().toLowerCase();
    if (busca.isEmpty) return registros;

    return registros.where((registro) {
      return registro.tipoRefeicao.toLowerCase().contains(busca) ||
          registro.alimentos.join(' ').toLowerCase().contains(busca) ||
          registro.observacao.toLowerCase().contains(busca);
    }).toList();
  }

  Future<void> _confirmarExclusao(RegistroAlimentacao registro) async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir refeição?'),
        content: Text('Deseja excluir o registro de ${registro.tipoRefeicao}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmou != true) return;
    try {
      await _service.excluirRefeicao(registro.id);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível excluir a refeição.')),
      );
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
          'ALIMENTAÇÃO',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(18, 18, 18, 12),
              child: Row(
                children: [
                  Icon(Icons.restaurant_menu, color: _azulPrincipal),
                  SizedBox(width: 10),
                  Text(
                    'Minhas refeições',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
              child: TextField(
                controller: _buscaController,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  hintText: 'Buscar refeição ou alimento...',
                  prefixIcon: Icon(Icons.search),
                  isDense: true,
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<List<RegistroAlimentacao>>(
                stream: _registros,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const _EstadoListaAlimentacao(
                      icon: Icons.cloud_off_outlined,
                      titulo: 'Não foi possível carregar a alimentação',
                    );
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final registros = _filtrar(snapshot.data!);
                  if (registros.isEmpty) {
                    return const _EstadoListaAlimentacao(
                      icon: Icons.restaurant_outlined,
                      titulo: 'Nenhuma refeição encontrada',
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(18, 4, 18, 90),
                    itemCount: registros.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final registro = registros[index];
                      return Card(
                        elevation: 0,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                          side: const BorderSide(color: Color(0xFFE1E7EF)),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.fromLTRB(
                            14,
                            8,
                            6,
                            8,
                          ),
                          leading: const CircleAvatar(
                            backgroundColor: Color(0xFFE6F1FB),
                            foregroundColor: _azulPrincipal,
                            child: Icon(Icons.restaurant_outlined),
                          ),
                          title: Text(
                            registro.tipoRefeicao,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          subtitle: Text(
                            '${_formatarDataHora(registro.dataHora)}\n${registro.alimentos.join(', ')}'
                            '${registro.observacao.isEmpty ? '' : ' • ${registro.observacao}'}',
                          ),
                          isThreeLine: true,
                          trailing: IconButton(
                            tooltip: 'Excluir',
                            onPressed: () => _confirmarExclusao(registro),
                            icon: const Icon(Icons.delete_outline),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/nova-refeicao'),
        tooltip: 'Adicionar refeição',
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: const NavegacaoPrincipal(indiceAtual: 2),
    );
  }
}

class _EstadoListaAlimentacao extends StatelessWidget {
  const _EstadoListaAlimentacao({required this.icon, required this.titulo});

  final IconData icon;
  final String titulo;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 52, color: const Color(0xFF98A2B3)),
          const SizedBox(height: 12),
          Text(titulo, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
