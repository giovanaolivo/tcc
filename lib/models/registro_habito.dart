import 'package:cloud_firestore/cloud_firestore.dart';

class RegistroHabito {
  const RegistroHabito({
    required this.id,
    required this.dataHora,
    required this.evacuou,
    required this.consistenciaBristol,
    required this.horasSono,
    required this.qualidadeSono,
    required this.atividadeFisica,
    required this.duracaoAtividadeMinutos,
    required this.nivelEstresse,
    required this.observacao,
  });

  final String id;
  final DateTime dataHora;
  final bool evacuou;
  final int? consistenciaBristol;
  final double horasSono;
  final String qualidadeSono;
  final bool atividadeFisica;
  final int duracaoAtividadeMinutos;
  final int nivelEstresse;
  final String observacao;

  factory RegistroHabito.fromFirestore(
    QueryDocumentSnapshot<Map<String, dynamic>> documento,
  ) {
    final dados = documento.data();

    return RegistroHabito(
      id: documento.id,
      dataHora: (dados['dataHora'] as Timestamp?)?.toDate() ?? DateTime.now(),
      evacuou: dados['evacuou'] as bool? ?? false,
      consistenciaBristol: (dados['consistenciaBristol'] as num?)?.toInt(),
      horasSono: (dados['horasSono'] as num?)?.toDouble() ?? 0,
      qualidadeSono: dados['qualidadeSono'] as String? ?? 'Não informada',
      atividadeFisica: dados['atividadeFisica'] as bool? ?? false,
      duracaoAtividadeMinutos:
          (dados['duracaoAtividadeMinutos'] as num?)?.toInt() ?? 0,
      nivelEstresse: (dados['nivelEstresse'] as num?)?.toInt() ?? 0,
      observacao: dados['observacao'] as String? ?? '',
    );
  }
}
