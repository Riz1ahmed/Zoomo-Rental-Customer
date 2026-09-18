import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../models/client_model.dart';
import '../services/firestore_service.dart';
import '../services/session.dart';
import '../services/storage_service.dart';
import '../theme.dart';
import 'login_screen.dart';

class InfoFormScreen extends StatefulWidget {
  final ClientModel client;
  const InfoFormScreen({super.key, required this.client});

  @override
  State<InfoFormScreen> createState() => _InfoFormScreenState();
}

class _InfoFormScreenState extends State<InfoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestore = FirestoreService();
  final _storage = StorageService();
  bool _saving = false;

  late final _fullNameCtrl = TextEditingController(text: widget.client.fullName);
  late final _phoneCtrl = TextEditingController(text: widget.client.phone);
  late final _addressCtrl = TextEditingController(text: widget.client.address);
  late final _referrerNameCtrl = TextEditingController(text: widget.client.referrerName);
  late final _referrerPhoneCtrl = TextEditingController(text: widget.client.referrerPhone);

  // Note: bike number, battery numbers, and rental amount stay out of this
  // form on purpose — only the admin sets those.

  File? _passportFile;
  File? _recepisseFile;
  File? _domicileFile;

  Future<File?> _pickFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (result == null || result.single.path == null) return null;
    final file = File(result.single.path!);
    const maxBytes = 800 * 1024; // 800 KB
    try {
      final len = await file.length();
      if (len > maxBytes) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Selected file is too large. Maximum 800 KB allowed.')),
          );
        }
        return null;
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not read selected file. Please try another file.')),
        );
      }
      return null;
    }
    return file;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_passportFile == null || _recepisseFile == null || _domicileFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All three documents are required.')),
      );
      return;
    }

    // Enforce max file size (safety check before uploading)
    const maxBytes = 800 * 1024; // 800 KB
    try {
      final pLen = await _passportFile!.length();
      final rLen = await _recepisseFile!.length();
      final dLen = await _domicileFile!.length();
      if (pLen > maxBytes || rLen > maxBytes || dLen > maxBytes) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Each document must be at most 800 KB. Please choose smaller files.')),
          );
        }
        return;
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not read file sizes. Please try selecting the files again.')),
        );
      }
      return;
    }

    setState(() => _saving = true);
    try {
      final clientId = widget.client.id;
      final passportUrl = await _storage.uploadDocument(clientId: clientId, docType: 'passport', file: _passportFile!);
      final recepisseUrl = await _storage.uploadDocument(clientId: clientId, docType: 'recepisse', file: _recepisseFile!);
      final domicileUrl = await _storage.uploadDocument(clientId: clientId, docType: 'domicile', file: _domicileFile!);

      await _firestore.submitInfo(clientId, {
        'fullName': _fullNameCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'address': _addressCtrl.text.trim(),
        'referrerName': _referrerNameCtrl.text.trim(),
        'referrerPhone': _referrerPhoneCtrl.text.trim(),
        'passportUrl': passportUrl,
        'recepisseUrl': recepisseUrl,
        'domicileUrl': domicileUrl,
      });
      // No navigation needed — HomeRouterScreen listens to status changes
      // and will swap to the "pending confirmation" screen automatically.
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      setState(() => _saving = false);
    }
  }

  Widget _docPicker({
    required String label,
    required File? file,
    required VoidCallback onPick,
  }) {
    return InkWell(
      onTap: onPick,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceHigh,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: file != null ? AppColors.primary : AppColors.border),
        ),
        child: Row(
          children: [
            Icon(file != null ? Icons.check_circle : Icons.upload_file, color: file != null ? AppColors.primary : AppColors.textSecondary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(
                    file != null ? file.path.split('/').last : 'Select a PDF or image',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Future<void> _logout(BuildContext context) async {
    await Session.instance.logout();
    if (!context.mounted) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Your Information'),
        actions: [IconButton(onPressed: () => _logout(context), icon: const Icon(Icons.logout))],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Please provide the following information before starting your rental. After you submit, the admin will confirm and your dashboard will be activated.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _fullNameCtrl,
              decoration: const InputDecoration(labelText: 'Full Name'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneCtrl,
              decoration: const InputDecoration(labelText: 'Phone Number'),
              keyboardType: TextInputType.phone,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _addressCtrl,
              decoration: const InputDecoration(labelText: 'Full Address'),
              maxLines: 2,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _referrerNameCtrl,
              decoration: const InputDecoration(labelText: 'Referer Full Name'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _referrerPhoneCtrl,
              decoration: const InputDecoration(labelText: 'Referer Phone Number'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 24),
            Text('Documents', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            _docPicker(
              label: 'Passport Copy',
              file: _passportFile,
              onPick: () async {
                final f = await _pickFile();
                if (f != null) setState(() => _passportFile = f);
              },
            ),
            const SizedBox(height: 10),
            _docPicker(
              label: 'Récépissé / Séjour Copy',
              file: _recepisseFile,
              onPick: () async {
                final f = await _pickFile();
                if (f != null) setState(() => _recepisseFile = f);
              },
            ),
            const SizedBox(height: 10),
            _docPicker(
              label: 'Domicile / Proof of Address',
              file: _domicileFile,
              onPick: () async {
                final f = await _pickFile();
                if (f != null) setState(() => _domicileFile = f);
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saving ? null : _submit,
              child: _saving
                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                  : const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
