import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import '../models/client_model.dart';
import '../services/firestore_service.dart';
import '../services/session.dart';
import 'info_form_screen.dart';
import 'pending_screen.dart';
import 'dashboard_screen.dart';

/// Single entry point after login. Listens to the client's status and
/// routes to whichever screen matches — so an admin confirming or
/// blocking the client updates this app live, no refresh needed.
class HomeRouterScreen extends StatefulWidget {
  const HomeRouterScreen({super.key});

  @override
  State<HomeRouterScreen> createState() => _HomeRouterScreenState();
}

class _HomeRouterScreenState extends State<HomeRouterScreen> {
  final _firestore = FirestoreService();

  @override
  void initState() {
    super.initState();
    _registerPushToken();
  }

  // Best-effort: if push permission/token isn't available (e.g. simulator,
  // or user denies it), the app still works fine — reminders just fall
  // back to the in-app notification list.
  Future<void> _registerPushToken() async {
    try {
      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission();
      final token = await messaging.getToken();
      if (token != null) {
        await _firestore.saveFcmToken(Session.instance.clientId!, token);
      }
    } catch (_) {
      // Ignore — push is a nice-to-have, not required for the app to work.
    }
  }

  @override
  Widget build(BuildContext context) {
    final clientId = Session.instance.clientId!;

    return StreamBuilder<ClientModel>(
      stream: _firestore.watchClient(clientId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final client = snapshot.data!;
        switch (client.status) {
          case ClientStatus.pendingInfo:
            return InfoFormScreen(client: client);
          case ClientStatus.pendingConfirmation:
            return const PendingScreen();
          case ClientStatus.active:
          case ClientStatus.blocked:
            return DashboardScreen(client: client);
        }
      },
    );
  }
}
