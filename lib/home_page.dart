import 'package:flutter/material.dart';
import 'pages/profile_page.dart';
import 'pages/bmi_page.dart';
import 'pages/activity_page.dart';
import 'pages/meal_planning_page.dart';
import 'pages/hydration_page.dart';
import 'pages/sleep_page.dart';
import 'pages/health_tips_page.dart';
import 'pages/quiz_page.dart';
import 'pages/food_guide_page.dart';
import 'pages/about_page.dart';

class HomePage extends StatelessWidget {
  final String userName;
  final String userEmail;

  const HomePage({
    super.key,
    required this.userName,
    required this.userEmail,
  });

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> healthCards = [
      {
        'title': 'BMI Calculator',
        'subtitle': 'Check body mass index',
        'image': 'assets/images/bmi.png',
        'color': const Color(0xFFE8F5E9),
        'page': const BmiPage(),
      },
      {
        'title': 'Activity Tracker',
        'subtitle': 'Monitor daily movement',
        'image': 'assets/images/activity.png',
        'color': const Color(0xFFE3F2FD),
        'page': const ActivityPage(),
      },
      {
        'title': 'Meal Planning',
        'subtitle': 'Organize healthy diet',
        'image': 'assets/images/meal_planning.png',
        'color': const Color(0xFFFFF3E0),
        'page': const MealPlanningPage(),
      },
      {
        'title': 'Hydration',
        'subtitle': 'Track water intake',
        'image': 'assets/images/hydration.png',
        'color': const Color(0xFFE0F7FA),
        'page': const HydrationPage(),
      },
      {
        'title': 'Sleep Tracker',
        'subtitle': 'Analyze sleep patterns',
        'image': 'assets/images/sleep.png',
        'color': const Color(0xFFEDE7F6),
        'page': const SleepPage(),
      },
      {
        'title': 'Health Tips',
        'subtitle': 'Daily wellness habits',
        'image': 'assets/images/health_tips.png',
        'color': const Color(0xFFF1F8E9),
        'page': const HealthTipsPage(),
      },
      {
        'title': 'Health Quiz',
        'subtitle': 'Test your knowledge',
        'image': 'assets/images/health_quiz.png',
        'color': const Color(0xFFFFFDE7),
        'page': const QuizPage(),
      },
      {
        'title': 'Food Guide',
        'subtitle': 'Choose healthy ingredients',
        'image': 'assets/images/food_guide.png',
        'color': const Color(0xFFFCE4EC),
        'page': const FoodGuidePage(),
      },
      {
        'title': 'About Wellora',
        'subtitle': 'Learn about the app',
        'image': 'assets/images/about.png',
        'color': const Color(0xFFEFEBE9),
        'page': const AboutPage(),
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8F4),
      appBar: AppBar(
        title: Text(
          'Welcome, $userName 🌱',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: const Color(0xFFE8F5E9),
        foregroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: IconButton(
              icon: const Icon(Icons.person_rounded, size: 28),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(
                      userName: userName,
                      userEmail: userEmail,
                    ),
                  ),
                );
              },
              tooltip: 'Profile',
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Explore Health Dashboard',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1B5E20),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Tap any card to check features & maintain your wellness.',
                style: TextStyle(fontSize: 13, color: Colors.black54),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.builder(
                  itemCount: healthCards.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.78,
                  ),
                  itemBuilder: (context, index) {
                    final card = healthCards[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => card['page'],
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFE0E8E0), width: 1.2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: card['color'],
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(19)),
                                ),
                                padding: const EdgeInsets.all(16),
                                child: Image.asset(
                                  card['image'],
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(Icons.favorite, size: 50, color: Color(0xFF4CAF50));
                                  },
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      card['title'],
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2E7D32),
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      card['subtitle'],
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.black54,
                                        height: 1.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}