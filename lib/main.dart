import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const LifeSimApp());
}

class LifeSimApp extends StatelessWidget {
  const LifeSimApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Life Journey - Life Simulator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
      ),
      home: const LifeGameScreen(),
    );
  }
}

class LifeGameScreen extends StatefulWidget {
  const LifeGameScreen({super.key});

  @override
  State<LifeGameScreen> createState() => _LifeGameScreenState();
}

class _LifeGameScreenState extends State<LifeGameScreen> {
  // Stats
  int age = 0;
  int health = 100;
  int happiness = 100;
  int intelligence = 50;
  int looks = 50;
  int money = 0;
  String job = 'Infant';
  int salary = 0;
  int educationLevel = 0; // 0: None, 1: High School, 2: College, 3: Master/PhD
  bool isAlive = true;
  String causeOfDeath = '';

  final List<String> eventLogs = [];
  final Random _rnd = Random();

  @override
  void initState() {
    super.initState();
    _startNewLife();
  }

  void _startNewLife() {
    setState(() {
      age = 0;
      health = 80 + _rnd.nextInt(20);
      happiness = 80 + _rnd.nextInt(20);
      intelligence = 30 + _rnd.nextInt(50);
      looks = 30 + _rnd.nextInt(60);
      money = 0;
      job = 'Infant';
      salary = 0;
      educationLevel = 0;
      isAlive = true;
      causeOfDeath = '';
      eventLogs.clear();
      eventLogs.add('👶 Welcome to the world! You were born healthy.');
    });
  }

  void _clampStats() {
    health = health.clamp(0, 100);
    happiness = happiness.clamp(0, 100);
    intelligence = intelligence.clamp(0, 100);
    looks = looks.clamp(0, 100);
    if (money < -50000) money = -50000;

    if (health <= 0 && isAlive) {
      isAlive = false;
      causeOfDeath = 'died of severe illness / poor health';
      eventLogs.insert(0, '⚰️ At age $age, you $causeOfDeath. Rest in peace.');
    }
  }

  void _ageUp() {
    if (!isAlive) return;

    setState(() {
      age++;
      // Natural health aging
      if (age > 40) {
        health -= (1 + _rnd.nextInt(3));
      }
      if (age > 75) {
        health -= (2 + _rnd.nextInt(5));
      }

      // Income & expenses
      if (salary > 0) {
        int taxAndLiving = (salary * 0.35).round() + 500;
        int netEarn = salary - taxAndLiving;
        money += netEarn;
      }

      // School & Milestones
      if (age == 6) {
        eventLogs.insert(0, '🎒 Age 6: You started primary school.');
      } else if (age == 18) {
        educationLevel = max(educationLevel, 1);
        job = 'High School Graduate';
        eventLogs.insert(0, '🎓 Age 18: You graduated from High School!');
      }

      // Random annual events
      _triggerRandomLifeEvent();

      // Check longevity death
      if (age >= 100 || (age > 70 && _rnd.nextInt(120 - age) == 0)) {
        if (isAlive) {
          isAlive = false;
          causeOfDeath = 'passed away peacefully of old age';
          eventLogs.insert(0, '🕊️ At age $age, you $causeOfDeath.');
        }
      }

      _clampStats();
    });
  }

  void _triggerRandomLifeEvent() {
    int roll = _rnd.nextInt(100);
    if (roll < 15) {
      // Sickness / Accident
      health -= 15 + _rnd.nextInt(20);
      happiness -= 10;
      eventLogs.insert(0, '🤒 Age $age: You caught a severe seasonal flu and felt terrible.');
    } else if (roll < 30) {
      // Lucky moment
      int find = 50 + _rnd.nextInt(200);
      money += find;
      happiness += 10;
      eventLogs.insert(0, '🍀 Age $age: You found \$$find on the sidewalk!');
    } else if (roll < 45 && age >= 16) {
      // Social / Romance
      happiness += 15;
      eventLogs.insert(0, '❤️ Age $age: You had an unforgettable date with someone special.');
    } else if (roll < 60 && age >= 22 && salary > 0) {
      // Work bonus or drama
      int bonus = (salary * 0.15).round();
      money += bonus;
      happiness += 10;
      eventLogs.insert(0, '💼 Age $age: Great work review! You received a bonus of \$$bonus.');
    } else {
      eventLogs.insert(0, '📅 Age $age: Another year has passed smoothly.');
    }
  }

