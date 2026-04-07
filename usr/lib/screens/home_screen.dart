import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _employeeId;
  bool _isCheckedIn = false;
  DateTime? _checkInTime;
  DateTime? _checkOutTime;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _employeeId = prefs.getString('employeeId');
      _isCheckedIn = prefs.getBool('isCheckedIn') ?? false;
      final checkInString = prefs.getString('checkInTime');
      if (checkInString != null) {
        _checkInTime = DateTime.parse(checkInString);
      }
      final checkOutString = prefs.getString('checkOutTime');
      if (checkOutString != null) {
        _checkOutTime = DateTime.parse(checkOutString);
      }
    });
  }

  Future<void> _checkIn() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    await prefs.setBool('isCheckedIn', true);
    await prefs.setString('checkInTime', now.toIso8601String());
    setState(() {
      _isCheckedIn = true;
      _checkInTime = now;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Checked in at ${now.hour}:${now.minute}')),
    );
  }

  Future<void> _checkOut() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    await prefs.setBool('isCheckedIn', false);
    await prefs.setString('checkOutTime', now.toIso8601String());
    setState(() {
      _isCheckedIn = false;
      _checkOutTime = now;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Checked out at ${now.hour}:${now.minute}')),
    );
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Attendance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome, Employee ID: $_employeeId'),
            const SizedBox(height: 24),
            if (_isCheckedIn)
              ElevatedButton(
                onPressed: _checkOut,
                child: const Text('Check Out'),
              )
            else
              ElevatedButton(
                onPressed: _checkIn,
                child: const Text('Check In'),
              ),
            const SizedBox(height: 24),
            if (_checkInTime != null)
              Text('Check-in Time: ${_checkInTime!.hour}:${_checkInTime!.minute}'),
            if (_checkOutTime != null)
              Text('Check-out Time: ${_checkOutTime!.hour}:${_checkOutTime!.minute}'),
          ],
        ),
      ),
    );
  }
}