import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shopwiz/commons/BaseLayout.dart';
import 'package:shopwiz/commons/BaselayoutAdmin.dart';
import 'package:shopwiz/pages/home/model/product.dart';
import 'package:shopwiz/pages/home/productdetails.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shopwiz/services/firebase_service.dart';
import 'package:shopwiz/services/reviewservice.dart'; // Import the FirebaseService

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  String currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
  int todaysOrders = 0;
  double todaysTotalPrice = 0.0;
  String? selectedYear = "2024";
  String? selectedMonth;
  Map<String, int>? monthlyOrders;
  bool isLoading = true;

  Future<void> _fetchMonthlyOrders(String year) async {
    setState(() {
      isLoading = true;
    });
    monthlyOrders = await Reviewservice(uid: currentUid).getMonthlyOrders(year);
    print(monthlyOrders);
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _fetchTodaysOrders() async {
    try {
      Map<String, dynamic> result =
          await Reviewservice(uid: currentUid).getTodaysOrders();
      setState(() {
        todaysOrders = result['totalOrders'];
        todaysTotalPrice = result['totalPrice'];
      });
    } catch (e) {
      print("Error fetching today's orders: $e");
    }
  }

  String getDayWithSuffix(int day) {
    if (day >= 11 && day <= 13) {
      return '${day}th';
    }
    switch (day % 10) {
      case 1:
        return '${day}st';
      case 2:
        return '${day}nd';
      case 3:
        return '${day}rd';
      default:
        return '${day}th';
    }
  }

  List<FlSpot> _generateFlSpots() {
    List<FlSpot> spots = [];
    if (monthlyOrders != null && monthlyOrders!.isNotEmpty) {
      List<String> months = [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December'
      ];
      for (int i = 0; i < months.length; i++) {
        String month = months[i];
        spots
            .add(FlSpot(i.toDouble(), (monthlyOrders![month] ?? 0).toDouble()));
      }
    }
    return spots;
  }

  @override
  void initState() {
    super.initState();
    _fetchTodaysOrders();
    _fetchMonthlyOrders("2024"); // Fetch monthly orders on app start
  }

  @override
  Widget build(BuildContext context) {
    String adminUid = '7aXevcNf3Cahdmk9l5jLRASw5QO2';
    String currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    DateTime now = DateTime.now();
    String month = DateFormat('MMMM').format(now);
    String formattedDate = getDayWithSuffix(now.day);

    List<String> years =
        List.generate(10, (index) => (2024 - index).toString());
    List<String> months = List.generate(
        12, (index) => DateFormat('MMMM').format(DateTime(0, index + 1)));

    return currentUid == adminUid
        ? BaseLayoutAdmin(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(25, 15, 0, 0),
              child: Text(
                'Dashboard',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.green[900],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              // Add the color property here
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blueAccent, // Background color
                borderRadius: BorderRadius.circular(15), // Curved corners
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        "Today",
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.white, // White text color
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        '$month $formattedDate',
                        style: TextStyle(
                          fontSize: 12,
                          color:
                              Colors.white.withOpacity(0.7), // White text color
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${todaysOrders}",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white, // White text color
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Orders",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white
                                  .withOpacity(0.9), // White text color
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Transform(
                        transform: Matrix4.identity()
                          ..translate(0.0, 0.0)
                          ..rotateZ(1.57),
                        child: Container(
                          width: 20,
                          decoration: ShapeDecoration(
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                width: 1,
                                strokeAlign: BorderSide.strokeAlignCenter,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${todaysTotalPrice}",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white, // White text color
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Revenue (RM)",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white
                                  .withOpacity(0.9), // White text color
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(20, 0, 0, 0),
              child: Row(
                children: [
                  DropdownButton<String>(
                    hint: Text('Select Year'),
                    value: selectedYear,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedYear = newValue;
                      });
                      _fetchMonthlyOrders(newValue!);
                    },
                    items: years.map((String year) {
                      return DropdownMenuItem<String>(
                        value: year,
                        child: Text(year),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(0, 20, 30, 0),
              child: AspectRatio(
                aspectRatio: 2.0,
                child: isLoading
                    ? Center(child: CircularProgressIndicator())
                    : monthlyOrders == null || monthlyOrders!.isEmpty
                        ? Center(
                            child:
                                Text('No data available for the selected year'))
                        : LineChart(LineChartData(
                            lineBarsData: [
                              LineChartBarData(
                                spots: _generateFlSpots(),
                                isCurved: true,
                                colors: [Colors.blue],
                                barWidth: 5,
                                belowBarData: BarAreaData(
                                  show: true,
                                  colors: [Colors.blue.withOpacity(0.3)],
                                ),
                              ),
                            ],
                            titlesData: FlTitlesData(
                              bottomTitles: SideTitles(
                                showTitles: true,
                                getTitles: (value) {
                                  List<String> months = [
                                    'Jan',
                                    'Feb',
                                    'Mar',
                                    'Apr',
                                    'May',
                                    'Jun',
                                    'Jul',
                                    'Aug',
                                    'Sep',
                                    'Oct',
                                    'Nov',
                                    'Dec'
                                  ];
                                  return months[value.toInt()];
                                },
                              ),
                            ),
                          )),
              ),
            ),
          ]))
        : BaseLayout(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Discover',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.green[900],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: FutureBuilder<List<Product>>(
                    future: _firebaseService
                        .getProducts(), // Fetch products from Firebase
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else {
                        List<Product> products = snapshot.data!;
                        return ListView.builder(
                          itemCount: (products.length / 2).ceil(),
                          itemBuilder: (context, index) {
                            final startIndex = index * 2;
                            final endIndex = startIndex + 2;
                            return Row(
                              children: [
                                for (int i = startIndex; i < endIndex; i++)
                                  if (i < products.length)
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: _buildCard(context, products[i]),
                                      ),
                                    ),
                              ],
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          );
  }

  Widget _buildCard(BuildContext context, Product product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsScreen(
              productId: product.pid,
              userId: '',
            ),
          ),
        );
      },
      child: Card(
        elevation: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            SizedBox(
              width: double.infinity,
              height: 200, // Increase the height of the card
              child: Image.network(
                product.pimageUrl,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product name
                  Text(
                    product.pname,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.0),
                  // Product price
                  Text(
                    '\RM ${product.pprice.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.green[900],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
