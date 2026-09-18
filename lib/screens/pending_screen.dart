import 'package:flutter/material.dart';
import '../services/session.dart';
import '../theme.dart';
import 'login_screen.dart';

class PendingScreen extends StatelessWidget {
  const PendingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.hourglass_top, size: 56, color: AppColors.warning),
              const SizedBox(height: 16),
              const Text(
                'Your information has been submitted',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Your dashboard will be activated once the admin verifies and confirms your information.',
                style: TextStyle(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () async {
                  await Session.instance.logout();
                  if (!context.mounted) return;
                  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
                },
                child: const Text('Logout'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
