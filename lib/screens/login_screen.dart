import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../services/session.dart';
import '../theme.dart';
import 'home_router_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _login() async {
    final username = _usernameCtrl.text.trim();
    final password = _passwordCtrl.text.trim();
    if (username.isEmpty || password.isEmpty) {
      setState(() => _error = 'Please enter username and password');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final firestore = FirestoreService();
      final clientId = await firestore.login(username, password);
      if (!mounted) return;
      if (clientId != null) {
        await Session.instance.login(clientId);
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeRouterScreen()),
        );
      } else {
        setState(() => _error = 'Incorrect username or password');
      }
    } catch (e) {
      setState(() => _error = 'An error occurred: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.electric_bike, size: 56, color: AppColors.primary),
                const SizedBox(height: 12),
                const Text('Welcome', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.textPrimary), textAlign: TextAlign.center),
                const SizedBox(height: 4),
                const Text('Please sign in with your account credentials', style: TextStyle(color: AppColors.textSecondary), textAlign: TextAlign.center),
                const SizedBox(height: 32),
                TextField(
                  controller: _usernameCtrl,
                  decoration: const InputDecoration(labelText: 'Username'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password'),
                  onSubmitted: (_) => _login(),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!, style: const TextStyle(color: AppColors.danger)),
                ],
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _loading ? null : _login,
                  child: _loading
                      ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                      : const Text('Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
