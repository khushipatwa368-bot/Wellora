import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  static const String _baseUrl = 'https://wellora-backend-wnzo.onrender.com';

  // Temporary logged-in user ID
  final int _userId = 1;

  // Initial values 0 se start hongi taaki khudse pre-fill na ho
  int _totalBurned = 0;
  int _activeMins = 0;
  int _stepCount = 0;

  final int _targetSteps = 8000;
  final int _targetBurn = 500;

  String _selectedCategory = 'All';

  bool _loadingActivities = false;

  // Sabhi initial activities 'done: false' rahengi
  List<Map<String, dynamic>> _activities = [
    {
      'title': 'Local Train & Campus Commute',
      'subtitle': 'Brisk Walk & Platform Stairs • 25 mins',
      'cals': 110,
      'done': false,
      'category': 'Commute',
      'icon': Icons.directions_subway_rounded,
      'duration': 25,
    },
    {
      'title': 'Stairs Climbing (College Building)',
      'subtitle': 'High Intensity • 12 mins',
      'cals': 95,
      'done': false,
      'category': 'Workouts',
      'icon': Icons.stairs_rounded,
      'duration': 12,
    },
    {
      'title': 'Library to Canteen Walk',
      'subtitle': 'Light Stroll • 15 mins',
      'cals': 45,
      'done': false,
      'category': 'Commute',
      'icon': Icons.directions_walk_rounded,
      'duration': 15,
    },
    {
      'title': 'Quick Badminton / Sports',
      'subtitle': 'Moderate Play • 30 mins',
      'cals': 140,
      'done': false,
      'category': 'Workouts',
      'icon': Icons.sports_tennis_rounded,
      'duration': 30,
    },
    {
      'title': 'Post-Study Desk Stretching & Yoga',
      'subtitle': 'Flexibility & Posture • 15 mins',
      'cals': 40,
      'done': false,
      'category': 'Workouts',
      'icon': Icons.self_improvement_rounded,
      'duration': 15,
    },
    {
      'title': 'Household Chores & Room Clean',
      'subtitle': 'Active Movement • 20 mins',
      'cals': 65,
      'done': false,
      'category': 'Chores',
      'icon': Icons.cleaning_services_rounded,
      'duration': 20,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadLocalStateData().then((_) => _loadActivities());
  }

  // ============================================================
  // LOAD LOCAL STATE FROM SHAREDPREFERENCES
  // ============================================================
  Future<void> _loadLocalStateData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final totalBurnedVal = prefs.get('activity_total_burned');
      final activeMinsVal = prefs.get('activity_active_mins');
      final stepCountVal = prefs.get('activity_step_count');

      if (!mounted) return;

      setState(() {
        if (totalBurnedVal != null) _totalBurned = (totalBurnedVal as num).toInt();
        if (activeMinsVal != null) _activeMins = (activeMinsVal as num).toInt();
        if (stepCountVal != null) _stepCount = (stepCountVal as num).toInt();

        final String? storedActivitiesJson = prefs.getString('activity_list_data');
        if (storedActivitiesJson != null) {
          final decoded = jsonDecode(storedActivitiesJson);
          if (decoded != null && decoded is List) {
            _activities = decoded.map((item) {
              final map = Map<String, dynamic>.from(item as Map);
              map['icon'] = _getCategoryIcon(map['category']?.toString() ?? 'Workouts');
              return map;
            }).toList();
          }
        }
      });
    } catch (e) {
      debugPrint('Error loading local state: $e');
    }
  }

  // ============================================================
  // SAVE LOCAL STATE TO SHAREDPREFERENCES
  // ============================================================
  Future<void> _saveLocalStateData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('activity_total_burned', _totalBurned);
      await prefs.setInt('activity_active_mins', _activeMins);
      await prefs.setInt('activity_step_count', _stepCount);

      final List<Map<String, dynamic>> jsonList = _activities.map((item) {
        final copy = Map<String, dynamic>.from(item);
        copy.remove('icon');
        return copy;
      }).toList();

      await prefs.setString('activity_list_data', jsonEncode(jsonList));
    } catch (e) {
      debugPrint('Error saving local state: $e');
    }
  }

  // ============================================================
  // LOAD ACTIVITIES FROM BACKEND
  // ============================================================
  Future<void> _loadActivities() async {
    if (!mounted) return;
    setState(() {
      _loadingActivities = true;
    });

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/activity/$_userId'),
      ).timeout(const Duration(seconds: 3));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data != null && data is Map && data['success'] == true && data['activities'] is List) {
          final List<dynamic> backendActivities = data['activities'];
          final List<Map<String, dynamic>> loadedActivities = [];

          for (final activity in backendActivities) {
            if (activity is Map) {
              final int backendId = activity['id'];
              final String name = activity['activity_name']?.toString() ?? 'Activity';
              final int duration = int.tryParse(activity['duration_minutes']?.toString() ?? '0') ?? 0;
              final int studyBreak = int.tryParse(activity['study_break']?.toString() ?? '0') ?? 0;

              bool currentDone = false;
              final existingIndex = _activities.indexWhere((item) => item['backendId'] == backendId);
              if (existingIndex != -1) {
                currentDone = _activities[existingIndex]['done'] ?? false;
              }

              loadedActivities.add({
                'title': name,
                'subtitle': studyBreak == 1 ? 'Study Break • $duration mins' : 'Logged Activity • $duration mins',
                'cals': 0,
                'done': currentDone,
                'category': 'Workouts',
                'icon': Icons.fitness_center_rounded,
                'duration': duration,
                'backendId': backendId,
              });
            }
          }

          if (!mounted) return;

          setState(() {
            _activities.removeWhere((item) => item['backendId'] != null);
            _activities.insertAll(0, loadedActivities);
          });
          await _saveLocalStateData();
        }
      }
    } catch (e) {
      debugPrint('Activity loading error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _loadingActivities = false;
        });
      }
    }
  }

  // ============================================================
  // SAVE ACTIVITY TO BACKEND
  // ============================================================
  Future<bool> _saveActivityToBackend({
    required String activityName,
    required int duration,
    required bool studyBreak,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/activity'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': _userId,
          'activity_name': activityName,
          'duration_minutes': duration,
          'study_break': studyBreak ? 1 : 0,
        }),
      ).timeout(const Duration(seconds: 3));

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data != null && data is Map && data['success'] == true) {
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint('Activity save error: $e');
      return false;
    }
  }

  // ============================================================
  // ADD CUSTOM ACTIVITY
  // ============================================================
  void _showAddActivityBottomSheet() {
    final titleController = TextEditingController();
    final minsController = TextEditingController();
    final calsController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
            top: 20,
            left: 20,
            right: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add Custom Activity',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Activity Name (e.g. Evening Jog)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: minsController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Duration (mins)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: calsController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Est. Calories',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    final String title = titleController.text.trim();
                    final int mins = int.tryParse(minsController.text.trim()) ?? 0;
                    final int cals = int.tryParse(calsController.text.trim()) ?? 0;

                    if (title.isEmpty || mins <= 0 || cals < 0) {
                      if (!sheetContext.mounted) return;
                      ScaffoldMessenger.of(sheetContext).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter valid activity details.'),
                        ),
                      );
                      return;
                    }

                    final bool saved = await _saveActivityToBackend(
                      activityName: title,
                      duration: mins,
                      studyBreak: false,
                    );

                    if (!sheetContext.mounted) return;
                    if (!mounted) return;

                    if (saved) {
                      setState(() {
                        _activities.insert(0, {
                          'title': title,
                          'subtitle': 'Custom • $mins mins',
                          'cals': cals,
                          'done': false,
                          'category': 'Workouts',
                          'icon': Icons.fitness_center_rounded,
                          'duration': mins,
                        });
                      });

                      await _saveLocalStateData();

                      if (!sheetContext.mounted) return;
                      Navigator.pop(sheetContext);

                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Activity added successfully!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(sheetContext).showSnackBar(
                        const SnackBar(
                          content: Text('Could not save activity. Check backend.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: const Text(
                    'Add Activity',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // LOG STEP ACTIVITY
  // ============================================================
  Future<void> _addSteps() async {
    try {
      await _saveActivityToBackend(
        activityName: 'Walking / Daily Steps',
        duration: 5,
        studyBreak: false,
      );
    } catch (_) {}

    if (!mounted) return;

    setState(() {
      _stepCount += 500;
      _totalBurned += 20;
      _activeMins += 5;
    });

    await _saveLocalStateData();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('+500 steps logged successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // ============================================================
  // CATEGORY ICON
  // ============================================================
  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Commute':
        return Icons.directions_subway_rounded;
      case 'Workouts':
        return Icons.fitness_center_rounded;
      case 'Chores':
        return Icons.cleaning_services_rounded;
      default:
        return Icons.directions_walk_rounded;
    }
  }

  // ============================================================
  // BUILD
  // ============================================================
  @override
  Widget build(BuildContext context) {
    final double burnProgress = (_totalBurned / _targetBurn).clamp(0.0, 1.0);
    final double stepProgress = (_stepCount / _targetSteps).clamp(0.0, 1.0);

    final List<Map<String, dynamic>> filteredActivities = _selectedCategory == 'All'
        ? _activities
        : _activities.where((activity) => activity['category'] == _selectedCategory).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Activity & Step Tracker'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddActivityBottomSheet,
        backgroundColor: Colors.deepOrange,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Log Activity',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SUMMARY CARD
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange.shade900, Colors.deepOrange.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepOrange.withValues(alpha: 0.3),
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
                          const Text(
                            'Total Calorie Burn',
                            style: TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$_totalBurned / $_targetBurn kcal',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'Active Duration',
                            style: TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$_activeMins mins',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: burnProgress,
                      backgroundColor: Colors.white24,
                      color: Colors.white,
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // STEP COUNTER
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: Colors.orangeAccent,
                          child: Icon(Icons.directions_walk_rounded, color: Colors.white),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Daily Step Goal',
                                style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                              ),
                              Text(
                                '$_stepCount / $_targetSteps Steps',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange.shade50,
                            foregroundColor: Colors.deepOrange,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: _addSteps,
                          child: const Text(
                            '+500 Steps',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: stepProgress,
                      color: Colors.deepOrange,
                      backgroundColor: Colors.orange.shade100,
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // CATEGORY FILTER
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['All', 'Commute', 'Workouts', 'Chores'].map((category) {
                  final bool isSelected = _selectedCategory == category;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      selected: isSelected,
                      label: Text(category),
                      selectedColor: Colors.deepOrange.shade100,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.deepOrange.shade900 : Colors.black87,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (_) {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // BACKEND LOADING
            if (_loadingActivities)
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: LinearProgressIndicator(color: Colors.deepOrange),
              ),

            // ACTIVITY LIST
            if (filteredActivities.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.directions_walk_outlined, size: 45, color: Colors.grey),
                    SizedBox(height: 10),
                    Text(
                      'No activities found',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

            ...filteredActivities.map((item) {
              final bool isDone = item['done'] == true;
              final String title = item['title']?.toString() ?? 'Activity';
              final String subtitle = item['subtitle']?.toString() ?? 'Activity';
              final int calories = item['cals'] is int
                  ? item['cals'] as int
                  : int.tryParse(item['cals']?.toString() ?? '0') ?? 0;
              final int duration = item['duration'] is int
                  ? item['duration'] as int
                  : int.tryParse(item['duration']?.toString() ?? '15') ?? 15;
              final IconData icon = item['icon'] is IconData
                  ? item['icon'] as IconData
                  : _getCategoryIcon(item['category']?.toString() ?? 'Workouts');

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: CheckboxListTile(
                  value: isDone,
                  activeColor: Colors.deepOrange,
                  secondary: CircleAvatar(
                    backgroundColor: isDone ? Colors.deepOrange.shade50 : Colors.grey.shade100,
                    child: Icon(
                      icon,
                      color: isDone ? Colors.deepOrange : Colors.grey.shade600,
                    ),
                  ),
                  title: Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      decoration: isDone ? TextDecoration.lineThrough : null,
                      color: isDone ? Colors.grey.shade600 : Colors.black87,
                    ),
                  ),
                  subtitle: Text('$subtitle • +$calories kcal'),
                  onChanged: (value) async {
                    if (value == null) return;
                    setState(() {
                      item['done'] = value;
                      if (value) {
                        _totalBurned += calories;
                        _activeMins += duration;
                      } else {
                        _totalBurned = (_totalBurned - calories).clamp(0, 99999);
                        _activeMins = (_activeMins - duration).clamp(0, 99999);
                      }
                    });
                    await _saveLocalStateData();
                  },
                ),
              );
            }),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}