import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/client_model.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;
  CollectionReference<Map<String, dynamic>> get _clients => _db.collection('clients');

  /// Returns the client's doc id if username/password match, else null.
  /// Admin creates every client doc beforehand, so a match here always
  /// means a real, admin-issued account.
  Future<String?> login(String username, String password) async {
    final query = await _clients
        .where('username', isEqualTo: username.toLowerCase())
        .where('password', isEqualTo: password)
        .limit(1)
        .get();
    if (query.docs.isEmpty) return null;
    return query.docs.first.id;
  }

  Stream<ClientModel> watchClient(String id) {
    return _clients.doc(id).snapshots().map(ClientModel.fromDoc);
  }

  /// Client fills this in once, right after their first login.
  Future<void> submitInfo(String id, Map<String, dynamic> fields) async {
    await _clients.doc(id).update({
      ...fields,
      'status': 'pendingConfirmation',
    });
  }

  Stream<List<Map<String, dynamic>>> watchNotifications(String clientId) {
    return _clients
        .doc(clientId)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => {...d.data(), 'id': d.id}).toList());
  }

  /// Saves this device's push token on the client doc so Cloud Functions
  /// can send a reminder push later. Safe to call every login — it just
  /// overwrites the previous token.
  Future<void> saveFcmToken(String clientId, String token) async {
    await _clients.doc(clientId).update({'fcmToken': token});
  }
}
