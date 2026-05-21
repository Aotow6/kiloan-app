// lib/models/user_model.dart
class UserModel {
  final String id; // UUID dari Supabase Auth
  final int? outletId;
  final String namaLengkap;
  final String role;
  final String? noHp;
  final bool statusAktif;

  UserModel({
    required this.id,
    this.outletId,
    required this.namaLengkap,
    required this.role,
    this.noHp,
    this.statusAktif = true,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      outletId: map['outlet_id'],
      namaLengkap: map['nama_lengkap'],
      role: map['role'],
      noHp: map['no_hp'],
      statusAktif: map['status_aktif'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'outlet_id': outletId,
      'nama_lengkap': namaLengkap,
      'role': role,
      'no_hp': noHp,
      'status_aktif': statusAktif,
    };
  }
}