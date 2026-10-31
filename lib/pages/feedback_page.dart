import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  double _stressRating = 3.0;
  final TextEditingController _feedbackController = TextEditingController();
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    _loadFeedbackData();
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  // ============================================================
  // LOAD SAVED DATA FROM SHAREDPREFERENCES
  // ============================================================
  Future<void> _loadFeedbackData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final double? savedStress = prefs.getDouble('feedback_stress_rating');
      final String? savedFeedback = prefs.getString('feedback_text_response');
      final bool? savedSubmitted = prefs.getBool('feedback_is_submitted');

      if (!mounted) return;

      setState(() {
        if (savedStress != null) {
          _stressRating = savedStress;
        }
        if (savedFeedback != null) {
          _feedbackController.text = savedFeedback;
        }
        if (savedSubmitted != null) {
          _submitted = savedSubmitted;
        }
      });
    } catch (e) {
      debugPrint('Error loading feedback data: $e');
    }
  }

  // ============================================================
  // SAVE DATA TO SHAREDPREFERENCES
  // ============================================================
  Future<void> _saveFeedbackData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('feedback_stress_rating', _stressRating);
      await prefs.setString('feedback_text_response', _feedbackController.text.trim());
      await prefs.setBool('feedback_is_submitted', _submitted);
    } catch (e) {
      debugPrint('Error saving feedback data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CEP Research Feedback'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF3F51B5), Color(0xFF7986CB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  Icon(Icons.assignment_ind_rounded, size: 40, color: Colors.white),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Community Engagement Project',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Help us evaluate student wellness & stress patterns.',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '1. Rate your daily academic stress level:',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Slider(
                      value: _stressRating,
                      min: 1,
                      max: 5,
                      divisions: 4,
                      activeColor: Colors.indigo,
                      onChanged: (val) async {
                        setState(() {
                          _stressRating = val;
                        });
                        await _saveFeedbackData();
                      },
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.indigo.shade50,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _getStressLabel(_stressRating),
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '2. What health issues do you face most during college?',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _feedbackController,
              maxLines: 4,
              onChanged: (_) async {
                await _saveFeedbackData();
              },
              decoration: InputDecoration(
                hintText: 'e.g., Lower back pain during labs, fatigue in afternoon lectures, poor canteen food options...',
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                ),
                onPressed: () async {
                  setState(() {
                    _submitted = true;
                  });
                  await _saveFeedbackData();

                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Response logged for CEP Research Report.'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                icon: const Icon(Icons.send_rounded, color: Colors.white),
                label: const Text(
                  'Submit Research Response',
                  style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            if (_submitted) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_rounded, color: Colors.green),
                    SizedBox(width: 8),
                    Text(
                      'Successfully Recorded for CEP Study',
                      style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  String _getStressLabel(double value) {
    switch (value.toInt()) {
      case 1:
        return '1 - Low / Relaxed';
      case 2:
        return '2 - Mild Stress';
      case 3:
        return '3 - Moderate / Normal';
      case 4:
        return '4 - High (Exam Term)';
      case 5:
        return '5 - Severe Fatigue';
      default:
        return '';
    }
  }
}