  // Activities
  void _studyHard() {
    if (!isAlive) return;
    setState(() {
      intelligence += 5 + _rnd.nextInt(5);
      happiness -= 3;
      eventLogs.insert(0, '📚 You spent months studying and reading books. (+Smart)');
      _clampStats();
    });
  }

  void _gymWorkout() {
    if (!isAlive) return;
    setState(() {
      health += 6 + _rnd.nextInt(6);
      looks += 3;
      happiness += 4;
      money -= 20;
      eventLogs.insert(0, '🏋️ You hit the gym consistently. (+Health, +Looks)');
      _clampStats();
    });
  }

  void _goOnVacation() {
    if (!isAlive) return;
    if (money < 1000) {
      _showToast('Not enough money! A vacation costs \$1,000.');
      return;
    }
    setState(() {
      money -= 1000;
      happiness += 25;
      health += 5;
      eventLogs.insert(0, '🏖️ You took an amazing luxury vacation to a tropical island. (+Happy)');
      _clampStats();
    });
  }

  void _goToDoctor() {
    if (!isAlive) return;
    if (money < 200 && age >= 18) {
      _showToast('Not enough money! Doctor consultation costs \$200.');
      return;
    }
    setState(() {
      if (age >= 18) money -= 200;
      health += 20 + _rnd.nextInt(15);
      eventLogs.insert(0, '🩺 The doctor treated your ailments thoroughly. (+Health)');
      _clampStats();
    });
  }

  void _applyUniversity() {
    if (!isAlive) return;
    if (age < 18) {
      _showToast('You must be at least 18 years old to attend University.');
      return;
    }
    if (educationLevel >= 2) {
      _showToast('You already graduated from University!');
      return;
    }
    if (intelligence < 50) {
      _showToast('Your intelligence is too low (<50). Study more to qualify!');
      return;
    }
    setState(() {
      educationLevel = 2;
      money -= 8000;
      intelligence += 15;
      job = 'College Student';
      eventLogs.insert(0, '🎓 Enrolled and graduated from University! (+Smart)');
      _clampStats();
    });
  }

  void _applyJob(String title, int pay, int requiredEdu, int requiredInt) {
    if (!isAlive) return;
    if (age < 18) {
      _showToast('You must be at least 18 to work full-time!');
      return;
    }
    if (educationLevel < requiredEdu) {
      _showToast('Higher education required for this role.');
      return;
    }
    if (intelligence < requiredInt) {
      _showToast('Insufficient intelligence for this position.');
      return;
    }

    setState(() {
      job = title;
      salary = pay;
      happiness += 10;
      eventLogs.insert(0, '🎉 Hired as $title earning \$$pay / year!');
      _clampStats();
    });
  }

