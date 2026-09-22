import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/registro_sintoma.dart';

class SintomasService {
  SintomasService([this._firestore]);

  final FirebaseFirestore? _firestore;

  FirebaseFirestore get _database => _firestore ?? FirebaseFirestore.instance;

  String get _usuarioId {
    final usuario = FirebaseAuth.instance.currentUser;

    if (usuario == null) {
      throw StateError('Usuário não autenticado.');
    }

    return usuario.uid;
  }

  Stream<List<RegistroSintoma>> observarSintomas() {
    return _database
        .collection('registros_sintomas')
        .where('usuarioId', isEqualTo: _usuarioId)
        .snapshots()
        .map((consulta) {
          final registros = consulta.docs
              .map(RegistroSintoma.fromFirestore)
              .toList();
          registros.sort((a, b) => b.dataHora.compareTo(a.dataHora));
          return registros;
        });
  }

  Future<void> adicionarSintoma({
    required String tipoSintoma,
    required String outroSintoma,
    required int intensidade,
    required DateTime dataHora,
    required String observacao,
  }) async {
    await _database.collection('registros_sintomas').add({
      'tipoSintoma': tipoSintoma,
      'outroSintoma': outroSintoma,
      'intensidade': intensidade,
      'dataHora': Timestamp.fromDate(dataHora),
      'observacao': observacao,
      'usuarioId': _usuarioId,
      'criadoEm': FieldValue.serverTimestamp(),
      'atualizadoEm': FieldValue.serverTimestamp(),
    });
  }

  Future<void> excluirSintoma(String registroId) async {
    await _database.collection('registros_sintomas').doc(registroId).delete();
  }
}
