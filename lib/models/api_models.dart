import 'dart:convert';

class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.roles,
  });

  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final List<String> roles;

  String get fullName {
    final name = '$firstName $lastName'.trim();
    return name.isEmpty ? email : name;
  }

  bool get isAdmin => roles.contains('ROLE_ADMIN');
  bool get isProvider => roles.contains('ROLE_PROVIDER');
  bool get isCustomer => roles.contains('ROLE_CUSTOMER');

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: _asInt(json['id']),
      email: json['email']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      roles: (json['roles'] as List<dynamic>? ?? const [])
          .map((role) => role.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'roles': roles,
      };

  static AppUser? fromJsonString(String? value) {
    if (value == null || value.isEmpty) return null;
    final decoded = jsonDecode(value);
    if (decoded is Map<String, dynamic>) {
      return AppUser.fromJson(decoded);
    }
    return null;
  }

  String toJsonString() => jsonEncode(toJson());
}

class AuthResponse {
  const AuthResponse({
    required this.token,
    required this.tokenType,
    required this.expiresAt,
    required this.user,
  });

  final String token;
  final String tokenType;
  final DateTime? expiresAt;
  final AppUser user;

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token']?.toString() ?? '',
      tokenType: json['tokenType']?.toString() ?? 'Bearer',
      expiresAt: DateTime.tryParse(json['expiresAt']?.toString() ?? ''),
      user: AppUser.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}

class MetricsResource {
  const MetricsResource({
    required this.usersTotal,
    required this.providersApproved,
    required this.vehiclesAvailable,
    required this.vehiclesInService,
    required this.bookingsConfirmed,
    required this.bookingsActive,
    required this.bookingsFinished,
    required this.paymentsAuthorized,
    required this.paymentsCaptured,
  });

  final int usersTotal;
  final int providersApproved;
  final int vehiclesAvailable;
  final int vehiclesInService;
  final int bookingsConfirmed;
  final int bookingsActive;
  final int bookingsFinished;
  final int paymentsAuthorized;
  final int paymentsCaptured;

  factory MetricsResource.fromJson(Map<String, dynamic> json) {
    return MetricsResource(
      usersTotal: _asInt(json['usersTotal']),
      providersApproved: _asInt(json['providersApproved']),
      vehiclesAvailable: _asInt(json['vehiclesAvailable']),
      vehiclesInService: _asInt(json['vehiclesInService']),
      bookingsConfirmed: _asInt(json['bookingsConfirmed']),
      bookingsActive: _asInt(json['bookingsActive']),
      bookingsFinished: _asInt(json['bookingsFinished']),
      paymentsAuthorized: _asInt(json['paymentsAuthorized']),
      paymentsCaptured: _asInt(json['paymentsCaptured']),
    );
  }
}

class VehicleResource {
  const VehicleResource({
    required this.id,
    required this.ownerId,
    required this.status,
    required this.title,
    required this.description,
    required this.hourlyPrice,
    required this.latitude,
    required this.longitude,
    required this.ratingAvg,
  });

  final String id;
  final String ownerId;
  final String status;
  final String title;
  final String description;
  final double hourlyPrice;
  final double latitude;
  final double longitude;
  final double ratingAvg;

  factory VehicleResource.fromJson(Map<String, dynamic> json) {
    return VehicleResource(
      id: json['id']?.toString() ?? '',
      ownerId: json['ownerId']?.toString() ?? '',
      status: json['status']?.toString() ?? 'UNKNOWN',
      title: json['title']?.toString() ?? 'Vehiculo',
      description: json['description']?.toString() ?? '',
      hourlyPrice: _asDouble(json['hourlyPrice']),
      latitude: _asDouble(json['latitude']),
      longitude: _asDouble(json['longitude']),
      ratingAvg: _asDouble(json['ratingAvg']),
    );
  }
}

class PaymentMethodResource {
  const PaymentMethodResource({
    required this.id,
    required this.brand,
    required this.last4,
    required this.isDefault,
  });

  final String id;
  final String brand;
  final String last4;
  final bool isDefault;

  factory PaymentMethodResource.fromJson(Map<String, dynamic> json) {
    return PaymentMethodResource(
      id: json['id']?.toString() ?? '',
      brand: json['brand']?.toString() ?? 'CARD',
      last4: json['last4']?.toString() ?? '',
      isDefault: json['isDefault'] == true,
    );
  }
}

class PayoutResource {
  const PayoutResource({
    required this.id,
    required this.amount,
    required this.status,
  });

  final String id;
  final double amount;
  final String status;

  factory PayoutResource.fromJson(Map<String, dynamic> json) {
    return PayoutResource(
      id: json['id']?.toString() ?? '',
      amount: _asDouble(json['amount']),
      status: json['status']?.toString() ?? 'UNKNOWN',
    );
  }
}

class ProviderResource {
  const ProviderResource({
    required this.id,
    required this.userId,
    required this.status,
    required this.displayName,
    required this.phone,
    required this.docType,
    required this.docNumber,
  });

  final String id;
  final String userId;
  final String status;
  final String displayName;
  final String phone;
  final String docType;
  final String docNumber;

  factory ProviderResource.fromJson(Map<String, dynamic> json) {
    return ProviderResource(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      status: json['status']?.toString() ?? 'UNKNOWN',
      displayName: json['displayName']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      docType: json['docType']?.toString() ?? '',
      docNumber: json['docNumber']?.toString() ?? '',
    );
  }
}

int _asInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

double _asDouble(Object? value) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}
