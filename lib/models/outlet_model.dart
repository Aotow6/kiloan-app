class OutletModel {
  final int? id;
  final String namaOutlet;
  final String? alamat;
  final String? jamBuka;
  final String? jamTutup;
  final bool allowKasbon;

  OutletModel({
    this.id,
    required this.namaOutlet,
    this.alamat,
    this.jamBuka,
    this.jamTutup,
    this.allowKasbon = true,
  });

  factory OutletModel.fromMap(Map<String, dynamic> map) {
    return OutletModel(
      id: map['id'],
      namaOutlet: map['nama_outlet'],
      alamat: map['alamat'],
      jamBuka: map['jam_buka'],
      jamTutup: map['jam_tutup'],
      allowKasbon: map['allow_kasbon'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'nama_outlet': namaOutlet,
      'alamat': alamat,
      'jam_buka': jamBuka,
      'jam_tutup': jamTutup,
      'allow_kasbon': allowKasbon,
    };
  }
}