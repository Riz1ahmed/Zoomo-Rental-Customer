import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

/// Uploads a document file for a client and returns its download URL.
/// Files are stored under clients/{clientId}/{docType}.{ext} — re-uploading
/// the same docType overwrites the old file rather than piling up copies.
class StorageService {
  final _storage = FirebaseStorage.instance;

  Future<String> uploadDocument({
    required String clientId,
    required String docType, // 'passport' | 'recepisse' | 'domicile'
    required File file,
  }) async {
    final ext = file.path.split('.').last;
    final ref = _storage.ref('clients/$clientId/$docType.$ext');
    await ref.putFile(file);
    return ref.getDownloadURL();
  }
}
