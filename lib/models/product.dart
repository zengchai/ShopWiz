class Product {
  final String pid;
  final String pname;
  final double pprice;
  final int pquantity;
  final String pcategory;
  final String pdescription;
  final String pimageUrl;

  Product({
    required this.pid,
    required this.pname,
    required this.pprice,
    required this.pquantity,
    required this.pcategory,
    required this.pdescription,
    required this.pimageUrl,
  });

  static Product fromMap(Map<String, dynamic> data) {
    return Product(
      pid: data['pid'] ?? '',
      pname: data['pname'] ?? '',
      pprice: (data['pprice'] as num).toDouble(),
      pquantity: (data['pquantity'] as num).toInt(),
      pcategory: data['pcategory'] ?? '',
      pdescription: data['pdescription'] ?? '',
      pimageUrl: data['pimageUrl'] ?? '',
    );
  }
}
