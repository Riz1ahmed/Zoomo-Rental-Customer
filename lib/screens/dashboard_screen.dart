import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/client_model.dart';
import '../services/firestore_service.dart';
import '../services/session.dart';
import '../theme.dart';
import 'login_screen.dart';

class DashboardScreen extends StatelessWidget {
  final ClientModel client;
  const DashboardScreen({super.key, required this.client});

  Future<void> _logout(BuildContext context) async {
    await Session.instance.logout();
    if (!context.mounted) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final isBlocked = client.status == ClientStatus.blocked;
    final firestore = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: Text('Hi, ${client.fullName.isEmpty ? client.username : client.fullName}'),
        actions: [IconButton(onPressed: () => _logout(context), icon: const Icon(Icons.logout))],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (isBlocked)
            Card(
              color: AppColors.danger.withOpacity(0.12),
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.block, color: AppColors.danger),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your cycle has been blocked. For details, please contact the admin.',
                        style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Card(
              color: AppColors.primary.withOpacity(0.12),
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: AppColors.primary),
                    SizedBox(width: 12),
                    Text('Cycle Active', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Next Payment Date', style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 6),
                  Text(
                    client.nextPaymentDate != null ? DateFormat('dd MMM yyyy').format(client.nextPaymentDate!) : 'Will be notified later',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _row('Bike Number', client.bikeNumber),
                  _row('Battery No. 1', client.battery1),
                  _row('Battery No. 2', client.battery2),
                  _row('Rental Amount', client.rentalAmount),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('Notifications', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: firestore.watchNotifications(client.id),
            builder: (context, snapshot) {
              final notifs = snapshot.data ?? [];
              if (notifs.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('No notifications', style: TextStyle(color: AppColors.textSecondary)),
                );
              }
              return Column(
                children: notifs.map((n) {
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.notifications_none, color: AppColors.primary),
                      title: Text(n['title'] ?? '', style: Theme.of(context).textTheme.titleMedium),
                      subtitle: Text(n['message'] ?? '', style: Theme.of(context).textTheme.bodySmall),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          Text(value, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
