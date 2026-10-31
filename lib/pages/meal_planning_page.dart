import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MealPlanningPage extends StatefulWidget {
  const MealPlanningPage({super.key});

  @override
  State<MealPlanningPage> createState() => _MealPlanningPageState();
}

class _MealPlanningPageState extends State<MealPlanningPage> {
  int _selectedDayIndex = 0;
  int _consumedCals = 0;
  final int _targetCals = 2000;
  int _teaSnackCount = 1;
  String _dietPreference = 'All';

  final List<String> _days = const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  List<Map<String, dynamic>> _groceryItems = [
    {'name': 'Sprouted Moong & Chana', 'bought': false},
    {'name': 'Oats & Roasted Makhana', 'bought': true},
    {'name': 'Eggs / Cottage Cheese (Paneer)', 'bought': false},
    {'name': 'Chicken Breast / Fish Fillets', 'bought': false},
    {'name': 'Bananas & Green Tea Bags', 'bought': true},
  ];

  final List<Map<String, dynamic>> _allMeals = [
    {
      'id': 'b1',
      'time': 'Breakfast',
      'title': 'Vegetable Poha with Peanuts',
      'cals': 220,
      'taken': false,
      'icon': Icons.breakfast_dining_rounded,
      'type': 'Healthy Veg',
      'isVeg': true,
    },
    {
      'id': 'b2',
      'time': 'Breakfast',
      'title': 'Oats Upma with Green Peas & Carrots',
      'cals': 200,
      'taken': false,
      'icon': Icons.breakfast_dining_rounded,
      'type': 'High Fiber Veg',
      'isVeg': true,
    },
    {
      'id': 'b3',
      'time': 'Breakfast',
      'title': 'Boiled Eggs (2) & Whole Wheat Toast',
      'cals': 260,
      'taken': false,
      'icon': Icons.egg_rounded,
      'type': 'High Protein Non-Veg',
      'isVeg': false,
    },
    {
      'id': 'b4',
      'time': 'Breakfast',
      'title': 'Sprouted Moong & Chana Chat',
      'cals': 180,
      'taken': false,
      'icon': Icons.breakfast_dining_rounded,
      'type': 'Raw Clean Veg',
      'isVeg': true,
    },
    {
      'id': 'b5',
      'time': 'Breakfast',
      'title': 'Masala Omelette (2 Eggs) with Brown Bread',
      'cals': 310,
      'taken': false,
      'icon': Icons.egg_alt_rounded,
      'type': 'Protein Non-Veg',
      'isVeg': false,
    },
    {
      'id': 'b6',
      'time': 'Breakfast',
      'title': 'Besan Chilla (2) with Green Chutney',
      'cals': 240,
      'taken': false,
      'icon': Icons.breakfast_dining_rounded,
      'type': 'Low GI Veg',
      'isVeg': true,
    },
    {
      'id': 'b7',
      'time': 'Breakfast',
      'title': 'Idli (3 Pcs) with Sambar & Coconut Chutney',
      'cals': 250,
      'taken': false,
      'icon': Icons.breakfast_dining_rounded,
      'type': 'South Indian Veg',
      'isVeg': true,
    },
    {
      'id': 'b8',
      'time': 'Breakfast',
      'title': 'Egg Bhurji with 2 Wheat Chapatis',
      'cals': 340,
      'taken': false,
      'icon': Icons.egg_rounded,
      'type': 'Filling Non-Veg',
      'isVeg': false,
    },
    {
      'id': 'l1',
      'time': 'Lunch',
      'title': '2 Chapati, Dal Tadka, Bhindi Subzi & Salad',
      'cals': 450,
      'taken': false,
      'icon': Icons.lunch_dining_rounded,
      'type': 'Balanced Veg',
      'isVeg': true,
    },
    {
      'id': 'l2',
      'time': 'Lunch',
      'title': 'Grilled Chicken Breast with Brown Rice & Veggies',
      'cals': 520,
      'taken': false,
      'icon': Icons.kebab_dining_rounded,
      'type': 'Lean Protein Non-Veg',
      'isVeg': false,
    },
    {
      'id': 'l3',
      'time': 'Lunch',
      'title': 'Paneer Bhurji with 2 Whole Wheat Roti & Cucumber',
      'cals': 480,
      'taken': false,
      'icon': Icons.lunch_dining_rounded,
      'type': 'Protein Rich Veg',
      'isVeg': true,
    },
    {
      'id': 'l4',
      'time': 'Lunch',
      'title': 'Fish Curry (Rohu/Surmai) with Steamed Rice',
      'cals': 510,
      'taken': false,
      'icon': Icons.set_meal_rounded,
      'type': 'Omega-3 Non-Veg',
      'isVeg': false,
    },
    {
      'id': 'l5',
      'time': 'Lunch',
      'title': 'Rajma Chawal Bowl with Green Salad',
      'cals': 460,
      'taken': false,
      'icon': Icons.rice_bowl_rounded,
      'type': 'Comfort Veg',
      'isVeg': true,
    },
    {
      'id': 'l6',
      'time': 'Lunch',
      'title': 'Egg Curry (2 Eggs) with Rice & Onion Salad',
      'cals': 490,
      'taken': false,
      'icon': Icons.egg_alt_rounded,
      'type': 'Budget Non-Veg',
      'isVeg': false,
    },
    {
      'id': 'l7',
      'time': 'Lunch',
      'title': 'Chole Bhature (1 Bhatura) + Cucumber Salad',
      'cals': 580,
      'taken': false,
      'icon': Icons.lunch_dining_rounded,
      'type': 'Cheat Meal Veg',
      'isVeg': true,
    },
    {
      'id': 'l8',
      'time': 'Lunch',
      'title': 'Chicken Sukka with 2 Roti & Buttermilk',
      'cals': 540,
      'taken': false,
      'icon': Icons.kebab_dining_rounded,
      'type': 'High Protein Non-Veg',
      'isVeg': false,
    },
    {
      'id': 'l9',
      'time': 'Lunch',
      'title': 'Soya Chunk Curry with Jeera Rice',
      'cals': 430,
      'taken': false,
      'icon': Icons.lunch_dining_rounded,
      'type': 'High Fiber Veg',
      'isVeg': true,
    },
    {
      'id': 'l10',
      'time': 'Lunch',
      'title': 'Prawns Masala with Rice Bhakri / Roti',
      'cals': 470,
      'taken': false,
      'icon': Icons.set_meal_rounded,
      'type': 'Seafood Non-Veg',
      'isVeg': false,
    },
    {
      'id': 's1',
      'time': 'Snack',
      'title': 'Roasted Makhana with Rock Salt',
      'cals': 110,
      'taken': false,
      'icon': Icons.bakery_dining_rounded,
      'type': 'Crunchy Veg',
      'isVeg': true,
    },
    {
      'id': 's2',
      'time': 'Snack',
      'title': 'Boiled Egg Whites (3 Pcs) with Black Pepper',
      'cals': 50,
      'taken': false,
      'icon': Icons.egg_rounded,
      'type': 'Pure Protein Non-Veg',
      'isVeg': false,
    },
    {
      'id': 's3',
      'time': 'Snack',
      'title': 'Handful of Almonds & Walnuts',
      'cals': 160,
      'taken': false,
      'icon': Icons.grain_rounded,
      'type': 'Healthy Fats Veg',
      'isVeg': true,
    },
    {
      'id': 's4',
      'time': 'Snack',
      'title': 'Chicken Sandwich (Brown Bread)',
      'cals': 280,
      'taken': false,
      'icon': Icons.lunch_dining_rounded,
      'type': 'Filling Non-Veg',
      'isVeg': false,
    },
    {
      'id': 's5',
      'time': 'Snack',
      'title': 'Sukha Bhel with Lemon & Peanuts',
      'cals': 140,
      'taken': false,
      'icon': Icons.bakery_dining_rounded,
      'type': 'Light Street Veg',
      'isVeg': true,
    },
    {
      'id': 's6',
      'time': 'Snack',
      'title': 'Grilled Paneer Cubes (100g) with Peri Peri',
      'cals': 260,
      'taken': false,
      'icon': Icons.bakery_dining_rounded,
      'type': 'Protein Veg',
      'isVeg': true,
    },
    {
      'id': 'd1',
      'time': 'Dinner',
      'title': '2 Chapati, Palak Paneer & Cucumber Salad',
      'cals': 420,
      'taken': false,
      'icon': Icons.dinner_dining_rounded,
      'type': 'Iron Rich Veg',
      'isVeg': true,
    },
    {
      'id': 'd2',
      'time': 'Dinner',
      'title': 'Light Chicken Soup with Garlic Toast & Salad',
      'cals': 310,
      'taken': false,
      'icon': Icons.soup_kitchen_rounded,
      'type': 'Low Cal Non-Veg',
      'isVeg': false,
    },
    {
      'id': 'd3',
      'time': 'Dinner',
      'title': 'Mixed Dal Khichdi with Ghee & Papad',
      'cals': 360,
      'taken': false,
      'icon': Icons.rice_bowl_rounded,
      'type': 'Easy Digest Veg',
      'isVeg': true,
    },
    {
      'id': 'd4',
      'time': 'Dinner',
      'title': 'Grilled Fish Fillet with Steamed Broccoli & Carrots',
      'cals': 390,
      'taken': false,
      'icon': Icons.set_meal_rounded,
      'type': 'Keto Non-Veg',
      'isVeg': false,
    },
    {
      'id': 'd5',
      'time': 'Dinner',
      'title': 'Mixed Veg Kadai with 2 Whole Wheat Phulkas',
      'cals': 380,
      'taken': false,
      'icon': Icons.dinner_dining_rounded,
      'type': 'Vitamins Veg',
      'isVeg': true,
    },
    {
      'id': 'd6',
      'time': 'Dinner',
      'title': 'Egg Roll (Whole Wheat Wrap with 2 Eggs)',
      'cals': 410,
      'taken': false,
      'icon': Icons.egg_alt_rounded,
      'type': 'Quick Non-Veg',
      'isVeg': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadMealPlannerData();
  }

  // ============================================================
  // LOAD DATA FROM SHAREDPREFERENCES
  // ============================================================
  Future<void> _loadMealPlannerData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final int? savedDayIndex = prefs.getInt('meal_selected_day_index');
      final int? savedConsumedCals = prefs.getInt('meal_consumed_cals');
      final int? savedTeaCount = prefs.getInt('meal_tea_snack_count');
      final String? savedDietPref = prefs.getString('meal_diet_preference');
      final String? mealsJson = prefs.getString('meal_taken_states');
      final String? groceryJson = prefs.getString('meal_grocery_items');

      if (!mounted) return;

      setState(() {
        if (savedDayIndex != null) _selectedDayIndex = savedDayIndex;
        if (savedConsumedCals != null) _consumedCals = savedConsumedCals;
        if (savedTeaCount != null) _teaSnackCount = savedTeaCount;
        if (savedDietPref != null) _dietPreference = savedDietPref;

        // Load Meal Check States
        if (mealsJson != null) {
          final Map<String, dynamic> takenMap = jsonDecode(mealsJson);
          for (var meal in _allMeals) {
            final String id = meal['id'] as String;
            if (takenMap.containsKey(id)) {
              meal['taken'] = takenMap[id] as bool;
            }
          }
        }

        // Load Grocery Checklist
        if (groceryJson != null) {
          final List<dynamic> decodedGrocery = jsonDecode(groceryJson);
          _groceryItems = decodedGrocery.map((item) {
            return Map<String, dynamic>.from(item as Map);
          }).toList();
        }
      });
    } catch (e) {
      debugPrint('Error loading meal planner data: $e');
    }
  }

  // ============================================================
  // SAVE DATA TO SHAREDPREFERENCES
  // ============================================================
  Future<void> _saveMealPlannerData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('meal_selected_day_index', _selectedDayIndex);
      await prefs.setInt('meal_consumed_cals', _consumedCals);
      await prefs.setInt('meal_tea_snack_count', _teaSnackCount);
      await prefs.setString('meal_diet_preference', _dietPreference);

      // Save Meal Check States
      final Map<String, bool> takenMap = {};
      for (var meal in _allMeals) {
        takenMap[meal['id'] as String] = meal['taken'] as bool;
      }
      await prefs.setString('meal_taken_states', jsonEncode(takenMap));

      // Save Grocery List
      await prefs.setString('meal_grocery_items', jsonEncode(_groceryItems));
    } catch (e) {
      debugPrint('Error saving meal planner data: $e');
    }
  }

  void _openGrocerySheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final List<Widget> listWidgets = [
              const Text(
                '🛒 Weekly Student Grocery List',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
            ];

            for (int index = 0; index < _groceryItems.length; index++) {
              listWidgets.add(
                CheckboxListTile(
                  value: _groceryItems[index]['bought'] as bool,
                  title: Text(_groceryItems[index]['name'] as String),
                  activeColor: Colors.teal,
                  onChanged: (val) async {
                    if (val == null) return;
                    setSheetState(() => _groceryItems[index]['bought'] = val);
                    setState(() {});
                    await _saveMealPlannerData();
                  },
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: listWidgets,
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Process list directly without late variables
    final List<Map<String, dynamic>> filteredMeals = [];
    for (int i = 0; i < _allMeals.length; i++) {
      final item = Map<String, dynamic>.from(_allMeals[i]);
      final bool isVeg = item['isVeg'] as bool;
      if (_dietPreference == 'Veg' && isVeg) {
        filteredMeals.add(item);
      } else if (_dietPreference == 'Non-Veg' && !isVeg) {
        filteredMeals.add(item);
      } else if (_dietPreference == 'All') {
        filteredMeals.add(item);
      }
    }

    final double progress = (_consumedCals / _targetCals).clamp(0.0, 1.0);

    // Build Day Chips
    final List<Widget> dayChips = [];
    for (int i = 0; i < _days.length; i++) {
      dayChips.add(
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: ChoiceChip(
            selected: _selectedDayIndex == i,
            label: Text(_days[i]),
            selectedColor: Colors.teal.shade100,
            labelStyle: TextStyle(
              color: _selectedDayIndex == i ? Colors.teal.shade900 : Colors.black87,
              fontWeight: _selectedDayIndex == i ? FontWeight.bold : FontWeight.normal,
            ),
            onSelected: (_) async {
              setState(() => _selectedDayIndex = i);
              await _saveMealPlannerData();
            },
          ),
        ),
      );
    }

    // Build Diet Filter Chips
    final List<String> filterTypes = const ['All', 'Veg', 'Non-Veg'];
    final List<Widget> filterChips = [];
    for (int k = 0; k < filterTypes.length; k++) {
      final String type = filterTypes[k];
      final bool isSelected = _dietPreference == type;
      Color chipColor = Colors.teal;
      if (type == 'Veg') chipColor = Colors.green;
      if (type == 'Non-Veg') chipColor = Colors.red;

      filterChips.add(
        ChoiceChip(
          selected: isSelected,
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (type == 'Veg') const Icon(Icons.circle, size: 10, color: Colors.green),
              if (type == 'Non-Veg') const Icon(Icons.circle, size: 10, color: Colors.red),
              if (type != 'All') const SizedBox(width: 4),
              Text(type),
            ],
          ),
          selectedColor: chipColor.withAlpha(51),
          labelStyle: TextStyle(
            color: isSelected ? chipColor : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          onSelected: (_) async {
            setState(() => _dietPreference = type);
            await _saveMealPlannerData();
          },
        ),
      );
    }

    // Build Meal Cards
    final List<Widget> mealCards = [];
    for (int j = 0; j < filteredMeals.length; j++) {
      final item = filteredMeals[j];
      final bool isVeg = item['isVeg'] as bool;

      mealCards.add(
        Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: CheckboxListTile(
            value: item['taken'] as bool,
            activeColor: Colors.teal,
            secondary: CircleAvatar(
              backgroundColor: isVeg ? Colors.green.shade50 : Colors.red.shade50,
              child: Icon(
                item['icon'] as IconData,
                color: isVeg ? Colors.green : Colors.red,
              ),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    item['time'] as String,
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item['title'] as String,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text('+${item['cals']} kcal • ${item['type']}'),
            ),
            onChanged: (val) async {
              if (val == null) return;
              setState(() {
                // Update original master list item matching ID
                final masterMeal = _allMeals.firstWhere((m) => m['id'] == item['id']);
                masterMeal['taken'] = val;

                if (val) {
                  _consumedCals += item['cals'] as int;
                } else {
                  _consumedCals -= item['cals'] as int;
                }
              });
              await _saveMealPlannerData();
            },
          ),
        ),
      );
    }

    final List<Widget> mainContent = [
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: dayChips),
      ),
      const SizedBox(height: 14),
      Row(
        children: [
          const Text('Diet Filter: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(width: 8),
          Wrap(spacing: 6, children: filterChips),
        ],
      ),
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade800, Colors.green.shade500],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Daily Calorie Intake', style: TextStyle(color: Colors.white70, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text(
                      '$_consumedCals / $_targetCals kcal',
                      style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const CircleAvatar(
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.pie_chart_rounded, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white24,
                color: Colors.white,
                minHeight: 8,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Row(
            children: [
              const CircleAvatar(
                backgroundColor: Colors.amber,
                child: Icon(Icons.coffee_rounded, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Tea / Coffee Breaks', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Text(
                      '$_teaSnackCount Servings (~${_teaSnackCount * 60} kcal)',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                onPressed: () async {
                  if (_teaSnackCount > 0) {
                    setState(() {
                      _teaSnackCount--;
                      _consumedCals -= 60;
                    });
                    await _saveMealPlannerData();
                  }
                },
              ),
              Text('$_teaSnackCount', style: const TextStyle(fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                onPressed: () async {
                  setState(() {
                    _teaSnackCount++;
                    _consumedCals += 60;
                  });
                  await _saveMealPlannerData();
                },
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 20),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('📋 Meal Menu Options', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text(
            'Showing ${filteredMeals.length} Items',
            style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      const SizedBox(height: 10),
    ];

    mainContent.addAll(mealCards);
    mainContent.add(const SizedBox(height: 60));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Interactive Meal Planner'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openGrocerySheet,
        backgroundColor: Colors.teal,
        icon: const Icon(Icons.shopping_cart_rounded, color: Colors.white),
        label: const Text(
          'Grocery List',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: mainContent,
        ),
      ),
    );
  }
}