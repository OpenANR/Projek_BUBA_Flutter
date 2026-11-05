// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class UserModel {
  final int id;
  final String kode_user;
  final String name;
  final String email;
  final String password;
  final String jenis_kelamin;
  final String role;
  final int kelas_id;
  final String nama_kelas;

  UserModel({
    required this.id,
    required this.kode_user,
    required this.name,
    required this.email,
    required this.password,
    required this.jenis_kelamin,
    required this.role,
    required this.kelas_id,
    required this.nama_kelas,
  });

  UserModel copyWith({
    int? id,
    String? kode_user,
    String? name,
    String? email,
    String? password,
    String? jenis_kelamin,
    String? role,
    int? kelas_id,
    String? nama_kelas,
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
      nama_kelas: nama_kelas ?? this.nama_kelas,
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
      'nama_kelas': nama_kelas,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    final kelas = map['kelas'];

    return UserModel(
      id: map['id'] ?? 0,
      kode_user: map['kode_user'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      jenis_kelamin: map['jenis_kelamin'] ?? '',
      role: map['role'] ?? '',
      // Format API (nested) -> fallback ke format lokal (flat)
      kelas_id: kelas != null ? (kelas['id'] ?? 0) : (map['kelas_id'] ?? 0),
      nama_kelas: kelas != null
          ? (kelas['nama_kelas'] ?? 'Belum Diatur')
          : (map['nama_kelas'] ?? 'Belum Diatur'),
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'UserModel(id: $id, kode_user: $kode_user, name: $name, email: $email, password: $password, jenis_kelamin: $jenis_kelamin, role: $role, kelas_id: $kelas_id, nama_kelas: $nama_kelas)';
  }

  @override
  bool operator ==(covariant UserModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.kode_user == kode_user &&
        other.name == name &&
        other.email == email &&
        other.password == password &&
        other.jenis_kelamin == jenis_kelamin &&
        other.role == role &&
        other.kelas_id == kelas_id &&
        other.nama_kelas == nama_kelas;
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
        kelas_id.hashCode ^
        nama_kelas.hashCode;
  }
}
