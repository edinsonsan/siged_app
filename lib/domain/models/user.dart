import 'package:equatable/equatable.dart';
import 'area.dart';

enum UserRole { admin, mesaPartes, area, auditor }

/// Immutable User model
class User extends Equatable {
  final num id;
  final String nombre;
  final String apellido;
  final String email;
  final UserRole rol;
  final Area? area;
  final String createdAt;
  final String updatedAt;

  const User({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.email,
    required this.rol,
    required this.area,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    UserRole parseRole(String value) {
      switch (value) {
        case 'ADMIN':
          return UserRole.admin;
        case 'MESA_PARTES':
          return UserRole.mesaPartes;
        case 'AREA':
          return UserRole.area;
        case 'AUDITOR':
          return UserRole.auditor;
        default:
          // Fallback: default to area
          return UserRole.area;
      }
    }

    return User(
      id: json['id'] as num,
      nombre: json['nombre'] as String,
      apellido: json['apellido'] as String,
      email: json['email'] as String,
      rol: parseRole(json['rol'] as String),
      area: json['area'] != null ? Area.fromJson(json['area'] as Map<String, dynamic>) : null,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    String roleToString(UserRole r) {
      switch (r) {
        case UserRole.admin:
          return 'ADMIN';
        case UserRole.mesaPartes:
          return 'MESA_PARTES';
        case UserRole.area:
          return 'AREA';
        case UserRole.auditor:
          return 'AUDITOR';
      }
    }

    return {
      'id': id,
      'nombre': nombre,
      'apellido': apellido,
      'email': email,
      'rol': roleToString(rol),
      'area': area?.toJson(),
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  @override
  List<Object?> get props => [id, nombre, apellido, email, rol, area, createdAt, updatedAt];
}
