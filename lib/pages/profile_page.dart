import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  final String userName;
  final String userEmail;

  const ProfilePage({
    super.key,
    required this.userName,
    required this.userEmail,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  double? _bmi;
  String _bmiCategory = '';
  String _currentUserName = '';
  String _currentUserEmail = '';

  @override
  void initState() {
    super.initState();
    _currentUserName = widget.userName;
    _currentUserEmail = widget.userEmail;
    _loadUserData();
  }

  @override
  void dispose() {
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Agar widget se empty naam mila ho toh local storage se uthayein
    String storedName = prefs.getString('user_name') ?? widget.userName;
    String storedEmail = prefs.getString('user_email') ?? widget.userEmail;

    setState(() {
      if (storedName.isNotEmpty) {
        _currentUserName = storedName;
      }
      if (storedEmail.isNotEmpty) {
        _currentUserEmail = storedEmail;
      }

      _ageController.text = prefs.getString('user_age') ?? '';
      _heightController.text = prefs.getString('user_height') ?? '';
      _weightController.text = prefs.getString('user_weight') ?? '';
      _calculateBmi();
    });
  }

  void _calculateBmi() {
    final double? heightCm = double.tryParse(_heightController.text);
    final double? weightKg = double.tryParse(_weightController.text);

    if (heightCm != null && weightKg != null && heightCm > 0 && weightKg > 0) {
      final double heightM = heightCm / 100;
      final double bmiValue = weightKg / (heightM * heightM);

      setState(() {
        _bmi = bmiValue;
        if (bmiValue < 18.5) {
          _bmiCategory = 'Underweight';
        } else if (bmiValue < 25) {
          _bmiCategory = 'Normal Weight';
        } else if (bmiValue < 30) {
          _bmiCategory = 'Overweight';
        } else {
          _bmiCategory = 'Obese';
        }
      });
    } else {
      setState(() {
        _bmi = null;
        _bmiCategory = '';
      });
    }
  }

  void _showEditMetricsDialog() {
    final GlobalKey<FormState> dialogFormKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Edit Health Profile',
            style: TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.bold),
          ),
          content: Form(
            key: dialogFormKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Age (Years)',
                      prefixIcon: Icon(Icons.cake_outlined, color: Color(0xFF4CAF50)),
                    ),
                    validator: (val) => val == null || val.isEmpty ? 'Enter age' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _heightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Height (cm)',
                      prefixIcon: Icon(Icons.height, color: Color(0xFF4CAF50)),
                    ),
                    validator: (val) => val == null || val.isEmpty ? 'Enter height in cm' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _weightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Weight (kg)',
                      prefixIcon: Icon(Icons.monitor_weight_outlined, color: Color(0xFF4CAF50)),
                    ),
                    validator: (val) => val == null || val.isEmpty ? 'Enter weight in kg' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                if (dialogFormKey.currentState!.validate()) {
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  await prefs.setString('user_age', _ageController.text.trim());
                  await prefs.setString('user_height', _heightController.text.trim());
                  await prefs.setString('user_weight', _weightController.text.trim());

                  setState(() {
                    _calculateBmi();
                  });

                  if (!context.mounted) return;
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Health details saved successfully!'),
                      backgroundColor: Color(0xFF4CAF50),
                    ),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Hum sirf login session ko false kar rahe hain, data clear nahi kar rahe taaki info bani rahe
    await prefs.setBool('is_logged_in', false);

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBF9),
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color(0xFFE8F5E9),
        foregroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_note, size: 28),
            onPressed: _showEditMetricsDialog,
            tooltip: 'Edit Details',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 10),
              CircleAvatar(
                radius: 50,
                backgroundColor: const Color(0xFF4CAF50),
                child: Text(
                  _currentUserName.isNotEmpty ? _currentUserName[0].toUpperCase() : 'U',
                  style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _currentUserName,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
              ),
              const SizedBox(height: 4),
              Text(
                _currentUserEmail,
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      icon: Icons.cake_outlined,
                      title: 'Age',
                      value: _ageController.text.isNotEmpty ? '${_ageController.text} yrs' : '--',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricCard(
                      icon: Icons.height,
                      title: 'Height',
                      value: _heightController.text.isNotEmpty ? '${_heightController.text} cm' : '--',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      icon: Icons.monitor_weight_outlined,
                      title: 'Weight',
                      value: _weightController.text.isNotEmpty ? '${_weightController.text} kg' : '--',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricCard(
                      icon: Icons.speed,
                      title: 'BMI',
                      value: _bmi != null ? _bmi!.toStringAsFixed(1) : '--',
                      subtitle: _bmiCategory.isNotEmpty ? _bmiCategory : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE1E6E1)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.person_outline, color: Color(0xFF4CAF50)),
                      title: const Text('Full Name'),
                      subtitle: Text(_currentUserName),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.email_outlined, color: Color(0xFF4CAF50)),
                      title: const Text('Email Address'),
                      subtitle: Text(_currentUserEmail),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () => _logout(context),
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required String title,
    required String value,
    String? subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE1E6E1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF4CAF50), size: 28),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 13, color: Colors.black54)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF4CAF50)),
            ),
          ]
        ],
      ),
    );
  }
}