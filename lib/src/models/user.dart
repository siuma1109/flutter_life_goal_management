// To parse this JSON data, do
//
//     final user = userFromJson(jsonString);

import 'dart:convert';

User userFromJson(String str) => User.fromJson(json.decode(str));

String userToJson(User data) => json.encode(data.toJson());

class User {
  int? id;
  String name;
  String email;
  String? currentPassword;
  String? password;
  DateTime? emailVerifiedAt;
  DateTime createdAt;
  DateTime updatedAt;

  User({
    this.id,
    required this.name,
    required this.email,
    this.currentPassword,
    this.password,
    this.emailVerifiedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        name: json["name"] ?? "",
        email: json["email"] ?? "",
        emailVerifiedAt: json["email_verified_at"] != null
            ? DateTime.parse(json["email_verified_at"])
            : null,
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
        "current_password": currentPassword,
        "password": password,
        "email_verified_at": emailVerifiedAt?.toIso8601String(),
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
      };
}
