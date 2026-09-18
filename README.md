# E-Bike Customer App — Setup Guide

## Setup (Same as Admin app)
1. Use the same Firebase project as the admin app (no new project required).
2. Run `flutterfire configure` for this app to generate a new `firebase_options.dart` for this app.
3. Import `firebase_options.dart` in `main.dart` and ensure `DefaultFirebaseOptions.currentPlatform` is used.
4. Run `flutter pub get`.
5. Run `flutter run`.

## Client login flow
- The admin creates a client document (username/password); those credentials are used to sign in to this app.
- After successful login the session is persisted locally on this device so the user remains signed in across app restarts.
- On first login the user completes an Info Form (name, phone, address, referrer).
- After submitting the form the client's status becomes `pendingConfirmation` and the user sees a waiting screen.
- When the admin confirms the client the app automatically navigates to the Dashboard in real time.
- Dashboard: next payment date, bike/battery info, cycle status (active/blocked), notifications list

## Features not yet available in this version
- Document upload (passport / récépissé-séjour / domicile) — not yet added to the info form, will be added later with Firebase Storage integration
- Push notification (currently only in-app notification list is shown, FCM not yet integrated)
- Bike number, battery numbers, rental amount — clients cannot set these themselves (as per your requirements), only admin app can set them

## Security Note
The same notes from the Admin app README apply here — plain text password, no Firestore Security Rules set yet. Once both apps are running, this should be addressed together.