  void _playLottery() {
    if (!isAlive) return;
    if (money < 50) {
      _showToast('Ticket costs \$50.');
      return;
    }
    setState(() {
      money -= 50;
      int winRoll = _rnd.nextInt(100);
      if (winRoll > 95) {
        int jackpot = 25000 + _rnd.nextInt(50000);
        money += jackpot;
        happiness += 35;
        eventLogs.insert(0, '🎰 JACKPOT! You won \$$jackpot in the lottery!!');
      } else if (winRoll > 70) {
        int smallWin = 100 + _rnd.nextInt(200);
        money += smallWin;
        happiness += 10;
        eventLogs.insert(0, '🎫 Nice! You won \$$smallWin on your scratch ticket.');
      } else {
        eventLogs.insert(0, '❌ Lottery ticket was a dud. Better luck next time.');
      }
      _clampStats();
    });
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        backgroundColor: const Color(0xFF374151),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('🌟 Life Journey Sim', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1E293B),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reincarnate / Restart',
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: const Color(0xFF1E293B),
                  title: const Text('Start New Life?'),
                  content: const Text('Are you sure you want to end this life and reincarnate?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                    FilledButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _startNewLife();
                      },
                      child: const Text('Restart'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header: Age, Job & Bank
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: const Color(0xFF1E293B),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Age: $age', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                      Text(job, style: TextStyle(fontSize: 14, color: Colors.indigoAccent[100])),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${money.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: money >= 0 ? Colors.greenAccent : Colors.redAccent,
                        ),
                      ),
                      Text('Salary: \$$salary/yr', style: const TextStyle(fontSize: 13, color: Colors.white70)),
                    ],
                  )
                ],
              ),
            ),

            // Stat Bars
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF334155)),
              ),
              child: Column(
                children: [
                  _buildStatRow('❤️ Health', health, Colors.redAccent),
                  const SizedBox(height: 8),
                  _buildStatRow('😄 Happiness', happiness, Colors.amberAccent),
                  const SizedBox(height: 8),
                  _buildStatRow('🧠 Smarts', intelligence, Colors.lightBlueAccent),
                  const SizedBox(height: 8),
                  _buildStatRow('✨ Looks', looks, Colors.pinkAccent),
                ],
              ),
            ),

            // Action Quick Buttons Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  _buildActionButton('📚 Study', _studyHard, Colors.blueGrey),
                  _buildActionButton('🏋️ Gym', _gymWorkout, Colors.orange),
                  _buildActionButton('🩺 Doctor', _goToDoctor, Colors.teal),
                  _buildActionButton('🏖️ Vacation', _goOnVacation, Colors.purple),
                  _buildActionButton('💼 Career', () => _showCareersDialog(), Colors.indigo),
                  _buildActionButton('🎰 Lottery', _playLottery, Colors.amber[800]!),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Life Event Feed
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF111827),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF1F2937)),
                ),
                child: ListView.separated(
                  itemCount: eventLogs.length,
                  separatorBuilder: (_, __) => const Divider(color: Color(0xFF1F2937), height: 8),
                  itemBuilder: (context, index) {
                    final item = eventLogs[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      child: Text(
                        item,
                        style: TextStyle(
                          fontSize: 14,
                          color: index == 0 ? Colors.white : Colors.white60,
                          fontWeight: index == 0 ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Big Age Up Button
            Padding(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: isAlive ? const Color(0xFF6366F1) : Colors.grey[700],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  icon: Icon(isAlive ? Icons.cake : Icons.refresh),
                  label: Text(
                    isAlive ? 'Age Up (+1 Year)' : 'Reincarnate (New Life)',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    if (isAlive) {
                      _ageUp();
                    } else {
                      _startNewLife();
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, int value, Color color) {
    return Row(
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: value / 100.0,
              backgroundColor: const Color(0xFF0F172A),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 10,
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 36,
          child: Text(
            '$value%',
            textAlign: TextAlign.end,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white70),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(String label, VoidCallback onPressed, Color color) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.2),
        foregroundColor: color,
        elevation: 0,
        side: BorderSide(color: color.withOpacity(0.5)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      ),
      onPressed: isAlive ? onPressed : null,
      child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
    );
  }

  void _showCareersDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('💼 Education & Careers', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Text('🎓', style: TextStyle(fontSize: 24)),
                  title: const Text('Attend University (Tuition: \$8,000)', style: TextStyle(color: Colors.white)),
                  subtitle: const Text('Requires Smarts >= 50. Opens higher career ladders.', style: TextStyle(color: Colors.white60)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white50),
                  onTap: () {
                    Navigator.pop(ctx);
                    _applyUniversity();
                  },
                ),
                const Divider(color: Color(0xFF334155)),
                _buildJobTile(ctx, 'Fast Food Worker', 18000, 0, 10, '🍔'),
                _buildJobTile(ctx, 'Junior Graphic Designer', 35000, 1, 30, '🎨'),
                _buildJobTile(ctx, 'Software Engineer', 85000, 2, 60, '💻'),
                _buildJobTile(ctx, 'Medical Doctor', 160000, 2, 80, '🩺'),
                _buildJobTile(ctx, 'Corporate CEO', 320000, 2, 90, '👑'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildJobTile(BuildContext ctx, String title, int salary, int reqEdu, int reqInt, String icon) {
    return ListTile(
      leading: Text(icon, style: const TextStyle(fontSize: 24)),
      title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      subtitle: Text('Salary: \$$salary/yr • Requires Edu lvl $reqEdu, Smarts $reqInt', style: const TextStyle(color: Colors.white60)),
      trailing: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1)),
        onPressed: () {
          Navigator.pop(ctx);
          _applyJob(title, salary, reqEdu, reqInt);
        },
        child: const Text('Apply', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
