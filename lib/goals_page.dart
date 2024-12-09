
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:developer'; // Loglama için
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart'; // Video player için gerekli
import 'models/goal.dart';

class GoalsPage extends StatefulWidget {
  const GoalsPage({super.key});

  @override
  GoalsPageState createState() => GoalsPageState();
}

class GoalsPageState extends State<GoalsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late VideoPlayerController _videoController; // Video controller
  List<Goal> weeklyGoals = [];
  List<Goal> monthlyGoals = [];
  List<Goal> yearlyGoals = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Video controller'ı başlat
    _videoController = VideoPlayerController.asset('assets/hedef.mp4')
      ..initialize().then((_) {
        _videoController.setLooping(true);
        _videoController.play();
        setState(() {});
      });

    _loadGoals();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _videoController.dispose(); // Video controller'ı temizle
    super.dispose();
  }

  Future<void> _loadGoals() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      weeklyGoals = _loadGoalList(prefs.getString('weeklyGoals'));
      monthlyGoals = _loadGoalList(prefs.getString('monthlyGoals'));
      yearlyGoals = _loadGoalList(prefs.getString('yearlyGoals'));
    });

    // Yüklenen hedefleri logla
    log("Yüklenen Weekly Goals: ${json.encode(weeklyGoals.map((goal) => goal.toJson()).toList())}");
    log("Yüklenen Monthly Goals: ${json.encode(monthlyGoals.map((goal) => goal.toJson()).toList())}");
    log("Yüklenen Yearly Goals: ${json.encode(yearlyGoals.map((goal) => goal.toJson()).toList())}");
  }

  List<Goal> _loadGoalList(String? goalsJson) {
    if (goalsJson == null) return [];
    final List<dynamic> decoded = json.decode(goalsJson);
    return decoded.map((json) => Goal.fromJson(json)).toList();
  }

  Future<void> _saveGoals() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(
        'weeklyGoals', json.encode(weeklyGoals.map((goal) => goal.toJson()).toList()));
    prefs.setString(
        'monthlyGoals', json.encode(monthlyGoals.map((goal) => goal.toJson()).toList()));
    prefs.setString(
        'yearlyGoals', json.encode(yearlyGoals.map((goal) => goal.toJson()).toList()));

    // Kayıt edilen hedefleri logla
    log("Kaydedilen Weekly Goals: ${json.encode(weeklyGoals.map((goal) => goal.toJson()).toList())}", name: "WeeklyGoals");
    log("Kaydedilen Monthly Goals: ${json.encode(monthlyGoals.map((goal) => goal.toJson()).toList())}", name: "MonthlyGoals");
    log("Kaydedilen Yearly Goals: ${json.encode(yearlyGoals.map((goal) => goal.toJson()).toList())}", name: "YearlyGoals");
  }

  void _addGoal(String title) {
    final currentTab = _tabController.index;
    setState(() {
      if (currentTab == 0) {
        weeklyGoals.add(Goal(title: title));
      } else if (currentTab == 1) {
        monthlyGoals.add(Goal(title: title));
      } else if (currentTab == 2) {
        yearlyGoals.add(Goal(title: title));
      }
    });
    _saveGoals();
  }

  void _toggleGoalCompletion(Goal goal) {
    setState(() {
      goal.isCompleted = !goal.isCompleted;
    });
    _saveGoals();
  }

  void _deleteGoal(Goal goal) {
    final currentTab = _tabController.index;
    setState(() {
      if (currentTab == 0) {
        weeklyGoals.remove(goal);
      } else if (currentTab == 1) {
        monthlyGoals.remove(goal);
      } else if (currentTab == 2) {
        yearlyGoals.remove(goal);
      }
    });
    _saveGoals();
  }

  void _showAddGoalDialog() {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Yeni Hedef Ekle"),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'Hedef'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  _addGoal(controller.text);
                }
                Navigator.of(context).pop();
              },
              child: const Text('Ekle'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('İptal'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hedefler"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Haftalık'),
            Tab(text: 'Aylık'),
            Tab(text: 'Yıllık'),
          ],
        ),
      ),
      body: Stack(
        children: [
          // Video arka planı
          Positioned.fill(
            child: _videoController.value.isInitialized
                ? FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _videoController.value.size.width,
                      height: _videoController.value.size.height,
                      child: VideoPlayer(_videoController),
                    ),
                  )
                : const Center(child: CircularProgressIndicator()),
          ),
          // İçerik
          TabBarView(
            controller: _tabController,
            children: [
              _buildGoalsList("Haftalık Hedefler", weeklyGoals),
              _buildGoalsList("Aylık Hedefler", monthlyGoals),
              _buildGoalsList("Yıllık Hedefler", yearlyGoals),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddGoalDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildGoalsList(String title, List<Goal> goals) {
    return ListView.builder(
      itemCount: goals.length,
      itemBuilder: (context, index) {
        final goal = goals[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 4,
          child: ListTile(
            title: Text(
              goal.title,
              style: TextStyle(
                decoration: goal.isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Checkbox(
                  value: goal.isCompleted,
                  onChanged: (_) => _toggleGoalCompletion(goal),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteGoal(goal),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
