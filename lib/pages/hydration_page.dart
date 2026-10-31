import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HydrationPage extends StatefulWidget {
  const HydrationPage({super.key});

  @override
  State<HydrationPage> createState() => _HydrationPageState();
}

class _HydrationPageState extends State<HydrationPage> {
  int _drunkGlasses = 4;
  final int _targetGlasses = 8;
  int _totalMl = 1000; // 250ml per glass default
  bool _remindersEnabled = true;
  String _selectedBeverage = 'Water';

  final List<Map<String, dynamic>> _beverages = [
    {'name': 'Water', 'icon': Icons.water_drop_rounded, 'color': Colors.blue, 'ml': 250},
    {'name': 'Coconut Water', 'icon': Icons.nature_people_rounded, 'color': Colors.green, 'ml': 200},
    {'name': 'Green Tea', 'icon': Icons.emoji_food_beverage_rounded, 'color': Colors.amber, 'ml': 150},
    {'name': 'Chaas / Buttermilk', 'icon': Icons.local_drink_rounded, 'color': Colors.teal, 'ml': 200},
  ];

  List<Map<String, String>> _hydrationLogs = [
    {'time': '08:30 AM', 'beverage': 'Water (250 ml)'},
    {'time': '10:45 AM', 'beverage': 'Green Tea (150 ml)'},
    {'time': '01:15 PM', 'beverage': 'Chaas / Buttermilk (200 ml)'},
    {'time': '03:30 PM', 'beverage': 'Water (250 ml)'},
  ];

  @override
  void initState() {
    super.initState();
    _loadHydrationData();
  }

  // ============================================================
  // LOAD DATA FROM SHAREDPREFERENCES
  // ============================================================
  Future<void> _loadHydrationData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final int? savedTotalMl = prefs.getInt('hydration_total_ml');
      final bool? savedReminders = prefs.getBool('hydration_reminders_enabled');
      final String? savedBev = prefs.getString('hydration_selected_beverage');
      final String? logsJson = prefs.getString('hydration_logs');

      if (!mounted) return;

      setState(() {
        if (savedTotalMl != null) {
          _totalMl = savedTotalMl;
          _drunkGlasses = (_totalMl / 250).floor();
        }
        if (savedReminders != null) {
          _remindersEnabled = savedReminders;
        }
        if (savedBev != null) {
          _selectedBeverage = savedBev;
        }

        if (logsJson != null) {
          final List<dynamic> decodedList = jsonDecode(logsJson);
          _hydrationLogs = decodedList.map((item) {
            final map = Map<String, dynamic>.from(item as Map);
            return {
              'time': map['time']?.toString() ?? '',
              'beverage': map['beverage']?.toString() ?? '',
            };
          }).toList();
        }
      });
    } catch (e) {
      debugPrint('Error loading hydration data: $e');
    }
  }

  // ============================================================
  // SAVE DATA TO SHAREDPREFERENCES
  // ============================================================
  Future<void> _saveHydrationData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('hydration_total_ml', _totalMl);
      await prefs.setBool('hydration_reminders_enabled', _remindersEnabled);
      await prefs.setString('hydration_selected_beverage', _selectedBeverage);
      await prefs.setString('hydration_logs', jsonEncode(_hydrationLogs));
    } catch (e) {
      debugPrint('Error saving hydration data: $e');
    }
  }

  Future<void> _addFluid(int ml, String name) async {
    setState(() {
      _totalMl += ml;
      _drunkGlasses = (_totalMl / 250).floor();
      _hydrationLogs.insert(0, {
        'time': 'Just Now',
        'beverage': '$name ($ml ml)',
      });
    });
    await _saveHydrationData();
  }

  Future<void> _resetTracker() async {
    setState(() {
      _drunkGlasses = 0;
      _totalMl = 0;
      _hydrationLogs.clear();
    });
    await _saveHydrationData();
  }

  @override
  Widget build(BuildContext context) {
    double progress = (_totalMl / (_targetGlasses * 250)).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Interactive Hydration Tracker'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Reset Tracker',
            onPressed: _resetTracker,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Dynamic Progress Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade800, Colors.cyan.shade500],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withAlpha(76),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Current Fluid Intake', style: TextStyle(color: Colors.white70, fontSize: 13)),
                          const SizedBox(height: 4),
                          Text(
                            '$_totalMl / ${_targetGlasses * 250} ml',
                            style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Approx. $_drunkGlasses of $_targetGlasses Glasses',
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.white.withAlpha(51),
                        child: const Icon(Icons.water_drop_rounded, size: 36, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.white24,
                      color: Colors.white,
                      minHeight: 10,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${(progress * 100).toInt()}% Goal Reached',
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 2. Interactive Beverage Quick Add Selector
            const Text(
              '🥤 Quick Add Beverage',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _beverages.map((bev) {
                  final String bevName = bev['name'] as String;
                  final Color bevColor = bev['color'] as Color;
                  final int bevMl = bev['ml'] as int;
                  final IconData bevIcon = bev['icon'] as IconData;
                  final bool isSelected = _selectedBeverage == bevName;

                  return Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () async {
                        setState(() {
                          _selectedBeverage = bevName;
                        });
                        await _addFluid(bevMl, bevName);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? bevColor.withAlpha(38) : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? bevColor : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(bevIcon, color: bevColor, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              '+$bevMl ml $bevName',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? bevColor : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),

            // 3. Interactive Incrementor Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade50,
                      foregroundColor: Colors.red.shade700,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    onPressed: () async {
                      if (_totalMl >= 250) {
                        setState(() {
                          _totalMl -= 250;
                          _drunkGlasses = (_totalMl / 250).floor();
                        });
                        await _saveHydrationData();
                      }
                    },
                    icon: const Icon(Icons.remove_circle_outline_rounded),
                    label: const Text('Subtract Glass', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 2,
                    ),
                    onPressed: () async {
                      await _addFluid(250, 'Glass Water');
                    },
                    icon: const Icon(Icons.add_circle_outline_rounded),
                    label: const Text('Drink Water', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 4. Interactive Lecture Water Reminder Switch
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                title: const Text('Smart Lecture Alerts', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: const Text('Get gentle hydration nudges between college lectures'),
                value: _remindersEnabled,
                activeThumbColor: Colors.blue,
                onChanged: (val) async {
                  setState(() => _remindersEnabled = val);
                  await _saveHydrationData();
                },
              ),
            ),
            const SizedBox(height: 20),

            // Live Hydration History Logs
            const Text(
              '⏱️ Today\'s Hydration Log',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ..._hydrationLogs.map((log) => Card(
              elevation: 1,
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                dense: true,
                leading: const Icon(Icons.water_drop_outlined, color: Colors.blue),
                title: Text(log['beverage']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                trailing: Text(log['time']!, style: const TextStyle(color: Colors.grey, fontSize: 11)),
              ),
            )),
          ],
        ),
      ),
    );
  }
}