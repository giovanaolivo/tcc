import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/registro_habito.dart';

class HabitosService {
  HabitosService([this._firestore]);

  final FirebaseFirestore? _firestore;

  FirebaseFirestore get _database => _firestore ?? FirebaseFirestore.instance;

  String get _usuarioId {
    final usuario = FirebaseAuth.instance.currentUser;
    if (usuario == null) {
      throw StateError('Usuário não autenticado.');
    }
    return usuario.uid;
  }

  Stream<List<RegistroHabito>> observarHabitos() {
    return _database
        .collection('registros_habitos')
        .where('usuarioId', isEqualTo: _usuarioId)
        .snapshots()
        .map((consulta) {
          final registros = consulta.docs
              .map(RegistroHabito.fromFirestore)
              .toList();
          registros.sort((a, b) => b.dataHora.compareTo(a.dataHora));
          return registros;
        });
  }

  Future<void> salvarHabitosDoDia({
    required DateTime dataHora,
    required bool evacuou,
    required int? consistenciaBristol,
    required double horasSono,
    required String qualidadeSono,
    required bool atividadeFisica,
    required int duracaoAtividadeMinutos,
    required int nivelEstresse,
    required String observacao,
  }) async {
    final usuarioId = _usuarioId;
    final data = '${dataHora.year.toString().padLeft(4, '0')}'
        '${dataHora.month.toString().padLeft(2, '0')}'
        '${dataHora.day.toString().padLeft(2, '0')}';
    final referencia = _database
        .collection('registros_habitos')
        .doc('${usuarioId}_$data');

    await referencia.set({
      'usuarioId': usuarioId,
      'dataHora': Timestamp.fromDate(dataHora),
      'evacuou': evacuou,
      'consistenciaBristol': evacuou ? consistenciaBristol : null,
      'horasSono': horasSono,
      'qualidadeSono': qualidadeSono,
      'atividadeFisica': atividadeFisica,
      'duracaoAtividadeMinutos': atividadeFisica
          ? duracaoAtividadeMinutos
          : 0,
      'nivelEstresse': nivelEstresse,
      'observacao': observacao,
      'criadoEm': FieldValue.serverTimestamp(),
      'atualizadoEm': FieldValue.serverTimestamp(),
    });
  }
}
