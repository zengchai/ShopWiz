class Product {
  final String pid;
  final String pname;
  final String pdescription;
  String pimageUrl; // Removed 'final' keyword
  final double pprice;
  final int pquantity;

  Product({
    required this.pid,
    required this.pname,
    required this.pdescription,
    required this.pimageUrl,
    required this.pprice,
    required this.pquantity,
  });
}
