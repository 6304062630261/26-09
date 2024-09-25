import 'dart:ffi';
import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:sqflite/sqflite.dart';
import 'package:vongola/database/db_manage.dart';
import 'package:intl/intl.dart';

class Page2 extends StatefulWidget {
  @override
  _Page2State createState() => _Page2State();
}

class _Page2State extends State<Page2> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  String selectedButton = 'Day'; // เริ่มต้นที่ Day
  String selectedIcon = 'Pie'; // เริ่มต้นที่ Pie Chart
  double totalIncome = 0.0;
  double totalExpense = 0.0;
  List<PieChartSectionData> pieChartSections = [];
  List<Map<String, dynamic>> statusExpenses = [];
  List<Map<String, dynamic>> selectedDateExpenses = [];
  DateTime? selectedDate;

  final Map<String, Color> typeToColor = {
    'Food': Colors.red,
    'Travel expenses': Colors.lightGreenAccent,
    'Water bill': Colors.lightBlueAccent,
    'Electricity bill': Colors.yellow,
    'House cost': Colors.deepOrangeAccent,
    'Car fare': Colors.deepPurpleAccent,
    'Gasoline cost': Colors.orangeAccent,
    'Medical expenses': Colors.indigo,
    'Beauty expenses': Colors.pinkAccent,
    'Cost of equipment': Colors.blue.shade100,
    'Other': Colors.teal.shade400,


  };
  final Map<String, String> typeImage = {
    'Food': 'assets/food.png',
    'Travel expenses':'assets/travel_expenses.png',
    'Water bill': 'assets/water_bill.png',
    'Electricity bill': 'assets/electricity_bill.png',
    'House cost': 'assets/house.png',
    'Car fare': 'assets/car.png',
    'Gasoline cost': 'assets/gasoline_cost.png',
    'Medical expenses': 'assets/medical.png',
    'Beauty expenses': 'assets/beauty.png',
    'Other': 'assets/other.png',

  };

  @override
  void initState() {
    super.initState();
    selectedButton = 'Day'; // เริ่มต้นที่ Day
    selectedIcon = 'Pie'; // เริ่มต้นที่ Pie Chart
    _showFinancialPieChart(context); // เรียกใช้ Pie Chart สำหรับ Day
     // เรียก Status สำหรับ Day
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(title: Text('Static Chart')),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              // ส่วนการแสดงปฏิทินและไอคอน
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0), // เพิ่ม Padding ซ้ายและขวา
                child: TableCalendar(
                  firstDay: DateTime.utc(2023, 1, 1),
                  lastDay: DateTime.utc(2100, 1, 1),
                  focusedDay: DateTime.now(),
                  selectedDayPredicate: (day) => isSameDay(selectedDate, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      selectedDate = selectedDay;
                      print("กรี๊ดดดดดดดดดด");
                      print(selectedDay);
                      DateTime dateOnly = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
                      print("Selected date: $dateOnly");
                      _showDateDetailsDialog(dateOnly);
                    });
                  },
                ),
              ),
              SizedBox(height: 20),
              // ไอคอนต่างๆ
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0), // เพิ่ม Padding ซ้ายและขวา
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildIconButton(Icons.pie_chart, 'Pie', Colors.blue, _showFinancialPieChart),
                    SizedBox(width: 20),
                    _buildIconButton(Icons.shopify_rounded, 'Status', Colors.green, _showStatus_Expense),
                    SizedBox(width: 20),
                    _buildIconButton(Icons.bar_chart, 'Bar', Colors.orange, _showFinancialBarChart),
                  ],
                ),
              ),
              SizedBox(height: 20),
              // ปุ่ม Day, Month, Year
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0), // เพิ่ม Padding ซ้ายและขวา
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildPeriodButton('Day'),
                    SizedBox(width: 10),
                    _buildPeriodButton('Month'),
                    SizedBox(width: 10),
                    _buildPeriodButton('Year'),
                  ],
                ),
              ),
              SizedBox(height: 20),
              // ส่วนแสดงกราฟ Pie Chart
              if (selectedIcon == 'Pie') _buildPieChart(),
              // ส่วนแสดงกราฟ Bar Chart
              if (selectedIcon == 'Bar') _buildBarChart(),
              if (selectedIcon == 'Status') _buildStatusList()

            ],
          ),
        ),
      ),
    );
  }


  // สร้างปุ่มเลือกช่วงเวลา (Day, Month, Year)
  ElevatedButton _buildPeriodButton(String label) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: selectedButton == label ? Colors.blue : Colors.grey,
      ),
      onPressed: () {
        setState(() {
          selectedButton = label;
        });
        if (selectedIcon == 'Pie') {
          _showFinancialPieChart(context); // เรียกฟังก์ชันดึงข้อมูล Pie Chart เมื่อเลือกช่วงเวลา
        } else if (selectedIcon == 'Bar') {
          _showFinancialBarChart(context); // เรียกฟังก์ชันดึงข้อมูล Bar Chart เมื่อเลือกช่วงเวลา
        }else if(selectedIcon=='Status'){
          _showStatus_Expense(context);
        }
      },
      child: Text(label),
    );
  }

  Widget _buildIconButton(IconData icon, String iconType, Color color, Function onPressed) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: IconButton(
        icon: Icon(
          icon,
          color: selectedIcon == iconType ? color : Colors.black, // เปลี่ยนสีตามการเลือก
        ),
        onPressed: () {
          setState(() {
            selectedIcon = iconType;
          });
          onPressed(context);
        },
        iconSize: 60,
      ),
    );
  }

  Widget _buildIndicator() {
    return Column(
      children: pieChartSections.map((section) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: section.color, // สีของ Indicator ตาม PieChartSectionData
              ),
            ),
            SizedBox(width: 8),
            Text(
              '${section.title.split('\n')[0]}: ${section.value.toStringAsFixed(2)}', // แสดงชื่อและมูลค่า
              style: TextStyle(fontSize: 16),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildPieChart() {
    if (pieChartSections.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 50), // เพิ่มระยะห่างจากข้างบน
            Image.asset(
              'assets/Zzz.png', // ใส่ path รูปภาพที่คุณต้องการ
              width: 100, // กำหนดขนาดความกว้างของรูป
              height: 100, // กำหนดขนาดความสูงของรูป
              fit: BoxFit.cover, // กำหนดการแสดงผลรูปภาพ
            ),
          ],
        ),
      );
    }


    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          Container(
            height: 300,
            child: PieChart(
              PieChartData(
                sections: pieChartSections,
                centerSpaceRadius: 40,
                sectionsSpace: 2,
              ),
            ),
          ),
          SizedBox(height: 20),
          _buildIndicator(), // แสดง Indicator ใต้ Pie Chart
        ],
      ),
    );
  }



  Widget _buildBarChart() {
    if (totalIncome == 0.0 && totalExpense == 0.0) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 50), // เพิ่มระยะห่างจากข้างบน
            Image.asset(
              'assets/Zzz.png', // ใส่ path รูปภาพที่คุณต้องการ
              width: 100, // กำหนดขนาดความกว้างของรูป
              height: 100, // กำหนดขนาดความสูงของรูป
              fit: BoxFit.cover, // กำหนดการแสดงผลรูปภาพ
            ),
          ],
        ),
      );
    }
    return Column(
      children: [
        Container(
          height: 300,
          width: 200,
          child: BarChart(
            BarChartData(
              borderData: FlBorderData(
                show: true,
                border: Border(
                  bottom: BorderSide(color: Colors.black, width: 1), // เส้นขอบด้านล่าง
                  left: BorderSide(color: Colors.transparent, width: 0), // ไม่มีเส้นขอบด้านซ้าย
                  right: BorderSide(color: Colors.transparent, width: 0), // ไม่มีเส้นขอบด้านขวา
                  top: BorderSide(color: Colors.transparent, width: 0), // ไม่มีเส้นขอบด้านบน
                ),
              ),
              barGroups: [
                BarChartGroupData(
                  x: 1,
                  barRods: [
                    BarChartRodData(
                        y: totalExpense,
                        colors: [Colors.red],
                        width: 30,
                        borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10), // มุมด้านซ้ายบนมน
                        topRight: Radius.circular(10), // มุมด้านขวาบนมน
                        bottomLeft: Radius.circular(0), // มุมด้านซ้ายล่างตรง
                        bottomRight: Radius.circular(0), // มุมด้านขวาล่างตรง
                      ),
                    ),
                  ],
                ),
                BarChartGroupData(
                  x: 0,
                  barRods: [
                    BarChartRodData(
                        y: totalIncome,
                        colors: [Colors.green],
                        width: 30,
                        borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10), // มุมด้านซ้ายบนมน
                        topRight: Radius.circular(10), // มุมด้านขวาบนมน
                        bottomLeft: Radius.circular(0), // มุมด้านซ้ายล่างตรง
                        bottomRight: Radius.circular(0), // มุมด้านขวาล่างตรง
                      ),
                    ),
                  ],
                ),
              ],
              titlesData: FlTitlesData(
                leftTitles: SideTitles(showTitles: false),
                bottomTitles: SideTitles(
                  showTitles: true,
                  getTitles: (double value) {
                    return ''; // คุณสามารถแก้ไขหรือลบถ้าต้องการ
                  },
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 0), // ช่องว่างระหว่างกราฟกับข้อความ
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '- ${totalExpense}฿',
                    style: TextStyle(fontSize: 20, color: Colors.red),
                  ),
                ],
              ),
            ),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '+ ${totalIncome}฿',
                    style: TextStyle(fontSize: 20, color: Colors.green),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusList() {
    if (statusExpenses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 50), // เพิ่มระยะห่างจากข้างบน
            Image.asset(
              'assets/Zzz.png', // ใส่ path รูปภาพที่คุณต้องการ
              width: 100, // กำหนดขนาดความกว้างของรูป
              height: 100, // กำหนดขนาดความสูงของรูป
              fit: BoxFit.cover, // กำหนดการแสดงผลรูปภาพ
            ),
          ],
        ),
      );

    }
    return ListView.builder(
      shrinkWrap: true,
      itemCount: statusExpenses.length,
      itemBuilder: (context, index) {
        // ดึงชื่อประเภทเพื่อใช้ค้นหารูปภาพ
        final type = statusExpenses[index]['type'];
        final imagePath = typeImage[type] ?? 'assets/other.png'; // ใช้รูปภาพเริ่มต้นถ้าไม่พบประเภท

        return ListTile(
          leading: Image.asset(
            imagePath,
            width: 40, // ปรับขนาดตามที่ต้องการ
            height: 40,
            fit: BoxFit.cover,
          ),
          title: Text(type),
          trailing: Text('${statusExpenses[index]['amount'].toStringAsFixed(2)} THB'),
        );
      },
    );
  }

  // ฟังก์ชันสำหรับแสดง Dialog ข้อมูลวันที่ที่เลือก
  void _showDateDetailsDialog(DateTime date) async {
    print("888888888888888888888");
    print(date);
    print("888888888888888888888");
    String dateString = date.toIso8601String().split('T')[0];

    // ดึงข้อมูลตามวันที่เลือก
    await _fetchcalendarDay(dateString);
    print('selectedDateExpenses');
    print(selectedDateExpenses);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(' ${date.toLocal().toIso8601String().split('T')[0]}'),
          content:SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,

            children: [
              if (selectedDateExpenses.isEmpty)
                Image.asset(
                  'assets/Zzz.png', // ใส่ path รูปภาพที่คุณต้องการแสดง
                  width: 100, // กำหนดความกว้างของรูปภาพ
                  height: 100, // กำหนดความสูงของรูปภาพ
                  fit: BoxFit.cover, // ปรับขนาดให้พอดีกับพื้นที่
                )
              else
              ...selectedDateExpenses.map((expense) {
        String imagetype='assets/beauty.png';

        // เลือกภาพที่เหมาะสมตามประเภท
        if (expense['incomeexpense'] == 0) {
        imagetype = 'assets/wallet_color.png'; // สำหรับ income
        } else if (expense['type'] == 'Food' && expense['incomeexpense'] == 1) {
        imagetype = 'assets/food.png'; // สำหรับ expense ประเภท Food
        } else if (expense['type'] == 'Travel expenses'&& expense['incomeexpense'] == 1) {
        imagetype = 'assets/travel_expenses.png';
        } else if (expense['type'] == 'Water bill'&& expense['incomeexpense'] == 1) {
        imagetype = 'assets/water.png';
        } else if (expense['type'] == 'Electricity bill'&& expense['incomeexpense'] == 1) {
        imagetype = 'assets/electricity_bill.png';
        } else if (expense['type'] == 'House cost'&& expense['incomeexpense'] == 1) {
        imagetype = 'assets/house.png';
        } else if (expense['type'] == 'Car fare'&& expense['incomeexpense'] == 1) {
        imagetype = 'assets/car.png';
        } else if (expense['type'] == 'Gasoline cost'&& expense['incomeexpense'] == 1) {
        imagetype = 'assets/gasoline_cost.png';
        } else if (expense['type'] == 'Medical expenses'&& expense['incomeexpense'] == 1) {
        imagetype = 'assets/medical.png';
        }


                return Row(
                  children: [
                    // รูปภาพทางซ้าย
                    Image.asset(
                      imagetype, // แสดงรูปตามประเภท
                      height: 50,
                      width: 50,
                    ),
                    SizedBox(width: 10), // ระยะห่างระหว่างรูปกับข้อมูล

                    // ข้อมูลทางขวา
                    Expanded(
                      child: ListTile(
                        title: Text(
                          expense['incomeexpense'].toString() == '0'
                              ? 'Income'  // ถ้า incomeexpense เป็น 0 จะแสดง "Income"
                              : '${expense['type']}',  // ถ้าเป็น 1 จะแสดง type ปกติ
                        ),
                subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start, // จัดเรียงข้อความซ้าย
                children: [
                Text('Amount: ${expense['amount']}'),
                Text('Memo: ${expense['memo']}'), // หรือข้อมูลเพิ่มเติมอื่น ๆ
                ],
                      ),
                    ),
                ),
                ],
                );
              }).toList(),
            ],
          ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // ปิด Dialog
              },
              child: Text('ปิด'),
            ),
          ],
        );
      },
    );
  }



  // ฟังก์ชันดึงข้อมูลสถานะการใช้จ่ายตามวันที่
  Future<void> _fetchcalendarDay(String date) async {
    print("Fetching data for date: $date");

    // สร้างวันที่เริ่มต้นและสิ้นสุดสำหรับการค้นหา
    DateTime startDate = DateTime.parse(date);
    print('startDate');
    print(startDate);
    print('date *********************');
    print(date);
    DateTime endDate = DateTime(startDate.year, startDate.month, startDate.day + 1); // วันถัดไป

    final List<Map<String, dynamic>> result = await DatabaseManagement.instance.rawQuery(
      '''
    SELECT *
    
      FROM Transactions
      JOIN Type_transaction ON Transactions.ID_type_transaction = Type_transaction.ID_type_transaction
      WHERE DATE(Transactions.date_user) = '${startDate.year}-${startDate.month.toString().padLeft(2,'0')}-${startDate.day.toString().padLeft(2,'0')}' 
      
      ''',

    );
    print("__________________");
    print('${startDate.year}-${startDate.month}-${startDate.day}' );
    print(result); // ตรวจสอบผลลัพธ์ของการคิวรี

    // อัพเดท UI
    setState(() {
      selectedDateExpenses = result.map((data) {
        return {
          'type': data['type_transaction'] ?? '-',
          'amount': data['amount_transaction'] ?? 0.0,
          'memo': data['memo_transaction'] ?? '-',
          'ID':data['ID_type_transaction'] ?? '-',
          'incomeexpense':data['type_expense'] ?? '-',
        };
      }).toList();
    });
  }




  Future<void> _fetchPieChartDataDay() async {
    final List<Map<String, dynamic>> result = await DatabaseManagement.instance.rawQuery(
        '''
    SELECT Transactions.ID_type_transaction, 
           SUM(Transactions.amount_transaction) AS total_amount_Pie, 
           Type_transaction.type_transaction
    FROM Transactions
    JOIN Type_transaction ON Transactions.ID_type_transaction = Type_transaction.ID_type_transaction
    WHERE Transactions.type_expense = 1
    AND DATE(Transactions.date_user) = DATE("now","localtime")  -- เปลี่ยนเป็นกรองตามวันปัจจุบัน
    GROUP BY Transactions.ID_type_transaction
    '''
    );
    // double total = 0.0;
    // for(var r in result){
    //   total += r['total_amount_Pie'] as double;
    // }
    //print(total);
    print(result.isEmpty);
    print('Result from database day: $result'); // ตรวจสอบผลลัพธ์ที่ได้
    setState(() {
      pieChartSections = result.map((data) {
        final color = typeToColor[data['type_transaction']] ?? Colors.grey;
       // final percentage = (data['total_amount_Pie'].toDouble()/ total * 100).toStringAsFixed(1);
        return PieChartSectionData(
          value: data['total_amount_Pie'].toDouble(),
          title: data['type_transaction'],//+' ${percentage}%',
          color: color,
          radius: 50,
          showTitle: false,
        );
      }).toList();
    });
  }

  Future<void> _fetchPieChartDataMonth() async {
    final List<Map<String, dynamic>> result = await DatabaseManagement.instance.rawQuery(
        '''
      SELECT Transactions.ID_type_transaction, SUM(Transactions.amount_transaction) AS total_amount_Pie, Type_transaction.type_transaction
      FROM Transactions
      JOIN Type_transaction ON Transactions.ID_type_transaction = Type_transaction.ID_type_transaction
      WHERE Transactions.type_expense = 1
      AND strftime('%Y-%m', Transactions.date_user) = strftime('%Y-%m', 'now',"localtime")
      GROUP BY Transactions.ID_type_transaction
    ''');
    print('Result from database month: $result');
    setState(() {
      pieChartSections = result.map((data) {
        final color = typeToColor[data['type_transaction']] ?? Colors.grey;
        return PieChartSectionData(
          value: data['total_amount_Pie'].toDouble(),
          title: data['type_transaction'],
          color: color,
          radius: 50,
          showTitle: false,
        );
      }).toList();
    });
  }

  Future<void> _fetchPieChartDataYear() async {
    final List<Map<String, dynamic>> result = await DatabaseManagement.instance.rawQuery(
        '''
      SELECT Transactions.ID_type_transaction, SUM(Transactions.amount_transaction) AS total_amount_Pie, Type_transaction.type_transaction
      FROM Transactions
      JOIN Type_transaction ON Transactions.ID_type_transaction = Type_transaction.ID_type_transaction
      WHERE Transactions.type_expense = 1
      AND strftime('%Y', Transactions.date_user) = strftime('%Y', 'now','localtime')
      GROUP BY Transactions.ID_type_transaction
    ''');
    print('Result from year  : $result');
    setState(() {
      pieChartSections = result.map((data) {
        final color = typeToColor[data['type_transaction']] ?? Colors.grey;
        return PieChartSectionData(
          value: data['total_amount_Pie'].toDouble(),
          title: data['type_transaction'],
          color: color,
          radius: 50,
          showTitle: false,
        );
      }).toList();
    });
  }

  Future<void> _fetchStatusDay() async {
    final List<Map<String, dynamic>> result = await DatabaseManagement.instance.rawQuery(
        '''
    SELECT Transactions.ID_type_transaction, SUM(Transactions.amount_transaction) AS total_expense, Type_transaction.type_transaction
    FROM Transactions
    JOIN Type_transaction ON Transactions.ID_type_transaction = Type_transaction.ID_type_transaction
    WHERE Transactions.type_expense = 1
    AND DATE(Transactions.date_user) = DATE("now","localtime")
    GROUP BY Transactions.ID_type_transaction
    '''
    );
    print('Status for today: $result');
    setState(() {
      statusExpenses = result.map((data) {
        return {
          'type': data['type_transaction'],
          'amount': data['total_expense'],

        };
      }).toList();

    });
  }

  Future<void> _fetchStatusMonth() async {
    final List<Map<String, dynamic>> result = await DatabaseManagement.instance.rawQuery(
        '''
    SELECT Transactions.ID_type_transaction, SUM(Transactions.amount_transaction) AS total_expense, Type_transaction.type_transaction
    FROM Transactions
    JOIN Type_transaction ON Transactions.ID_type_transaction = Type_transaction.ID_type_transaction
    WHERE Transactions.type_expense = 1
    AND strftime('%Y-%m', Transactions.date_user) = strftime('%Y-%m', 'now','localtime')  -- ดึงข้อมูลตามเดือนปัจจุบัน
    GROUP BY Transactions.ID_type_transaction
    '''
    );
    // ตรวจสอบผลลัพธ์ที่ได้จากฐานข้อมูล
    print('Status for today: $result');

    // กำหนดค่าแสดงผล หรือ อัพเดท state ที่ต้องการแสดงบน UI
    setState(() {
      // สมมติว่าคุณมีตัวแปรที่จะแสดงผล เช่น `totalExpenses`
      statusExpenses = result.map((data) {
        return {
          'type': data['type_transaction'],
          'amount': data['total_expense'],

        };
      }).toList();

    });
  }

  Future<void> _fetchStatusYear() async {
    final List<Map<String, dynamic>> result = await DatabaseManagement.instance.rawQuery(
        '''
    SELECT Transactions.ID_type_transaction, SUM(Transactions.amount_transaction) AS total_expense, Type_transaction.type_transaction
    FROM Transactions
    JOIN Type_transaction ON Transactions.ID_type_transaction = Type_transaction.ID_type_transaction
    WHERE Transactions.type_expense = 1
    AND strftime('%Y', Transactions.date_user) = strftime('%Y', 'now','localtime')  -- ดึงข้อมูลตามปีปัจจุบัน
    GROUP BY Transactions.ID_type_transaction
    '''
    );
    // ตรวจสอบผลลัพธ์ที่ได้จากฐานข้อมูล
    print('Status for this year: $result');

    // อัพเดทข้อมูลใน UI
    setState(() {
      statusExpenses = result.map((data) {
        return {
          'type': data['type_transaction'],
          'amount': data['total_expense'],
        };
      }).toList();
    });
  }

  // ฟังก์ชันดึงข้อมูล Bar Chart จากฐานข้อมูล
  Future<void> _fetchBarDataDay() async {
    final List<Map<String, dynamic>> incomeResult = await DatabaseManagement.instance.rawQuery(
      'SELECT SUM(amount_transaction) AS total_income FROM transactions WHERE type_expense = 0 AND DATE(date_user) = DATE("now","localtime")',
    );

    final List<Map<String, dynamic>> expenseResult = await DatabaseManagement.instance.rawQuery(
      'SELECT SUM(amount_transaction) AS total_expense FROM transactions WHERE type_expense = 1 AND DATE(date_user) = DATE("now","localtime")',
    );

    setState(() {
      totalIncome = incomeResult.isNotEmpty && incomeResult[0]['total_income'] != null
          ? incomeResult[0]['total_income'].toDouble()
          : 0.0;
      totalExpense = expenseResult.isNotEmpty && expenseResult[0]['total_expense'] != null
          ? expenseResult[0]['total_expense'].toDouble()
          : 0.0;
    });
  }

  Future<void> _fetchBarDataMonth() async {
    final List<Map<String, dynamic>> incomeResult = await DatabaseManagement.instance.rawQuery(
        'SELECT SUM(amount_transaction) AS total_income FROM transactions WHERE type_expense = 0 AND strftime("%m", date_user) = strftime("%m", "now") AND strftime("%Y", date_user) = strftime("%Y", "now","localtime")'
    );

    final List<Map<String, dynamic>> expenseResult = await DatabaseManagement.instance.rawQuery(
        'SELECT SUM(amount_transaction) AS total_expense FROM transactions WHERE type_expense = 1 AND strftime("%m", date_user) = strftime("%m", "now") AND strftime("%Y", date_user) = strftime("%Y", "now","localtime")'
    );

    setState(() {
      totalIncome = incomeResult.isNotEmpty && incomeResult[0]['total_income'] != null
          ? incomeResult[0]['total_income'].toDouble()
          : 0.0;
      totalExpense = expenseResult.isNotEmpty && expenseResult[0]['total_expense'] != null
          ? expenseResult[0]['total_expense'].toDouble()
          : 0.0;
    });
  }

  Future<void> _fetchBarDataYear() async {
    final List<Map<String, dynamic>> incomeResult = await DatabaseManagement.instance.rawQuery(
        'SELECT SUM(amount_transaction) AS total_income '
            'FROM transactions '
            'WHERE type_expense = 0 '
            'AND strftime("%Y", date_user) = strftime("%Y", "now","localtime")'  // เงื่อนไขสำหรับดึงข้อมูลเฉพาะปีปัจจุบัน
    );

    final List<Map<String, dynamic>> expenseResult = await DatabaseManagement.instance.rawQuery(
        'SELECT SUM(amount_transaction) AS total_expense '
            'FROM transactions '
            'WHERE type_expense = 1 '
            'AND strftime("%Y", date_user) = strftime("%Y", "now","localtime")'  // เงื่อนไขสำหรับดึงข้อมูลเฉพาะปีปัจจุบัน
    );

    setState(() {
      totalIncome = incomeResult.isNotEmpty && incomeResult[0]['total_income'] != null
          ? incomeResult[0]['total_income'].toDouble()
          : 0.0;
      totalExpense = expenseResult.isNotEmpty && expenseResult[0]['total_expense'] != null
          ? expenseResult[0]['total_expense'].toDouble()
          : 0.0;
    });
  }

  // ฟังก์ชันแสดงกราฟ Pie Chart และดึงข้อมูล
  void _showFinancialPieChart(BuildContext context) {
    setState(() {
      if (selectedButton == 'Day') {
        _fetchPieChartDataDay();
      } else if (selectedButton == 'Month') {
        _fetchPieChartDataMonth();
      } else if (selectedButton == 'Year') {
        _fetchPieChartDataYear();
      }
    });
  }

  // ฟังก์ชันแสดง Status Expense
  void _showStatus_Expense(BuildContext context) {
    setState(() {
    if (selectedButton == 'Day') {
      _fetchStatusDay(); // ดึงข้อมูลจากฐานข้อมูลเมื่อเลือก Day
    } else if (selectedButton == 'Month') {
      _fetchStatusMonth(); // ดึงข้อมูลจากฐานข้อมูลเมื่อเลือก Month
    } else if (selectedButton == 'Year') {
      _fetchStatusYear(); // ดึงข้อมูลจากฐานข้อมูลเมื่อเลือก Year
    }
    });
  }

  // ฟังก์ชันแสดง Bar Chart และดึงข้อมูล
  void _showFinancialBarChart(BuildContext context) {
    if (selectedButton == 'Day') {
      _fetchBarDataDay(); // ดึงข้อมูลจากฐานข้อมูลเมื่อเลือก Day
    } else if (selectedButton == 'Month') {
      _fetchBarDataMonth(); // ดึงข้อมูลจากฐานข้อมูลเมื่อเลือก Month
    } else if (selectedButton == 'Year') {
      _fetchBarDataYear(); // ดึงข้อมูลจากฐานข้อมูลเมื่อเลือก Year
    }
  }

}
