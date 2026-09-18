import 'package:cloud_firestore/cloud_firestore.dart';

enum ClientStatus { pendingInfo, pendingConfirmation, active, blocked }

ClientStatus statusFromString(String? value) {
  switch (value) {
    case 'pendingConfirmation':
      return ClientStatus.pendingConfirmation;
    case 'active':
      return ClientStatus.active;
    case 'blocked':
      return ClientStatus.blocked;
    default:
      return ClientStatus.pendingInfo;
  }
}

class ClientModel {
  final String id;
  final String username;
  final String fullName;
  final String phone;
  final String bikeNumber;
  final String battery1;
  final String battery2;
  final String rentalAmount;
  final String referrerName;
  final String referrerPhone;
  final String address;
  final DateTime? nextPaymentDate;
  final ClientStatus status;

  ClientModel({
    required this.id,
    required this.username,
    this.fullName = '',
    this.phone = '',
    this.bikeNumber = '',
    this.battery1 = '',
    this.battery2 = '',
    this.rentalAmount = '',
    this.referrerName = '',
    this.referrerPhone = '',
    this.address = '',
    this.nextPaymentDate,
    this.status = ClientStatus.pendingInfo,
  });

  factory ClientModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return ClientModel(
      id: doc.id,
      username: data['username'] ?? '',
      fullName: data['fullName'] ?? '',
      phone: data['phone'] ?? '',
      bikeNumber: data['bikeNumber'] ?? '',
      battery1: data['battery1'] ?? '',
      battery2: data['battery2'] ?? '',
      rentalAmount: data['rentalAmount'] ?? '',
      referrerName: data['referrerName'] ?? '',
      referrerPhone: data['referrerPhone'] ?? '',
      address: data['address'] ?? '',
      nextPaymentDate: (data['nextPaymentDate'] as Timestamp?)?.toDate(),
      status: statusFromString(data['status']),
    );
  }
}
