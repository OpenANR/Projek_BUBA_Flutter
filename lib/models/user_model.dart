// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class UserModel {
  final int? id;
  final String? kode_user;
  final String? name;
  final String? email;
  final String? password;
  final String? jenis_kelamin;
  final String? role;
  final String? kelas_id;
  UserModel({
    this.id,
    this.kode_user,
    this.name,
    this.email,
    this.password,
    this.jenis_kelamin,
    this.role,
    this.kelas_id,
  });

  UserModel copyWith({
    int? id,
    String? kode_user,
    String? name,
    String? email,
    String? password,
    String? jenis_kelamin,
    String? role,
    String? kelas_id,
  }) {
    return UserModel(
      id: id ?? this.id,
      kode_user: kode_user ?? this.kode_user,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      jenis_kelamin: jenis_kelamin ?? this.jenis_kelamin,
      role: role ?? this.role,
      kelas_id: kelas_id ?? this.kelas_id,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'kode_user': kode_user,
      'name': name,
      'email': email,
      'password': password,
      'jenis_kelamin': jenis_kelamin,
      'role': role,
      'kelas_id': kelas_id,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] != null ? map['id'] as int : null,
      kode_user: map['kode_user'] != null ? map['kode_user'] as String : null,
      name: map['name'] != null ? map['name'] as String : null,
      email: map['email'] != null ? map['email'] as String : null,
      password: map['password'] != null ? map['password'] as String : null,
      jenis_kelamin: map['jenis_kelamin'] != null ? map['jenis_kelamin'] as String : null,
      role: map['role'] != null ? map['role'] as String : null,
      kelas_id: map['kelas_id'] != null ? map['kelas_id'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) => UserModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'UserModel(id: $id, kode_user: $kode_user, name: $name, email: $email, password: $password, jenis_kelamin: $jenis_kelamin, role: $role, kelas_id: $kelas_id)';
  }

  @override
  bool operator ==(covariant UserModel other) {
    if (identical(this, other)) return true;
  
    return 
      other.id == id &&
      other.kode_user == kode_user &&
      other.name == name &&
      other.email == email &&
      other.password == password &&
      other.jenis_kelamin == jenis_kelamin &&
      other.role == role &&
      other.kelas_id == kelas_id;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      kode_user.hashCode ^
      name.hashCode ^
      email.hashCode ^
      password.hashCode ^
      jenis_kelamin.hashCode ^
      role.hashCode ^
      kelas_id.hashCode;
  }
}
