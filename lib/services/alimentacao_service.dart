import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/registro_alimentacao.dart';

class AlimentacaoService {
  AlimentacaoService([this._firestore]);

  final FirebaseFirestore? _firestore;

  FirebaseFirestore get _database => _firestore ?? FirebaseFirestore.instance;

  String get _usuarioId {
    final usuario = FirebaseAuth.instance.currentUser;

    if (usuario == null) {
      throw StateError('Usuário não autenticado.');
    }

    return usuario.uid;
  }

  Stream<List<RegistroAlimentacao>> observarRefeicoes() {
    return _database
        .collection('registros_alimentacao')
        .where('usuarioId', isEqualTo: _usuarioId)
        .snapshots()
        .map((consulta) {
          final registros = consulta.docs
              .map(RegistroAlimentacao.fromFirestore)
              .toList();
          registros.sort((a, b) => b.dataHora.compareTo(a.dataHora));
          return registros;
        });
  }

  Future<void> adicionarRefeicao({
    required String tipoRefeicao,
    required List<String> alimentos,
    required DateTime dataHora,
    required String observacao,
  }) async {
    await _database.collection('registros_alimentacao').add({
      'tipoRefeicao': tipoRefeicao,
      'alimentos': alimentos,
      'dataHora': Timestamp.fromDate(dataHora),
      'observacao': observacao,
      'usuarioId': _usuarioId,
      'criadoEm': FieldValue.serverTimestamp(),
      'atualizadoEm': FieldValue.serverTimestamp(),
    });
  }

  Future<void> excluirRefeicao(String registroId) async {
    await _database
        .collection('registros_alimentacao')
        .doc(registroId)
        .delete();
  }
}
