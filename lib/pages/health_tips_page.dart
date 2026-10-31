import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HealthTipsPage extends StatefulWidget {
  const HealthTipsPage({super.key});

  @override
  State<HealthTipsPage> createState() => _HealthTipsPageState();
}

class _HealthTipsPageState extends State<HealthTipsPage> {
  String _selectedCategory = 'All';
  final Set<int> _bookmarkedIndices = {};
  final Set<int> _completedTips = {};

  final List<Map<String, dynamic>> studentTips = const [
    {
      'title': 'The 20-20-20 Eye Protection Rule',
      'desc': 'Every 20 minutes of reading or coding, look at an object 20 feet away for 20 seconds to prevent screen eye fatigue.',
      'category': 'Study',
      'icon': Icons.remove_red_eye_rounded,
      'color': Colors.blue,
      'tag': 'Screen Care',
    },
    {
      'title': 'Pre-Viva Box Breathing Technique',
      'desc': 'Inhale for 4s, hold for 4s, exhale for 4s, hold for 4s. Perform 4 rounds before vivas or presentations to reduce anxiety.',
      'category': 'Mental',
      'icon': Icons.self_improvement_rounded,
      'color': Colors.purple,
      'tag': 'Stress Relief',
    },
    {
      'title': 'Smart Hydration Over Extra Coffee',
      'desc': 'Swap your 3rd cup of tea or coffee with a fresh glass of water. Brain dehydration is frequently misread as fatigue.',
      'category': 'Diet',
      'icon': Icons.water_drop_rounded,
      'color': Colors.cyan,
      'tag': 'Energy Boost',
    },
    {
      'title': 'Sleep Memory Consolidation',
      'desc': 'Sleeping 6-7 hours strengthens neural pathways. All-nighters lower exam memory retention capacity by up to 40%.',
      'category': 'Sleep',
      'icon': Icons.bedtime_rounded,
      'color': Colors.indigo,
      'tag': 'Exam Prep',
    },
    {
      'title': 'Posture Check During Long Lectures',
      'desc': 'Keep feet flat on the floor, shoulders relaxed, and stack books under your laptop to lift it to eye level.',
      'category': 'Physical',
      'icon': Icons.accessibility_rounded,
      'color': Colors.orange,
      'tag': 'Ergonomics',
    },
    {
      'title': 'Pomodoro Focus Sprint (25m / 5m)',
      'desc': 'Study continuously for 25 minutes without opening social media, then take a mandatory 5-minute walk break.',
      'category': 'Study',
      'icon': Icons.timer_rounded,
      'color': Colors.deepOrange,
      'tag': 'Productivity',
    },
    {
      'title': 'Late Night Smart Snack Alternatives',
      'desc': 'Avoid fried canteen chips at midnight. Choose roasted makhana, boiled sprouts, or almonds for sustained energy.',
      'category': 'Diet',
      'icon': Icons.restaurant_rounded,
      'color': Colors.teal,
      'tag': 'Nutrition',
    },
    {
      'title': 'Desk Neck & Shoulder Relief Stretches',
      'desc': 'Slowly roll your shoulders backward 10 times and tilt your neck side-to-side to release muscle tension built from studying.',
      'category': 'Physical',
      'icon': Icons.fitness_center_rounded,
      'color': Colors.green,
      'tag': 'Flexibility',
    },
    {
      'title': 'Digital Detox 30 Mins Before Bed',
      'desc': 'Blue light suppresses melatonin release. Turn off screens 30 minutes before sleep to reach deep REM sleep faster.',
      'category': 'Sleep',
      'icon': Icons.phonelink_off_rounded,
      'color': Colors.deepPurple,
      'tag': 'Better Sleep',
    },
    {
      'title': 'Micro Brain Dump Journaling',
      'desc': 'Feeling overwhelmed before exams? Spend 3 minutes writing all your thoughts on paper to clear cognitive load.',
      'category': 'Mental',
      'icon': Icons.edit_note_rounded,
      'color': Colors.pink,
      'tag': 'Mindfulness',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadHealthTipsData();
  }

  // ============================================================
  // LOAD DATA FROM SHAREDPREFERENCES
  // ============================================================
  Future<void> _loadHealthTipsData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? savedCategory = prefs.getString('health_selected_category');
      final List<String>? savedBookmarks = prefs.getStringList('health_bookmarked_indices');
      final List<String>? savedCompleted = prefs.getStringList('health_completed_tips');

      if (!mounted) return;

      setState(() {
        if (savedCategory != null) {
          _selectedCategory = savedCategory;
        }

        if (savedBookmarks != null) {
          _bookmarkedIndices.clear();
          for (final e in savedBookmarks) {
            final parsed = int.tryParse(e);
            if (parsed != null) {
              _bookmarkedIndices.add(parsed);
            }
          }
        }

        if (savedCompleted != null) {
          _completedTips.clear();
          for (final e in savedCompleted) {
            final parsed = int.tryParse(e);
            if (parsed != null) {
              _completedTips.add(parsed);
            }
          }
        }
      });
    } catch (e) {
      debugPrint('Error loading health tips data: $e');
    }
  }

  // ============================================================
  // SAVE DATA TO SHAREDPREFERENCES
  // ============================================================
  Future<void> _saveHealthTipsData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('health_selected_category', _selectedCategory);

      // Save Bookmarks
      await prefs.setStringList(
        'health_bookmarked_indices',
        _bookmarkedIndices.map((idx) => idx.toString()).toList(),
      );

      // Save Completed Tips
      await prefs.setStringList(
        'health_completed_tips',
        _completedTips.map((idx) => idx.toString()).toList(),
      );
    } catch (e) {
      debugPrint('Error saving health tips data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredTips = studentTips.asMap().entries.where((entry) {
      final tip = entry.value;
      if (_selectedCategory == 'Saved') {
        return _bookmarkedIndices.contains(entry.key);
      }
      return _selectedCategory == 'All' || tip['category'] == _selectedCategory;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Wellness Guide'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Top Quick Interactive Banner Card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.indigo.shade700, Colors.purple.shade500],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.indigo.withAlpha(64),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 26,
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.auto_awesome_rounded, color: Colors.amber, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Daily Wellness Habit',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Completed: ${_completedTips.length}/${studentTips.length} Habits Practiced Today',
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Horizontal Filter Chips
          Container(
            height: 45,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: ['All', 'Saved', 'Study', 'Mental', 'Diet', 'Physical', 'Sleep'].map((cat) {
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    selected: isSelected,
                    label: Text(cat == 'Saved' ? '⭐ Saved (${_bookmarkedIndices.length})' : cat),
                    selectedColor: Colors.indigo.shade100,
                    checkmarkColor: Colors.indigo.shade900,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.indigo.shade900 : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (bool value) async {
                      setState(() {
                        _selectedCategory = cat;
                      });
                      await _saveHealthTipsData();
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 10),

          // Expanded Tips List
          Expanded(
            child: filteredTips.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bookmark_border_rounded, size: 48, color: Colors.grey.shade400),
                  const SizedBox(height: 10),
                  Text(
                    _selectedCategory == 'Saved' ? 'No saved guides yet!' : 'No tips found.',
                    style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              itemCount: filteredTips.length,
              itemBuilder: (context, index) {
                final itemEntry = filteredTips[index];
                final originalIdx = itemEntry.key;
                final tip = itemEntry.value;
                final bool isBookmarked = _bookmarkedIndices.contains(originalIdx);
                final bool isPracticed = _completedTips.contains(originalIdx);
                final Color tipColor = tip['color'] as Color;

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: tipColor.withAlpha(38),
                              child: Icon(tip['icon'] as IconData, color: tipColor),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    tip['title'] as String,
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 2),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: tipColor.withAlpha(25),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      tip['tag'] as String,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: tipColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                isBookmarked ? Icons.star_rounded : Icons.star_outline_rounded,
                                color: isBookmarked ? Colors.amber : Colors.grey,
                              ),
                              onPressed: () async {
                                setState(() {
                                  if (isBookmarked) {
                                    _bookmarkedIndices.remove(originalIdx);
                                  } else {
                                    _bookmarkedIndices.add(originalIdx);
                                  }
                                });
                                await _saveHealthTipsData();
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          tip['desc'] as String,
                          style: TextStyle(color: Colors.grey.shade700, fontSize: 13, height: 1.4),
                        ),
                        const Divider(height: 20),
                        InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () async {
                            setState(() {
                              if (isPracticed) {
                                _completedTips.remove(originalIdx);
                              } else {
                                _completedTips.add(originalIdx);
                              }
                            });
                            await _saveHealthTipsData();
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              children: [
                                Icon(
                                  isPracticed ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                                  color: isPracticed ? Colors.green : Colors.grey,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  isPracticed ? 'Practiced Today!' : 'Mark as Practiced',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isPracticed ? Colors.green : Colors.grey.shade700,
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
    );
  }
}