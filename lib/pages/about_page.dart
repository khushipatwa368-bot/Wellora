import 'package:flutter/material.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  final List<Map<String, String>> faqs = const [
    {
      'q': 'What is Wellora?',
      'a': 'Wellora is an all-in-one student wellness platform designed to track physical fitness, mental health, hydration, and meal habits during busy academic routines.'
    },
    {
      'q': 'Is my data secure and private?',
      'a': 'Yes! All your health metrics, water intake logs, and research survey responses remain saved locally on your device.'
    },
    {
      'q': 'What is the CEP Research Module?',
      'a': 'Community Engagement Project (CEP) helps gather anonymized data regarding academic stress levels and canteen food choices to improve campus wellness.'
    },
    {
      'q': 'How do I earn health points in the app?',
      'a': 'You can complete daily quizzes, log 8 glasses of water, and track your daily sleep to score wellness points.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Wellora Project'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.teal.shade700, Colors.teal.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.teal.withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 38,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.health_and_safety_rounded, size: 48, color: Colors.teal),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Wellora Health Suite',
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Version 1.0.0 • CEP Initiative',
                    style: TextStyle(color: Colors.teal.shade50, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Interactive Quick Stats Row
            Row(
              children: [
                _buildStatCard('Modules', '12 Active', Icons.widgets_rounded, Colors.blue),
                const SizedBox(width: 12),
                _buildStatCard('Target Group', 'Students', Icons.school_rounded, Colors.purple),
              ],
            ),
            const SizedBox(height: 24),

            // App Highlights Section
            const Text(
              '🌟 Key Highlights',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildFeatureRow(Icons.monitor_weight_rounded, 'Smart BMI & Calorie Calculator'),
                    const Divider(height: 20),
                    _buildFeatureRow(Icons.water_drop_rounded, 'Real-time Water & Sleep Trackers'),
                    const Divider(height: 20),
                    _buildFeatureRow(Icons.assignment_turned_in_rounded, 'Student Stress Research Feedback'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Interactive FAQ Accordion Section
            const Text(
              '❓ Frequently Asked Questions',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...faqs.map((faq) => Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: ExpansionTile(
                leading: const Icon(Icons.help_outline_rounded, color: Colors.teal),
                title: Text(
                  faq['q']!,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Text(
                      faq['a']!,
                      style: TextStyle(color: Colors.grey.shade700, fontSize: 13, height: 1.4),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String val, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  Text(val, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.teal, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}