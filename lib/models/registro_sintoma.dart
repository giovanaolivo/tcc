import 'package:cloud_firestore/cloud_firestore.dart';

class RegistroSintoma {
  const RegistroSintoma({
    required this.id,
    required this.tipoSintoma,
    required this.outroSintoma,
    required this.intensidade,
    required this.dataHora,
    required this.observacao,
  });

  final String id;
  final String tipoSintoma;
  final String outroSintoma;
  final int intensidade;
  final DateTime dataHora;
  final String observacao;

  String get nomeExibido {
    if (tipoSintoma == 'Outro' && outroSintoma.isNotEmpty) {
      return outroSintoma;
    }
    return tipoSintoma;
  }

  factory RegistroSintoma.fromFirestore(
    QueryDocumentSnapshot<Map<String, dynamic>> documento,
  ) {
    final dados = documento.data();

    return RegistroSintoma(
      id: documento.id,
      tipoSintoma: dados['tipoSintoma'] as String? ?? 'Sintoma',
      outroSintoma: dados['outroSintoma'] as String? ?? '',
      intensidade: (dados['intensidade'] as num?)?.toInt() ?? 0,
      dataHora: (dados['dataHora'] as Timestamp?)?.toDate() ?? DateTime.now(),
      observacao: dados['observacao'] as String? ?? '',
    );
  }
}
