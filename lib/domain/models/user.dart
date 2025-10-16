import 'package:equatable/equatable.dart';
import 'area.dart';

enum UserRole { ADMIN, MESA_PARTES, AREA, AUDITOR }

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
          return UserRole.ADMIN;
        case 'MESA_PARTES':
          return UserRole.MESA_PARTES;
        case 'AREA':
          return UserRole.AREA;
        case 'AUDITOR':
          return UserRole.AUDITOR;
        default:
          // Fallback: default to area
          return UserRole.AREA;
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
        case UserRole.ADMIN:
          return 'ADMIN';
        case UserRole.MESA_PARTES:
          return 'MESA_PARTES';
        case UserRole.AREA:
          return 'AREA';
        case UserRole.AUDITOR:
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
