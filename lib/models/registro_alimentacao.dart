import 'package:cloud_firestore/cloud_firestore.dart';

class RegistroAlimentacao {
  const RegistroAlimentacao({
    required this.id,
    required this.tipoRefeicao,
    required this.alimentos,
    required this.dataHora,
    required this.observacao,
  });

  final String id;
  final String tipoRefeicao;
  final List<String> alimentos;
  final DateTime dataHora;
  final String observacao;

  factory RegistroAlimentacao.fromFirestore(
    QueryDocumentSnapshot<Map<String, dynamic>> documento,
  ) {
    final dados = documento.data();
    final alimentos = dados['alimentos'] as List<dynamic>? ?? const [];

    return RegistroAlimentacao(
      id: documento.id,
      tipoRefeicao: dados['tipoRefeicao'] as String? ?? 'Refeição',
      alimentos: alimentos.map((item) => item.toString()).toList(),
      dataHora: (dados['dataHora'] as Timestamp?)?.toDate() ?? DateTime.now(),
      observacao: dados['observacao'] as String? ?? '',
    );
  }
}
