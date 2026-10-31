import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int _score = 0;
  int _highScore = 0;
  int _currentQuestionIndex = 0;
  int? _selectedOptionIndex;
  bool _isAnswered = false;

  Timer? _timer;
  int _timeLeft = 15; // 15 Seconds per question

  final List<Map<String, dynamic>> _questions = const [
    {
      'question': 'How much water should an average student drink daily?',
      'options': ['1-2 Liters', '2.5-3 Liters', '5 Liters', 'Only when thirsty'],
      'correct': 1,
      'explanation': '2.5 to 3 liters per day keeps your body properly hydrated and boosts concentration.',
    },
    {
      'question': 'Which is the healthiest snack option during study sessions?',
      'options': ['Fried Chips', 'Roasted Chana / Nuts', 'Instant Noodles', 'Chocolates'],
      'correct': 1,
      'explanation': 'Nuts and roasted chana deliver sustained energy without sudden sugar crashes.',
    },
    {
      'question': 'What is the recommended screen break rule to avoid eye strain?',
      'options': ['10-10-10 Rule', '20-20-20 Rule', '50-50 Rule', 'No breaks needed'],
      'correct': 1,
      'explanation': 'Every 20 minutes, look at something 20 feet away for at least 20 seconds.',
    },
    {
      'question': 'How many hours of sleep are recommended for university students?',
      'options': ['4-5 Hours', '7-9 Hours', '10-12 Hours', 'Sleep length does not matter'],
      'correct': 1,
      'explanation': '7 to 9 hours of quality sleep helps memory consolidation and physical recovery.',
    },
    {
      'question': 'Which habit helps reduce stress and improves mental focus?',
      'options': ['Excessive Caffeine', 'Deep Breathing & Short Walks', 'Continuous Screen Time', 'Skipping Meals'],
      'correct': 1,
      'explanation': 'Taking short breaks and practicing deep breathing helps lower cortisol and reduce stress.',
    },
    {
      'question': 'What is the ideal bedtime habit for better sleep quality?',
      'options': ['Using phone in bed', 'Drinking coffee late night', 'Reading or offline relaxing', 'Heavy workout at 11 PM'],
      'correct': 2,
      'explanation': 'Avoiding screen blue-light 30 minutes before sleep helps release natural melatonin.',
    },
    {
      'question': 'Which vitamin is synthesized by your body through morning sunlight exposure?',
      'options': ['Vitamin A', 'Vitamin B12', 'Vitamin C', 'Vitamin D'],
      'correct': 3,
      'explanation': 'Morning sunlight facilitates Vitamin D synthesis, crucial for bone health and immunity.',
    },
    {
      'question': 'What is the primary benefit of eating fiber-rich foods like oats and salads?',
      'options': ['Improves digestion & gut health', 'Increases blood sugar rapidly', 'Causes fatigue', 'Decreases hydration'],
      'correct': 0,
      'explanation': 'Dietary fiber enhances digestion, regulates gut movement, and maintains full feeling longer.',
    },
    {
      'question': 'How many steps per day are generally recommended for an active lifestyle?',
      'options': ['1,000 steps', '4,000 steps', '8,000 - 10,000 steps', '25,000 steps'],
      'correct': 2,
      'explanation': 'Targeting around 8,000 to 10,000 daily steps improves cardiovascular stamina.',
    },
    {
      'question': 'Why is skipping breakfast not recommended for students?',
      'options': ['It lowers energy & focus', 'It speeds up metabolism', 'It improves memory', 'It keeps you hydrated'],
      'correct': 0,
      'explanation': 'Breakfast replenishes glucose supply to restore energy and alertness for morning tasks.',
    },
    {
      'question': 'Which beverage is the best alternative to sugary carbonated drinks?',
      'options': ['Energy drinks', 'Lemon water / Tender coconut', 'Packaged fruit juices', 'Sweetened iced tea'],
      'correct': 1,
      'explanation': 'Fresh coconut water or natural lemon water provides electrolytes without artificial sugar.',
    },
    {
      'question': 'What causes posture issues like back pain during long study sessions?',
      'options': ['Ergonomic chair', 'Slouching / Poor desk ergonomics', 'Stretching regularly', 'Sitting upright'],
      'correct': 1,
      'explanation': 'Slouching strains spine ligaments and back muscles. Maintain upright spine support.',
    },
    {
      'question': 'What is the healthiest way to manage sudden sugar cravings?',
      'options': ['Eat fresh fruits / dates', 'Drink soda', 'Eat milk chocolate bar', 'Ignore hydration completely'],
      'correct': 0,
      'explanation': 'Fruits contain natural sugars along with fiber, preventing steep glucose spikes.',
    },
    {
      'question': 'How does regular physical exercise impact mental health?',
      'options': ['Increases anxiety', 'Releases endorphins (mood boosters)', 'Causes chronic fatigue', 'Impairs memory retention'],
      'correct': 1,
      'explanation': 'Physical exercise stimulates endorphins and dopamine, reducing anxiety and boosting mood.',
    },
    {
      'question': 'What is the best practice after completing an intensive study block?',
      'options': ['Immediately start another without break', 'Take a 5-10 min light walk / stretch', 'Eat a heavy junk meal', 'Sleep for 4 hours'],
      'correct': 1,
      'explanation': 'Short physical movements refresh blood circulation to the brain and reduce cognitive fatigue.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadQuizData();
  }

  // ============================================================
  // LOAD DATA FROM SHAREDPREFERENCES
  // ============================================================
  Future<void> _loadQuizData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _score = prefs.getInt('quiz_score') ?? 0;
      _highScore = prefs.getInt('quiz_high_score') ?? 0;
      _currentQuestionIndex = prefs.getInt('quiz_current_index') ?? 0;
    });
    _startTimer();
  }

  // ============================================================
  // SAVE DATA TO SHAREDPREFERENCES
  // ============================================================
  Future<void> _saveQuizData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('quiz_score', _score);
    await prefs.setInt('quiz_current_index', _currentQuestionIndex);
    if (_score > _highScore) {
      _highScore = _score;
      await prefs.setInt('quiz_high_score', _highScore);
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timeLeft = 15;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() => _timeLeft--);
      } else {
        _timer?.cancel();
        _handleTimeOut();
      }
    });
  }

  void _handleTimeOut() {
    if (!_isAnswered) {
      setState(() {
        _isAnswered = true;
        _selectedOptionIndex = -1;
      });
    }
  }

  void _selectAnswer(int index) async {
    if (_isAnswered) return;

    _timer?.cancel();
    setState(() {
      _selectedOptionIndex = index;
      _isAnswered = true;
      if (index == _questions[_currentQuestionIndex]['correct']) {
        _score += 10;
      }
    });
    await _saveQuizData();
  }

  void _nextQuestion() async {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedOptionIndex = null;
        _isAnswered = false;
      });
      await _saveQuizData();
      _startTimer();
    } else {
      _showResultSheet();
    }
  }

  void _resetQuiz() async {
    _timer?.cancel();
    setState(() {
      _score = 0;
      _currentQuestionIndex = 0;
      _selectedOptionIndex = null;
      _isAnswered = false;
    });
    await _saveQuizData();
    _startTimer();
  }

  void _showResultSheet() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final totalMaxScore = _questions.length * 10;
        final percentage = (_score / totalMaxScore) * 100;

        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                percentage >= 70 ? '🎉 Fantastic Performance!' : '👍 Good Effort!',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
              ),
              const SizedBox(height: 12),
              CircleAvatar(
                radius: 40,
                backgroundColor: const Color(0xFFE8F5E9),
                child: Text(
                  '$_score / $totalMaxScore',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4CAF50)),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '🏆 Best Score: $_highScore',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.amber),
              ),
              const SizedBox(height: 10),
              Text(
                percentage >= 70
                    ? 'You scored ${percentage.toInt()}%! You have awesome wellness awareness.'
                    : 'You scored ${percentage.toInt()}%. Revisit the Health Tips section to boost your health knowledge.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: Colors.black87),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    _resetQuiz();
                  },
                  child: const Text('Retake Quiz', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final q = _questions[_currentQuestionIndex];
    final int correctAnswerIndex = q['correct'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Health & Wellness Quiz', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFE8F5E9),
        foregroundColor: const Color(0xFF2E7D32),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TOP BAR: TIMER & PROGRESS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Question ${_currentQuestionIndex + 1} of ${_questions.length}',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _timeLeft <= 5 ? Colors.red.shade50 : const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.timer, size: 16, color: _timeLeft <= 5 ? Colors.red : const Color(0xFF4CAF50)),
                      const SizedBox(width: 4),
                      Text(
                        '${_timeLeft}s',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: _timeLeft <= 5 ? Colors.red : const Color(0xFF2E7D32),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),

            const SizedBox(height: 10),

            LinearProgressIndicator(
              value: (_currentQuestionIndex + 1) / _questions.length,
              color: const Color(0xFF4CAF50),
              backgroundColor: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(6),
            ),

            const SizedBox(height: 24),

            // QUESTION TEXT
            Text(
              q['question'] as String,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
            ),

            const SizedBox(height: 20),

            // OPTIONS LIST
            Expanded(
              child: ListView.builder(
                itemCount: (q['options'] as List).length,
                itemBuilder: (context, index) {
                  final optionText = q['options'][index];

                  Color borderColor = const Color(0xFFE1E6E1);
                  Color fillColor = Colors.white;
                  Color textColor = Colors.black87;

                  if (_isAnswered) {
                    if (index == correctAnswerIndex) {
                      borderColor = const Color(0xFF4CAF50);
                      fillColor = const Color(0xFFE8F5E9);
                      textColor = const Color(0xFF2E7D32);
                    } else if (index == _selectedOptionIndex) {
                      borderColor = Colors.red;
                      fillColor = Colors.red.shade50;
                      textColor = Colors.red.shade900;
                    }
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _selectAnswer(index),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: fillColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: borderColor, width: 1.5),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                optionText,
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: textColor),
                              ),
                            ),
                            if (_isAnswered && index == correctAnswerIndex)
                              const Icon(Icons.check_circle, color: Color(0xFF4CAF50))
                            else if (_isAnswered && index == _selectedOptionIndex)
                              const Icon(Icons.cancel, color: Colors.red)
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // EXPLANATION CARD
            if (_isAnswered) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F8E9),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFC8E6C9)),
                ),
                child: Text(
                  '💡 Tip: ${q['explanation']}',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF2E7D32)),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // NEXT / FINISH BUTTON
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isAnswered ? _nextQuestion : null,
                child: Text(
                  _currentQuestionIndex == _questions.length - 1 ? 'Finish Quiz' : 'Next Question',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}