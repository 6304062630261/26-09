import 'package:flutter/material.dart';
import 'package:vongola/database/db_manage.dart';
import 'package:intl/intl.dart'; // นำเข้า intl package

class Page3 extends StatefulWidget {
  @override
  _Page3State createState() => _Page3State();
}

class _Page3State extends State<Page3> {
  List<Map<String, dynamic>> income_transactions = []; // ตัวแปรสำหรับเก็บข้อมูล Transactions
  double totalIncome = 0; // ตัวแปรสำหรับเก็บค่ารวมรายได้

  @override
  void initState() {
    super.initState();
    _fetchTotal_income(); // เรียกฟังก์ชันดึงข้อมูลเมื่อเริ่มต้น
  }

  Future<void> _fetchTotal_income() async {
    // คิวรีเพื่อดึงข้อมูลรายได้รวม
    final List<Map<String, dynamic>> incomeResult = await DatabaseManagement.instance.rawQuery(
      'SELECT SUM(amount_transaction) AS total_income FROM transactions WHERE type_expense = 0',
    );

    // เช็คว่ามีข้อมูลไหม
    if (incomeResult.isNotEmpty && incomeResult[0]['total_income'] != null) {
      totalIncome = incomeResult[0]['total_income'];
    }

    // เรียกฟังก์ชันเพื่อดึงข้อมูลการทำธุรกรรม
    _fetchStatus_income();
  }

  Future<void> _fetchStatus_income() async {
    // คิวรีเพื่อดึงข้อมูลธุรกรรมทั้งหมด
    final List<Map<String, dynamic>> dailyTransactions = await DatabaseManagement.instance.rawQuery(
      'SELECT * FROM transactions WHERE type_expense = 0',
    );

    setState(() {
      income_transactions = dailyTransactions;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Page 3'),
      ),
      body: SingleChildScrollView( // ใช้ SingleChildScrollView
        child: Column(
          children: [
            // แสดงรูปภาพที่กึ่งกลางด้านบนพร้อมพื้นหลังสีเหลืองอ่อน
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: Colors.yellow[100], // พื้นหลังสีเหลืองอ่อน
              ),
              padding: const EdgeInsets.symmetric(horizontal: 80.0), // เพิ่ม padding
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center, // จัดให้อยู่กลาง
                children: [
                  // รูปภาพ
                  Image.asset(
                    'assets/wallet_color.png',
                    width: 200,
                    height: 200,
                  ),
                  SizedBox(height: 10), // เว้นที่ระหว่างรูปภาพกับข้อความ
                  // ข้อความ Total Income
                  RichText(
                    textAlign: TextAlign.center, // จัดให้อยู่ตรงกลาง
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Total Income\n', // Total Income บรรทัดบน
                          style: TextStyle(
                            fontSize: 18, // ขนาดตัวอักษรเล็กกว่า
                            fontWeight: FontWeight.bold, // ตัวหนา
                            color: Colors.black, // สีดำ
                          ),
                        ),
                        TextSpan(
                          text: '$totalIncome'' ฿', // จำนวนเงินบรรทัดล่าง
                          style: TextStyle(
                            fontSize: 30, // ขนาดตัวอักษรใหญ่กว่า
                            fontWeight: FontWeight.bold, // ตัวหนา
                            color: Colors.green, // สีเขียว
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20), // เว้นที่ระหว่าง Total Income และข้อมูลธุรกรรม

            // แสดงข้อมูล Transactions
            ListView.builder(
              physics: NeverScrollableScrollPhysics(), // ปิดการเลื่อนของ ListView
              shrinkWrap: true, // ใช้ขนาดที่จำเป็น
              itemCount: income_transactions.length,
              itemBuilder: (context, index) {
                final transaction = income_transactions[index];
                // แปลงวันที่เป็นรูปแบบที่ต้องการ
                final DateTime date = DateTime.parse(transaction['date_user']);
                final String formattedDate = DateFormat('dd/MM/yyyy').format(date);
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0), // เพิ่มระยะห่างซ้ายขวา 20
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10.0), // เพิ่มระยะห่างด้านล่าง
                    padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0), // เพิ่มระยะห่างภายใน
                    decoration: BoxDecoration(
                      color: Colors.green[100], // สีเขียวอ่อน
                      borderRadius: BorderRadius.circular(8), // มุมโค้ง
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.zero, // ปิดการ padding เริ่มต้นของ ListTile
                      leading: Image.asset(
                        'assets/money.png', // ใช้รูปภาพ money.png
                        width: 60, // กำหนดความกว้าง
                        height: 60, // กำหนดความสูง
                        fit: BoxFit.cover, // ปรับขนาดให้พอดีกับกรอบ
                      ),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween, // จัดให้มีพื้นที่ระหว่าง
                        children: [
                          // ข้อมูลวันที่และ Memo
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start, // จัดเรียงข้อความซ้าย
                            children: [
                              Text('Date: $formattedDate'), // แสดงวันที่ที่กรองแล้ว
                              Text('Memo: ${transaction['memo_transaction']}', style: TextStyle(fontSize: 14)), // หรือข้อมูลเพิ่มเติมอื่น ๆ
                            ],
                          ),
                          // จำนวนเงิน
                          Text(
                            '+ ${transaction['amount_transaction']}',
                            style: TextStyle(
                              color: Colors.green, // สีเขียว
                              fontSize: 18, // ขนาดตัวอักษรใหญ่กว่าฝั่งซ้าย
                              fontWeight: FontWeight.bold, // ตัวหนา
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
