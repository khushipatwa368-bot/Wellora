import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BmiPage extends StatefulWidget {
  const BmiPage({super.key});

  @override
  State<BmiPage> createState() => _BmiPageState();
}

class _BmiPageState extends State<BmiPage> {
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  double? _bmiResult;
  String _bmiCategory = '';
  Color _categoryColor = Colors.teal;
  String _healthRecommendation = '';

  @override
  void initState() {
    super.initState();
    _loadBmiData();
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  // ============================================================
  // LOAD SAVED DATA FROM SHAREDPREFERENCES (Safe Casting)
  // ============================================================
  Future<void> _loadBmiData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final heightVal = prefs.get('bmi_height');
      final weightVal = prefs.get('bmi_weight');
      final double? savedBmi = prefs.getDouble('bmi_result');

      if (!mounted) return;

      setState(() {
        _heightController.text = heightVal != null ? heightVal.toString() : '';
        _weightController.text = weightVal != null ? weightVal.toString() : '';

        if (savedBmi != null) {
          _bmiResult = savedBmi;
          _bmiCategory = prefs.getString('bmi_category') ?? '';
          _healthRecommendation = prefs.getString('bmi_recommendation') ?? '';

          final int? colorValue = prefs.getInt('bmi_color_value');
          if (colorValue != null) {
            _categoryColor = Color(colorValue);
          }
        }
      });
    } catch (e) {
      debugPrint('Error loading BMI data: $e');
    }
  }

  // ============================================================
  // SAVE DATA TO SHAREDPREFERENCES
  // ============================================================
  Future<void> _saveBmiData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('bmi_height', _heightController.text.trim());
      await prefs.setString('bmi_weight', _weightController.text.trim());

      if (_bmiResult != null) {
        await prefs.setDouble('bmi_result', _bmiResult!);
        await prefs.setString('bmi_category', _bmiCategory);
        await prefs.setString('bmi_recommendation', _healthRecommendation);
        // Using .value for universal cross-platform color value persistence
        await prefs.setInt('bmi_color_value', _categoryColor.value);
      }
    } catch (e) {
      debugPrint('Error saving BMI data: $e');
    }
  }

  // ============================================================
  // BMI CALCULATION & STATE UPDATE
  // ============================================================
  Future<void> _calculateBMI() async {
    final double? heightCm = double.tryParse(_heightController.text);
    final double? weightKg = double.tryParse(_weightController.text);

    if (heightCm != null && weightKg != null && heightCm > 0 && weightKg > 0) {
      final double heightM = heightCm / 100;
      final double bmi = weightKg / (heightM * heightM);

      setState(() {
        _bmiResult = bmi;
        if (bmi < 18.5) {
          _bmiCategory = 'Underweight';
          _categoryColor = Colors.orange;
          _healthRecommendation =
          'Focus on nutrient-dense meals like sprouts, nuts, paneer, and rich smoothies for sustained study energy.';
        } else if (bmi >= 18.5 && bmi < 24.9) {
          _bmiCategory = 'Optimal / Normal';
          _categoryColor = Colors.green;
          _healthRecommendation =
          'Great job! Maintain your balanced canteen choices and 15-minute daily active walks.';
        } else if (bmi >= 25 && bmi < 29.9) {
          _bmiCategory = 'Overweight';
          _categoryColor = Colors.amber.shade800;
          _healthRecommendation =
          'Swap deep-fried canteen snacks with boiled eggs, fruit chat, or idli, and try library stretch breaks.';
        } else {
          _bmiCategory = 'Obese';
          _categoryColor = Colors.red;
          _healthRecommendation =
          'Consider consulting a college health counselor to craft a sustainable, stress-free fitness plan.';
        }
      });

      await _saveBmiData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student BMI Analytics'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00897B), Color(0xFF4DB6AC)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.teal.withAlpha(76),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Row(
                children: [
                  Icon(Icons.health_and_safety_rounded, size: 48, color: Colors.white),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Track Your Fitness Level',
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Ideal health metrics foster better academic concentration.',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _heightController,
                    keyboardType: TextInputType.number,
                    onChanged: (_) async {
                      await _saveBmiData();
                    },
                    decoration: InputDecoration(
                      labelText: 'Height (cm)',
                      prefixIcon: const Icon(Icons.height_rounded),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: TextField(
                    controller: _weightController,
                    keyboardType: TextInputType.number,
                    onChanged: (_) async {
                      await _saveBmiData();
                    },
                    decoration: InputDecoration(
                      labelText: 'Weight (kg)',
                      prefixIcon: const Icon(Icons.monitor_weight_outlined),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00897B),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                ),
                onPressed: _calculateBMI,
                icon: const Icon(Icons.calculate_rounded, color: Colors.white),
                label: const Text(
                  'Calculate BMI Result',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            if (_bmiResult != null) ...[
              const SizedBox(height: 28),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _categoryColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _categoryColor.withAlpha(76)),
                ),
                child: Column(
                  children: [
                    Text(
                      'YOUR BMI SCORE',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _bmiResult!.toStringAsFixed(1),
                      style: TextStyle(fontSize: 44, fontWeight: FontWeight.w900, color: _categoryColor),
                    ),
                    Chip(
                      label: Text(
                        _bmiCategory,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      backgroundColor: _categoryColor,
                    ),
                    const Divider(height: 28),
                    Row(
                      children: [
                        const Icon(Icons.lightbulb_outline_rounded, color: Colors.amber),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _healthRecommendation,
                            style: TextStyle(fontSize: 13, color: Colors.grey.shade800, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}