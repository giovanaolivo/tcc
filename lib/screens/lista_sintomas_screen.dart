import 'package:flutter/material.dart';

import '../models/registro_sintoma.dart';
import '../services/sintomas_service.dart';
import '../widgets/navegacao_principal.dart';

class ListaSintomasScreen extends StatefulWidget {
  const ListaSintomasScreen({super.key});

  @override
  State<ListaSintomasScreen> createState() => _ListaSintomasScreenState();
}

class _ListaSintomasScreenState extends State<ListaSintomasScreen> {
  static const _azulPrincipal = Color(0xFF246FB5);
  static const _filtros = [
    'Todos',
    'Dor abdominal',
    'Inchaço',
    'Diarreia',
    'Náusea',
    'Outro',
  ];

  final _service = SintomasService();
  final _buscaController = TextEditingController();
  late final Stream<List<RegistroSintoma>> _registros;
  String _filtroSelecionado = 'Todos';

  @override
  void initState() {
    super.initState();
    _registros = _service.observarSintomas();
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

  List<RegistroSintoma> _filtrar(List<RegistroSintoma> registros) {
    final busca = _buscaController.text.trim().toLowerCase();
    return registros.where((registro) {
      final correspondeAoFiltro =
          _filtroSelecionado == 'Todos' ||
          registro.tipoSintoma == _filtroSelecionado;
      final correspondeABusca =
          busca.isEmpty ||
          registro.nomeExibido.toLowerCase().contains(busca) ||
          registro.observacao.toLowerCase().contains(busca);
      return correspondeAoFiltro && correspondeABusca;
    }).toList();
  }

  Future<void> _confirmarExclusao(RegistroSintoma registro) async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir sintoma?'),
        content: Text('Deseja excluir o registro de ${registro.nomeExibido}?'),
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
      await _service.excluirSintoma(registro.id);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível excluir o sintoma.')),
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
          'LISTAGEM DE SINTOMAS',
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
                  Icon(Icons.format_list_bulleted, color: _azulPrincipal),
                  SizedBox(width: 10),
                  Text(
                    'Meus sintomas',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: TextField(
                controller: _buscaController,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  hintText: 'Buscar sintoma...',
                  prefixIcon: Icon(Icons.search),
                  isDense: true,
                ),
              ),
            ),
            SizedBox(
              height: 58,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                scrollDirection: Axis.horizontal,
                itemCount: _filtros.length,
                separatorBuilder: (_, _) => const SizedBox(width: 7),
                itemBuilder: (context, index) {
                  final filtro = _filtros[index];
                  return FilterChip(
                    label: Text(filtro),
                    selected: _filtroSelecionado == filtro,
                    showCheckmark: false,
                    onSelected: (_) {
                      setState(() => _filtroSelecionado = filtro);
                    },
                  );
                },
              ),
            ),
            Expanded(
              child: StreamBuilder<List<RegistroSintoma>>(
                stream: _registros,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const _EstadoLista(
                      icon: Icons.cloud_off_outlined,
                      titulo: 'Não foi possível carregar os sintomas',
                    );
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final registros = _filtrar(snapshot.data!);
                  if (registros.isEmpty) {
                    return const _EstadoLista(
                      icon: Icons.edit_note_outlined,
                      titulo: 'Nenhum sintoma encontrado',
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
                          leading: Container(
                            width: 11,
                            height: 11,
                            decoration: BoxDecoration(
                              color: registro.intensidade >= 4
                                  ? Colors.red
                                  : registro.intensidade >= 3
                                  ? Colors.orange
                                  : Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          title: Text(
                            registro.nomeExibido,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          subtitle: Text(
                            '${_formatarDataHora(registro.dataHora)}\nIntensidade ${registro.intensidade}/5'
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
        onPressed: () => Navigator.pushNamed(context, '/novo-sintoma'),
        tooltip: 'Adicionar sintoma',
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: const NavegacaoPrincipal(indiceAtual: 1),
    );
  }
}

class _EstadoLista extends StatelessWidget {
  const _EstadoLista({required this.icon, required this.titulo});

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
