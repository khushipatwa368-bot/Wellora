 import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SleepPage extends StatefulWidget {
  const SleepPage({super.key});

  @override
  State<SleepPage> createState() => _SleepPageState();
}

class _SleepPageState extends State<SleepPage> with TickerProviderStateMixin {
  int routineCompleted = 0;
  int selectedQualityIndex = 2;
  int sleepStreak = 4;
  double targetSleepHours = 8.0;
  bool isReminderOn = true;

  // Lamp & User States
  bool isLampOn = true;
  bool showGoodNight = false;
  String userName = 'User';
  int? currentUserId;

  final TextEditingController _dreamController = TextEditingController();

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  late AnimationController _lampGlowController;
  late Animation<double> _lampGlowAnimation;

  final List<String> routineSteps = [
    'Wind down & dim room lights',
    'Put away all electronic screens',
    'Gentle stretching or light reading',
    'Set alarm & preparation for rest',
  ];

  final List<Map<String, String>> sleepQualities = [
    {'label': 'Poor', 'emoji': '😫'},
    {'label': 'Fair', 'emoji': '😐'},
    {'label': 'Good', 'emoji': '😊'},
    {'label': 'Deep', 'emoji': '😴'},
  ];

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _lampGlowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _lampGlowAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _lampGlowController, curve: Curves.easeInOut),
    );

    _loadLocalSleepData();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _lampGlowController.dispose();
    _dreamController.dispose();
    super.dispose();
  }

  Future<void> _loadLocalSleepData() async {
    final prefs = await SharedPreferences.getInstance();

    currentUserId = prefs.getInt('user_id');
    String fetchedName = prefs.getString('user_name') ?? 'User';

    double parsedTarget = 8.0;
    try {
      var val = prefs.get('sleep_target_hours');
      if (val is num) {
        parsedTarget = val.toDouble();
      }
    } catch (_) {
      parsedTarget = 8.0;
    }

    if (mounted) {
      setState(() {
        routineCompleted = prefs.getInt('sleep_routine_completed') ?? 0;
        selectedQualityIndex = prefs.getInt('sleep_quality_index') ?? 2;
        sleepStreak = prefs.getInt('sleep_streak_count') ?? 4;
        targetSleepHours = parsedTarget;
        isReminderOn = prefs.getBool('sleep_reminder_on') ?? true;
        _dreamController.text = prefs.getString('sleep_dream_note') ?? '';
        userName = fetchedName;
      });
    }
  }

  Future<void> _saveLocalSleepData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('sleep_routine_completed', routineCompleted);
    await prefs.setInt('sleep_quality_index', selectedQualityIndex);
    await prefs.setInt('sleep_streak_count', sleepStreak);
    await prefs.setDouble('sleep_target_hours', targetSleepHours);
    await prefs.setBool('sleep_reminder_on', isReminderOn);
    await prefs.setString('sleep_dream_note', _dreamController.text);
  }

  void toggleLamp() {
    setState(() {
      isLampOn = !isLampOn;
      if (!isLampOn) {
        showGoodNight = true;
      }
    });
  }

  void completeRoutine() {
    if (routineCompleted < routineSteps.length) {
      setState(() {
        routineCompleted++;
        if (routineCompleted == routineSteps.length) {
          sleepStreak++;
        }
      });
      _saveLocalSleepData();
    }
  }

  void resetRoutine() {
    setState(() {
      routineCompleted = 0;
    });
    _saveLocalSleepData();
  }

  @override
  Widget build(BuildContext context) {
    double progress = routineSteps.isNotEmpty ? routineCompleted / routineSteps.length : 0.0;
    double safeTarget = targetSleepHours;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text(
          'Dream Sanctuary 🌙',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1E1B4B),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                const Icon(Icons.local_fire_department, color: Colors.amber, size: 18),
                const SizedBox(width: 4),
                Text(
                  '$sleepStreak Days',
                  style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ],
            ),
          )
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ScaleTransition(
                  scale: _pulseAnimation,
                  child: _heroCard(),
                ),
                const SizedBox(height: 28),
                const Center(
                  child: Text(
                    'Bedside Moon Lamp 🏮',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 16),
                _moonLampWidget(),
                const SizedBox(height: 32),
                _sectionTitle('Target Sleep & Rest Goal', Icons.track_changes_rounded),
                const SizedBox(height: 12),
                _interactiveTargetCard(safeTarget),
                const SizedBox(height: 24),
                _sectionTitle('How restorative was your rest?', Icons.auto_awesome),
                const SizedBox(height: 12),
                _sleepQualitySelector(),
                const SizedBox(height: 24),
                _sectionTitle('Nighttime Wind-Down Ritual', Icons.nights_stay_rounded),
                const SizedBox(height: 12),
                _interactiveRoutineCard(progress),
                const SizedBox(height: 24),
                _sectionTitle('Midnight Dream & Thought Journal', Icons.edit_note_rounded),
                const SizedBox(height: 12),
                _dreamJournalCard(),
                const SizedBox(height: 24),
                _sectionTitle('Bedside Notification Alarm', Icons.alarm_on_rounded),
                const SizedBox(height: 12),
                _reminderToggleCard(),
              ],
            ),
          ),
          IgnorePointer(
            ignoring: !showGoodNight,
            child: AnimatedOpacity(
              opacity: showGoodNight ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 600),
              child: Container(
                color: Colors.black.withValues(alpha: 0.92),
                width: double.infinity,
                height: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.nightlight_round, color: Colors.amber, size: 80),
                    const SizedBox(height: 20),
                    Text(
                      'Good Night, $userName ✨',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Have a peaceful and restorative sleep. 🌙',
                      style: TextStyle(fontSize: 14, color: Colors.white60),
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          showGoodNight = false;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F46E5),
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: const Text('Wake Up / Back to App', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF312E81), Color(0xFF4C1D95), Color(0xFF1E1B4B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  width: 115,
                  child: const Text(
                    'NIGHT SANCTUARY',
                    style: TextStyle(color: Color(0xFFA5B4FC), fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Unlock Deep Rest 🌌',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Calm your mind, follow your wind-down checklist, and drift into peaceful recovery.',
                  style: TextStyle(fontSize: 12, height: 1.4, color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: const Icon(Icons.nightlight_round, color: Color(0xFFFDE047), size: 42),
          ),
        ],
      ),
    );
  }

  Widget _moonLampWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: toggleLamp,
            child: AnimatedBuilder(
              animation: _lampGlowAnimation,
              builder: (context, child) {
                final double glowVal = _lampGlowAnimation.value;
                return Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: isLampOn
                          ? [
                        const Color(0xFFFEF08A),
                        const Color(0xFFFACC15),
                        const Color(0xFFCA8A04),
                      ]
                          : [
                        const Color(0xFF475569),
                        const Color(0xFF334155),
                        const Color(0xFF1E293B),
                      ],
                      stops: const [0.2, 0.6, 1.0],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isLampOn
                            ? Colors.amber.withValues(alpha: 0.6 * glowVal)
                            : Colors.black.withValues(alpha: 0.3),
                        blurRadius: isLampOn ? 35 : 10,
                        spreadRadius: isLampOn ? 8 : 0,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      isLampOn ? Icons.nightlight_round : Icons.brightness_2_rounded,
                      color: isLampOn ? const Color(0xFF713F12) : Colors.white54,
                      size: 55,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: Text(
              isLampOn ? '✨ Good Night, $userName ✨' : '🌙 Tap the Moon to Light Up',
              key: ValueKey<bool>(isLampOn),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isLampOn ? const Color(0xFFFDE047) : Colors.white60,
                letterSpacing: 1.1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _interactiveTargetCard(double safeTarget) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Nightly Sleep Goal', style: TextStyle(color: Colors.white70, fontSize: 13)),
              Text(
                '${safeTarget.toStringAsFixed(1)} Hours',
                style: const TextStyle(color: Color(0xFF818CF8), fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          Slider(
            value: safeTarget.clamp(4.0, 12.0),
            min: 4.0,
            max: 12.0,
            divisions: 16,
            activeColor: const Color(0xFF6366F1),
            inactiveColor: Colors.white10,
            onChanged: (val) {
              setState(() {
                targetSleepHours = val;
              });
              _saveLocalSleepData();
            },
          ),
        ],
      ),
    );
  }

  Widget _sleepQualitySelector() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(sleepQualities.length, (index) {
          bool isSelected = selectedQualityIndex == index;
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedQualityIndex = index;
              });
              _saveLocalSleepData();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF4338CA).withValues(alpha: 0.4) : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? const Color(0xFF818CF8) : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  Text(sleepQualities[index]['emoji']!, style: const TextStyle(fontSize: 26)),
                  const SizedBox(height: 4),
                  Text(
                    sleepQualities[index]['label']!,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? const Color(0xFFA5B4FC) : Colors.white60,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _interactiveRoutineCard(double progress) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          ...List.generate(routineSteps.length, (index) {
            bool done = index < routineCompleted;
            return Column(
              children: [
                Row(
                  children: [
                    Icon(
                      done ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
                      color: done ? const Color(0xFF34D399) : Colors.white30,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        routineSteps[index],
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: done ? FontWeight.bold : FontWeight.normal,
                          decoration: done ? TextDecoration.lineThrough : null,
                          color: done ? Colors.white38 : Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                if (index < routineSteps.length - 1)
                  Divider(height: 18, color: Colors.white.withValues(alpha: 0.05)),
              ],
            );
          }),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: Colors.white10,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF34D399)),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$routineCompleted of ${routineSteps.length} Completed',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF818CF8)),
              ),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: completeRoutine,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    child: const Text('Check Step', style: TextStyle(fontSize: 12)),
                  ),
                  const SizedBox(width: 6),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white54, size: 20),
                    onPressed: resetRoutine,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dreamJournalCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: TextField(
        controller: _dreamController,
        maxLines: 3,
        style: const TextStyle(color: Colors.white, fontSize: 13),
        onChanged: (val) => _saveLocalSleepData(),
        decoration: const InputDecoration(
          hintText: 'Write down your thoughts or dreams before drifting off...',
          hintStyle: TextStyle(color: Colors.white38, fontSize: 13),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _reminderToggleCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Row(
            children: [
              Icon(Icons.notifications_active_rounded, color: Color(0xFF818CF8), size: 22),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Bedside Reminder', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                  SizedBox(height: 2),
                  Text('Get notified at 10:30 PM daily', style: TextStyle(color: Colors.white54, fontSize: 11)),
                ],
              ),
            ],
          ),
          Switch(
            value: isReminderOn,
            activeThumbColor: const Color(0xFF34D399),
            onChanged: (val) {
              setState(() {
                isReminderOn = val;
              });
              _saveLocalSleepData();
            },
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF818CF8)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ],
    );
  }
}