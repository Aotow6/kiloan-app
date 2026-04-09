// lib/models/outlet_model.dart
class OutletModel {
  final int? id;
  final String namaOutlet;
  final String? alamat;
  final String? jamBuka;
  final String? jamTutup;

  OutletModel({this.id, required this.namaOutlet, this.alamat, this.jamBuka, this.jamTutup});

  // Mapping dari Map Supabase ke Object Dart
  factory OutletModel.fromMap(Map<String, dynamic> map) {
    return OutletModel(
      id: map['id'],
      namaOutlet: map['nama_outlet'],
      alamat: map['alamat'],
      jamBuka: map['jam_buka'],
      jamTutup: map['jam_tutup'],
    );
  }

  // Mapping dari Object Dart ke Map untuk Simpan ke Supabase
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'nama_outlet': namaOutlet,
      'alamat': alamat,
      'jam_buka': jamBuka,
      'jam_tutup': jamTutup,
    };
  }
}