import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:impostor/domain/model/word_pair.dart';
import 'package:impostor/domain/service/round_feedback_service.dart';

class FirebaseRoundFeedbackService implements RoundFeedbackService {
  final FirebaseFirestore _firestore;

  FirebaseRoundFeedbackService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<void> saveApprovedWordPair({
    required WordPair wordPair,
    required String gameMode,
  }) {
    final docId =
        '${wordPair.civilianWord}_${wordPair.impostorWord}'.toLowerCase();

    return _firestore.collection('word_pairs').doc(docId).set({
      'civilianWord': wordPair.civilianWord,
      'impostorWord': wordPair.impostorWord,
      'gameMode': gameMode,
    });
  }
}
