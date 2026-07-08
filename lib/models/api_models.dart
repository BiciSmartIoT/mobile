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
    required this.deviceId,
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
  final String? deviceId;
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
      deviceId: json['deviceId']?.toString(),
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

class IotDeviceConfigResource {
  const IotDeviceConfigResource({
    required this.deviceId,
    required this.speedLimitKmph,
    required this.geofenceCenterLat,
    required this.geofenceCenterLon,
    required this.geofenceRadiusMeters,
    this.updatedAt,
  });

  final String deviceId;
  final double speedLimitKmph;
  final double geofenceCenterLat;
  final double geofenceCenterLon;
  final double geofenceRadiusMeters;
  final DateTime? updatedAt;

  factory IotDeviceConfigResource.fromJson(Map<String, dynamic> json) {
    return IotDeviceConfigResource(
      deviceId: json['deviceId']?.toString() ?? '',
      speedLimitKmph: _asDouble(json['speedLimitKmph']),
      geofenceCenterLat: _asDouble(json['geofenceCenterLat']),
      geofenceCenterLon: _asDouble(json['geofenceCenterLon']),
      geofenceRadiusMeters: _asDouble(json['geofenceRadiusMeters']),
      updatedAt: _nullableDateTime(json['updatedAt']),
    );
  }
}

class IotDeviceStateResource {
  const IotDeviceStateResource({
    required this.deviceId,
    required this.eventType,
    required this.blocked,
    required this.message,
    this.latitude,
    this.longitude,
    this.speedKmph,
    this.insideGeofence,
    this.lockState,
    this.updatedAt,
  });

  final String deviceId;
  final String eventType;
  final bool blocked;
  final String message;
  final double? latitude;
  final double? longitude;
  final double? speedKmph;
  final bool? insideGeofence;
  final String? lockState;
  final DateTime? updatedAt;

  factory IotDeviceStateResource.fromJson(Map<String, dynamic> json) {
    return IotDeviceStateResource(
      deviceId: json['deviceId']?.toString() ?? '',
      eventType: json['eventType']?.toString() ?? 'UNKNOWN',
      blocked: json['blocked'] == true,
      message: json['message']?.toString() ?? '',
      latitude: _nullableDouble(json['latitude']),
      longitude: _nullableDouble(json['longitude']),
      speedKmph: _nullableDouble(json['speedKmph']),
      insideGeofence: json['insideGeofence'] is bool
          ? json['insideGeofence'] as bool
          : null,
      lockState: json['lockState']?.toString(),
      updatedAt: _nullableDateTime(json['updatedAt']),
    );
  }
}

class IotDeviceCommandResource {
  const IotDeviceCommandResource({
    required this.commandId,
    required this.deviceId,
    required this.type,
    required this.reason,
    required this.status,
  });

  final String commandId;
  final String deviceId;
  final String type;
  final String reason;
  final String status;

  factory IotDeviceCommandResource.fromJson(Map<String, dynamic> json) {
    return IotDeviceCommandResource(
      commandId: json['commandId']?.toString() ?? '',
      deviceId: json['deviceId']?.toString() ?? '',
      type: json['type']?.toString() ?? 'UNKNOWN',
      reason: json['reason']?.toString() ?? '',
      status: json['status']?.toString() ?? 'UNKNOWN',
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

double? _nullableDouble(Object? value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

DateTime? _nullableDateTime(Object? value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}
