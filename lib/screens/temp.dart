import 'package:flutter/material.dart';

class TemperatureConverterScreen extends StatefulWidget {
  @override
  _TemperatureConverterScreenState createState() => _TemperatureConverterScreenState();
}

class _TemperatureConverterScreenState extends State<TemperatureConverterScreen> {
  final TextEditingController _celsiusController = TextEditingController();
  String _result = "";

  void _convert() {
    if (_celsiusController.text.isEmpty) return;

    double celsius = double.tryParse(_celsiusController.text) ?? 0;
    double fahrenheit = celsius * 9 / 5 + 32;

    setState(() {
      _result = "$celsius °C = ${fahrenheit.toStringAsFixed(2)} °F";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Temperature Converter"),
        backgroundColor: Color(0xFF06b6d4),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Nhập nhiệt độ (°C):", style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            TextField(
              controller: _celsiusController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Ví dụ: 37",
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _convert,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF06b6d4),
              ),
              child: Text("Đổi sang °F"),
            ),
            SizedBox(height: 20),
            Text(
              _result,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),
    );
  }
}
