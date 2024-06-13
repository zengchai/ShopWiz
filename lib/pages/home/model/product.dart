class Product {
  final String pid;
  final String pname;
  final String pcategory;
  final String pdescription;
  late final String pimageUrl;
  final double pprice;
  final int pquantity;

  Product({
    required this.pid,
    required this.pname,
    required this.pcategory,
    required this.pdescription,
    required this.pimageUrl,
    required this.pprice,
    required this.pquantity,
  });
}