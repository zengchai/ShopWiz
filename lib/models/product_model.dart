class Product {
  final String pid;
  final String pname;
  final double pprice;
  final int pquantity;
  final String pdescription;
  final String pimageUrl;

  Product({
    required this.pid,
    required this.pname,
    required this.pprice,
    required this.pquantity,
    required this.pdescription,
    required this.pimageUrl,
  });

  static Product fromMap(Map<String, dynamic> data) {
    return Product(
      pid: data['pid'] ?? '',
      pname: data['pname'] ?? '',
      pprice: (data['pprice'] as num?)?.toDouble() ?? 0.0,
      pquantity: (data['pquantity'] as num?)?.toInt() ?? 0,
      pdescription: data['pdescription'] ?? '',
      pimageUrl: data['pimageUrl'] ?? '',
    );
  }
}