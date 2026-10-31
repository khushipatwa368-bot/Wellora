import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FoodGuidePage extends StatefulWidget {
  const FoodGuidePage({super.key});

  @override
  State<FoodGuidePage> createState() => _FoodGuidePageState();
}

class _FoodGuidePageState extends State<FoodGuidePage> {
  int _totalCals = 380;
  int _proteinGrams = 18;
  int _carbsGrams = 45;
  int _fatsGrams = 12;

  String _selectedCategory = 'All';

  List<Map<String, dynamic>> _meals = [
    {
      'title': 'Vegetable Oats Upma / Poha',
      'subtitle': 'Rich in Fiber & Complex Carbs',
      'cals': 180,
      'protein': 6,
      'carbs': 32,
      'fats': 4,
      'done': true,
      'category': 'Balanced Meals',
      'icon': Icons.rice_bowl_rounded,
    },
    {
      'title': 'Sprouted Moong & Chana Salad',
      'subtitle': 'High Protein Clean Snack',
      'cals': 140,
      'protein': 9,
      'carbs': 20,
      'fats': 2,
      'done': true,
      'category': 'Quick Snacks',
      'icon': Icons.set_meal_rounded,
    },
    {
      'title': 'Fresh Coconut Water / Chaas',
      'subtitle': 'Natural Electrolyte Booster',
      'cals': 60,
      'protein': 3,
      'carbs': 8,
      'fats': 1,
      'done': false,
      'category': 'Smart Hydration',
      'icon': Icons.local_drink_rounded,
    },
    {
      'title': 'Boiled Eggs / Paneer Cubes',
      'subtitle': 'Muscle Recovery & Lean Protein',
      'cals': 160,
      'protein': 14,
      'carbs': 3,
      'fats': 10,
      'done': false,
      'category': 'Balanced Meals',
      'icon': Icons.egg_alt_rounded,
    },
    {
      'title': 'Handful of Mixed Almonds & Walnuts',
      'subtitle': 'Healthy Fats & Brain Power',
      'cals': 120,
      'protein': 4,
      'carbs': 4,
      'fats': 10,
      'done': false,
      'category': 'Quick Snacks',
      'icon': Icons.grain_rounded,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadFoodGuideData();
  }

  // ============================================================
  // LOAD SAVED DATA FROM SHAREDPREFERENCES
  // ============================================================
  Future<void> _loadFoodGuideData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final int? savedCals = prefs.getInt('food_total_cals');
      final int? savedProtein = prefs.getInt('food_protein_grams');
      final int? savedCarbs = prefs.getInt('food_carbs_grams');
      final int? savedFats = prefs.getInt('food_fats_grams');
      final String? storedMealsJson = prefs.getString('food_meals_list');

      if (!mounted) return;

      setState(() {
        if (savedCals != null) _totalCals = savedCals;
        if (savedProtein != null) _proteinGrams = savedProtein;
        if (savedCarbs != null) _carbsGrams = savedCarbs;
        if (savedFats != null) _fatsGrams = savedFats;

        if (storedMealsJson != null) {
          final List<dynamic> decodedList = jsonDecode(storedMealsJson);
          _meals = decodedList.map((item) {
            final map = Map<String, dynamic>.from(item as Map);
            map['icon'] = _getCategoryIcon(map['category']?.toString() ?? 'Balanced Meals');
            return map;
          }).toList();
        }
      });
    } catch (e) {
      debugPrint('Error loading food guide data: $e');
    }
  }

  // ============================================================
  // SAVE DATA TO SHAREDPREFERENCES
  // ============================================================
  Future<void> _saveFoodGuideData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('food_total_cals', _totalCals);
      await prefs.setInt('food_protein_grams', _proteinGrams);
      await prefs.setInt('food_carbs_grams', _carbsGrams);
      await prefs.setInt('food_fats_grams', _fatsGrams);

      final List<Map<String, dynamic>> jsonList = _meals.map((item) {
        final copy = Map<String, dynamic>.from(item);
        copy.remove('icon');
        return copy;
      }).toList();

      await prefs.setString('food_meals_list', jsonEncode(jsonList));
    } catch (e) {
      debugPrint('Error saving food guide data: $e');
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Quick Snacks':
        return Icons.set_meal_rounded;
      case 'Smart Hydration':
        return Icons.local_drink_rounded;
      case 'Balanced Meals':
      default:
        return Icons.rice_bowl_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredMeals = _selectedCategory == 'All'
        ? _meals
        : _meals.where((m) => m['category'] == _selectedCategory).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Food & Macro Guide'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Nutrients Dashboard Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade800, Colors.teal.shade500],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.teal.withAlpha(76),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Logged Intake', style: TextStyle(color: Colors.white70, fontSize: 13)),
                          const SizedBox(height: 2),
                          Text(
                            '$_totalCals kcal',
                            style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(51),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.restaurant_menu_rounded, color: Colors.white, size: 28),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const Text('Macro Breakdown', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildMacroBadge('Protein', '${_proteinGrams}g', Colors.lightBlueAccent),
                      const SizedBox(width: 8),
                      _buildMacroBadge('Carbs', '${_carbsGrams}g', Colors.amberAccent),
                      const SizedBox(width: 8),
                      _buildMacroBadge('Fats', '${_fatsGrams}g', Colors.orangeAccent),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Smart Canteen Swap Tip Card
            Card(
              color: Colors.lightGreen.shade50,
              elevation: 0,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.lightGreen.shade300),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Padding(
                padding: EdgeInsets.all(14.0),
                child: Row(
                  children: [
                    Icon(Icons.lightbulb_rounded, color: Colors.green),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Smart Swap: Samosa (250 kcal) ki jagah Idli ya Poha choose karein to keep energy stable without feeling sleepy during lectures!',
                        style: TextStyle(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Category Selection Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['All', 'Balanced Meals', 'Quick Snacks', 'Smart Hydration'].map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      selected: isSelected,
                      label: Text(cat),
                      selectedColor: Colors.teal.shade100,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.teal.shade900 : Colors.black87,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (_) => setState(() => _selectedCategory = cat),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Interactive Checkable Meal List
            ...filteredMeals.asMap().entries.map((entry) {
              final item = entry.value;
              final bool isDone = item['done'] as bool;

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: CheckboxListTile(
                  value: isDone,
                  activeColor: Colors.teal,
                  secondary: CircleAvatar(
                    backgroundColor: isDone ? Colors.teal.shade50 : Colors.grey.shade100,
                    child: Icon(
                      item['icon'] as IconData,
                      color: isDone ? Colors.teal : Colors.grey.shade600,
                    ),
                  ),
                  title: Text(
                    item['title'] as String,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      decoration: isDone ? TextDecoration.lineThrough : null,
                      color: isDone ? Colors.grey.shade600 : Colors.black87,
                    ),
                  ),
                  subtitle: Text(
                    '${item['subtitle']}\n+${item['cals']} kcal | P: ${item['protein']}g • C: ${item['carbs']}g • F: ${item['fats']}g',
                    style: const TextStyle(fontSize: 11),
                  ),
                  isThreeLine: true,
                  onChanged: (val) async {
                    if (val == null) return;
                    setState(() {
                      item['done'] = val;
                      final int cals = item['cals'] as int;
                      final int p = item['protein'] as int;
                      final int c = item['carbs'] as int;
                      final int f = item['fats'] as int;

                      if (val) {
                        _totalCals += cals;
                        _proteinGrams += p;
                        _carbsGrams += c;
                        _fatsGrams += f;
                      } else {
                        _totalCals -= cals;
                        _proteinGrams -= p;
                        _carbsGrams -= c;
                        _fatsGrams -= f;
                      }
                    });
                    await _saveFoodGuideData();
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroBadge(String title, String val, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(38),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(title, style: const TextStyle(color: Colors.white70, fontSize: 11)),
            const SizedBox(height: 2),
            Text(val, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}