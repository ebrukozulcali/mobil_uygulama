
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math';

class DailyPlanningPage extends StatefulWidget {
  const DailyPlanningPage({super.key});

  @override
  State<DailyPlanningPage> createState() => _DailyPlanningPageState();
}

class _DailyPlanningPageState extends State<DailyPlanningPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<String, List<Map<String, dynamic>>> _tasks = {};
  String _motivationalMessage = "";
  final List<String> _motivationalMessages = [
    "Bugün harika bir gün olacak!",
    "Kendine inan, her şey mümkün!",
    "Hedefine bir adım daha yaklaş!",
    "Her gün bir şanstır, değerlendir!",
    "Pozitif ol ve ışığını yay!"
  ];

  final List<String> _dailyTips = [
    "Su içmeyi unutmuyorsun değil mi?",
    "Egzersizler tamam mı?",
    "Bugün biraz kitap okumayı dene!",
    "Telefonu bir kenara bırak ve doğaya çık!",
    "Bugün kendine biraz vakit ayır!"
  ];

  @override
  void initState() {
    super.initState();
    _loadTasks();
    _loadMotivationalMessage();
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = prefs.getString('tasks');
    if (tasksJson != null) {
      setState(() {
        _tasks = Map<String, List<Map<String, dynamic>>>.from(
          json.decode(tasksJson).map(
            (key, value) => MapEntry(
              key,
              List<Map<String, dynamic>>.from(value),
            ),
          ),
        );
      });
    }
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('tasks', json.encode(_tasks));
  }

  Future<void> _loadMotivationalMessage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedDate = prefs.getString('lastMessageDate') ?? '';
    final savedMessage = prefs.getString('motivationalMessage') ?? '';

    if (savedDate == DateTime.now().toIso8601String().split('T').first) {
      setState(() {
        _motivationalMessage = savedMessage;
      });
    } else {
      _selectRandomMessage();
    }
  }

  Future<void> _selectRandomMessage() async {
    final prefs = await SharedPreferences.getInstance();
    final random = Random();
    final randomIndex = random.nextInt(_motivationalMessages.length);

    setState(() {
      _motivationalMessage = _motivationalMessages[randomIndex];
    });

    await prefs.setString('lastMessageDate', DateTime.now().toIso8601String().split('T').first);
    await prefs.setString('motivationalMessage', _motivationalMessage);
  }

  void _addTask(String task) {
    final selectedDateKey = _selectedDay?.toIso8601String().split('T').first ?? '';
    setState(() {
      if (_tasks[selectedDateKey] == null) {
        _tasks[selectedDateKey] = [];
      }
      _tasks[selectedDateKey]?.add({'title': task, 'isCompleted': false});
    });
    _saveTasks();
  }

  void _toggleTaskCompletion(int index) {
    final selectedDateKey = _selectedDay?.toIso8601String().split('T').first ?? '';
    setState(() {
      _tasks[selectedDateKey]?[index]['isCompleted'] =
          !_tasks[selectedDateKey]![index]['isCompleted'];
    });
    _saveTasks();
  }

  void _showAddTaskDialog() {
    final TextEditingController taskController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Yeni Görev Ekle"),
          content: TextField(
            controller: taskController,
            decoration: const InputDecoration(labelText: "Görev"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (taskController.text.isNotEmpty) {
                  _addTask(taskController.text);
                }
                Navigator.of(context).pop();
              },
              child: const Text("Ekle"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("İptal"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTaskList() {
    final selectedDateKey = _selectedDay?.toIso8601String().split('T').first ?? '';
    final tasksForTheDay = _tasks[selectedDateKey] ?? [];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tasksForTheDay.length,
      itemBuilder: (context, index) {
        final task = tasksForTheDay[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 4,
          child: ListTile(
            leading: Checkbox(
              value: task['isCompleted'],
              onChanged: (_) {
                _toggleTaskCompletion(index);
              },
            ),
            title: Text(
              task['title'],
              style: TextStyle(
                decoration: task['isCompleted'] ? TextDecoration.lineThrough : null,
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                setState(() {
                  tasksForTheDay.removeAt(index);
                });
                _saveTasks();
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildMotivationalSection() {
    final colors = [
      Colors.orange.shade200,
      Colors.green.shade200,
      Colors.blue.shade200,
      Colors.pink.shade200,
      Colors.purple.shade200,
    ];
    final now = DateTime.now();
    final index = now.day % _motivationalMessages.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: colors[index],
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              blurRadius: 8.0,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.lightbulb, color: Colors.white, size: 30),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _motivationalMessages[index],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDailyTips() {
    return Container(
      height: 80,
      margin: const EdgeInsets.only(top: 10.0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _dailyTips.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 8.0),
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Center(
              child: Text(
                _dailyTips[index],
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/menuarkaplan.jpg',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  AppBar(
                    title: const Text("                  (❁´◡`❁)"),
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: TableCalendar(
                      focusedDay: _focusedDay,
                      firstDay: DateTime.utc(2000, 1, 1),
                      lastDay: DateTime.utc(2100, 12, 31),
                      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                      },
                      calendarStyle: CalendarStyle(
                        todayDecoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.8),
                          shape: BoxShape.circle,
                        ),
                        selectedDecoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.8),
                          shape: BoxShape.circle,
                        ),
                        weekendTextStyle: const TextStyle(color: Colors.red),
                        defaultTextStyle: const TextStyle(color: Colors.black),
                      ),
                      headerStyle: const HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                        titleTextStyle: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  const Divider(),
                  if (_selectedDay == null)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          "Bir gün seçin",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    )
                  else
                    _buildTaskList(),
                  _buildMotivationalSection(),
                  _buildDailyTips(),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _selectedDay == null
          ? null
          : FloatingActionButton(
              backgroundColor: Colors.blue,
              onPressed: _showAddTaskDialog,
              child: const Icon(Icons.add),
            ),
    );
  }
}


/*öneri yok diğer kısımlar tamam
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math';

class DailyPlanningPage extends StatefulWidget {
  const DailyPlanningPage({super.key});

  @override
  State<DailyPlanningPage> createState() => _DailyPlanningPageState();
}

class _DailyPlanningPageState extends State<DailyPlanningPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<String, List<Map<String, dynamic>>> _tasks = {};
  String _motivationalMessage = "";
  final List<String> _motivationalMessages = [
    "Bugün harika bir gün olacak!",
    "Kendine inan, her şey mümkün!",
    "Hedefine bir adım daha yaklaş!",
    "Her gün bir şanstır, değerlendir!",
    "Pozitif ol ve ışığını yay!"
  ];

  @override
  void initState() {
    super.initState();
    _loadTasks();
    _loadMotivationalMessage();
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = prefs.getString('tasks');
    if (tasksJson != null) {
      setState(() {
        _tasks = Map<String, List<Map<String, dynamic>>>.from(
          json.decode(tasksJson).map(
            (key, value) => MapEntry(
              key,
              List<Map<String, dynamic>>.from(value),
            ),
          ),
        );
      });
    }
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('tasks', json.encode(_tasks));
  }

  Future<void> _loadMotivationalMessage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedDate = prefs.getString('lastMessageDate') ?? '';
    final savedMessage = prefs.getString('motivationalMessage') ?? '';

    if (savedDate == DateTime.now().toIso8601String().split('T').first) {
      setState(() {
        _motivationalMessage = savedMessage;
      });
    } else {
      _selectRandomMessage();
    }
  }

  Future<void> _selectRandomMessage() async {
    final prefs = await SharedPreferences.getInstance();
    final random = Random();
    final randomIndex = random.nextInt(_motivationalMessages.length);

    setState(() {
      _motivationalMessage = _motivationalMessages[randomIndex];
    });

    await prefs.setString('lastMessageDate', DateTime.now().toIso8601String().split('T').first);
    await prefs.setString('motivationalMessage', _motivationalMessage);
  }

  void _addTask(String task) {
    final selectedDateKey = _selectedDay?.toIso8601String().split('T').first ?? '';
    setState(() {
      if (_tasks[selectedDateKey] == null) {
        _tasks[selectedDateKey] = [];
      }
      _tasks[selectedDateKey]?.add({'title': task, 'isCompleted': false});
    });
    _saveTasks();
  }

  void _toggleTaskCompletion(int index) {
    final selectedDateKey = _selectedDay?.toIso8601String().split('T').first ?? '';
    setState(() {
      _tasks[selectedDateKey]?[index]['isCompleted'] =
          !_tasks[selectedDateKey]![index]['isCompleted'];
    });
    _saveTasks();
  }

  void _showAddTaskDialog() {
    final TextEditingController taskController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Yeni Görev Ekle"),
          content: TextField(
            controller: taskController,
            decoration: const InputDecoration(labelText: "Görev"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (taskController.text.isNotEmpty) {
                  _addTask(taskController.text);
                }
                Navigator.of(context).pop();
              },
              child: const Text("Ekle"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("İptal"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTaskList() {
    final selectedDateKey = _selectedDay?.toIso8601String().split('T').first ?? '';
    final tasksForTheDay = _tasks[selectedDateKey] ?? [];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tasksForTheDay.length,
      itemBuilder: (context, index) {
        final task = tasksForTheDay[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 4,
          child: ListTile(
            leading: Checkbox(
              value: task['isCompleted'],
              onChanged: (_) {
                _toggleTaskCompletion(index);
              },
            ),
            title: Text(
              task['title'],
              style: TextStyle(
                decoration: task['isCompleted'] ? TextDecoration.lineThrough : null,
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                setState(() {
                  tasksForTheDay.removeAt(index);
                });
                _saveTasks();
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildMotivationalSection() {
    final colors = [
      Colors.orange.shade200,
      Colors.green.shade200,
      Colors.blue.shade200,
      Colors.pink.shade200,
      Colors.purple.shade200,
    ];
    final now = DateTime.now();
    final index = now.day % _motivationalMessages.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: colors[index],
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              blurRadius: 8.0,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.lightbulb, color: Colors.white, size: 30),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _motivationalMessages[index],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/menuarkaplan.jpg',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  AppBar(
                    title: const Text("Günlük Planlama ve Takvim"),
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: TableCalendar(
                      focusedDay: _focusedDay,
                      firstDay: DateTime.utc(2000, 1, 1),
                      lastDay: DateTime.utc(2100, 12, 31),
                      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                      },
                      calendarStyle: CalendarStyle(
                        todayDecoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.8),
                          shape: BoxShape.circle,
                        ),
                        selectedDecoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.8),
                          shape: BoxShape.circle,
                        ),
                        weekendTextStyle: const TextStyle(color: Colors.red),
                        defaultTextStyle: const TextStyle(color: Colors.black),
                      ),
                      headerStyle: const HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                        titleTextStyle: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  const Divider(),
                  if (_selectedDay == null)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          "Bir gün seçin",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    )
                  else
                    _buildTaskList(),
                  _buildMotivationalSection(),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _selectedDay == null
          ? null
          : FloatingActionButton(
              backgroundColor: Colors.blue,
              onPressed: _showAddTaskDialog,
              child: const Icon(Icons.add),
            ),
    );
  }
}*/


/*import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math';

class DailyPlanningPage extends StatefulWidget {
  const DailyPlanningPage({super.key});

  @override
  State<DailyPlanningPage> createState() => _DailyPlanningPageState();
}

class _DailyPlanningPageState extends State<DailyPlanningPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<String, List<Map<String, dynamic>>> _tasks = {};
  String _motivationalMessage = "";
  final List<String> _motivationalMessages = [
    "Bugün harika bir gün olacak!",
    "Kendine inan, her şey mümkün!",
    "Hedefine bir adım daha yaklaş!",
    "Her gün bir şanstır, değerlendir!",
    "Pozitif ol ve ışığını yay!"
  ];

  @override
  void initState() {
    super.initState();
    _loadTasks();
    _loadMotivationalMessage();
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = prefs.getString('tasks');
    if (tasksJson != null) {
      setState(() {
        _tasks = Map<String, List<Map<String, dynamic>>>.from(
          json.decode(tasksJson).map(
            (key, value) => MapEntry(
              key,
              List<Map<String, dynamic>>.from(value),
            ),
          ),
        );
      });
    }
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('tasks', json.encode(_tasks));
  }

  Future<void> _loadMotivationalMessage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedDate = prefs.getString('lastMessageDate') ?? '';
    final savedMessage = prefs.getString('motivationalMessage') ?? '';

    if (savedDate == DateTime.now().toIso8601String().split('T').first) {
      setState(() {
        _motivationalMessage = savedMessage;
      });
    } else {
      _selectRandomMessage();
    }
  }

  Future<void> _selectRandomMessage() async {
    final prefs = await SharedPreferences.getInstance();
    final random = Random();
    final randomIndex = random.nextInt(_motivationalMessages.length);

    setState(() {
      _motivationalMessage = _motivationalMessages[randomIndex];
    });

    await prefs.setString('lastMessageDate', DateTime.now().toIso8601String().split('T').first);
    await prefs.setString('motivationalMessage', _motivationalMessage);
  }

  void _addTask(String task) {
    final selectedDateKey = _selectedDay?.toIso8601String().split('T').first ?? '';
    setState(() {
      if (_tasks[selectedDateKey] == null) {
        _tasks[selectedDateKey] = [];
      }
      _tasks[selectedDateKey]?.add({'title': task, 'isCompleted': false});
    });
    _saveTasks();
  }

  void _toggleTaskCompletion(int index) {
    final selectedDateKey = _selectedDay?.toIso8601String().split('T').first ?? '';
    setState(() {
      _tasks[selectedDateKey]?[index]['isCompleted'] =
          !_tasks[selectedDateKey]![index]['isCompleted'];
    });
    _saveTasks();
  }

  void _showAddTaskDialog() {
    final TextEditingController taskController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Yeni Görev Ekle"),
          content: TextField(
            controller: taskController,
            decoration: const InputDecoration(labelText: "Görev"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (taskController.text.isNotEmpty) {
                  _addTask(taskController.text);
                }
                Navigator.of(context).pop();
              },
              child: const Text("Ekle"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("İptal"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTaskList() {
    final selectedDateKey = _selectedDay?.toIso8601String().split('T').first ?? '';
    final tasksForTheDay = _tasks[selectedDateKey] ?? [];

    return ListView.builder(
      itemCount: tasksForTheDay.length,
      itemBuilder: (context, index) {
        final task = tasksForTheDay[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 4,
          child: ListTile(
            leading: Checkbox(
              value: task['isCompleted'],
              onChanged: (_) {
                _toggleTaskCompletion(index);
              },
            ),
            title: Text(
              task['title'],
              style: TextStyle(
                decoration: task['isCompleted'] ? TextDecoration.lineThrough : null,
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                setState(() {
                  tasksForTheDay.removeAt(index);
                });
                _saveTasks();
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildMotivationalSection() {
  // Günlük motivasyon cümleleri
  final List<String> motivations = [
    "Her gün bir şanstır, değerlendir!",
    "Başarı, küçük adımlarla gelir.",
    "Bugün kendine bir iyilik yap!",
    "Hayallerin peşinden gitmekten korkma!",
    "Gülümse, çünkü hayat güzel!"
  ];

  // Günlük farklı bir renk seçimi
  final List<Color> colors = [
    Colors.orange.shade200,
    Colors.green.shade200,
    Colors.blue.shade200,
    Colors.pink.shade200,
    Colors.purple.shade200,
  ];

  // Günü baz alarak renk ve cümle seçimi
  final DateTime now = DateTime.now();
  final int index = now.day % motivations.length; // Her gün farklı bir cümle ve renk

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    child: Container(
      decoration: BoxDecoration(
        color: colors[index],
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            blurRadius: 8.0,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.lightbulb,
              color: Colors.white,
              size: 30,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                motivations[index],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildRecommendations() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Günlük Öneriler",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
          ),
          const SizedBox(height: 8),
          Row(
            children: const [
              Icon(Icons.local_drink, color: Colors.orange),
              SizedBox(width: 8),
              Text("Günde en az 3 litre su için."),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: const [
              Icon(Icons.fitness_center, color: Colors.green),
              SizedBox(width: 8),
              Text("Düzenli egzersiz yapmayı unutmayın."),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: const [
              Icon(Icons.menu_book, color: Colors.purple),
              SizedBox(width: 8),
              Text("Günde en az 30 dakika kitap okuyun."),
            ],
          ),
        ],
      ),
    );
  }
  @override
Widget build(BuildContext context) {
  return Scaffold(
    body: Stack(
      children: [
        // Arka plan görseli
        Positioned.fill(
          child: Image.asset(
            'assets/menuarkaplan.jpg',
            fit: BoxFit.cover,
          ),
        ),
        SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Uygulama başlığı
                AppBar(
                  title: const Text("Günlük Planlama ve Takvim"),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                ),
                // Takvim bölümü
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TableCalendar(
                    focusedDay: _focusedDay,
                    firstDay: DateTime.utc(2000, 1, 1),
                    lastDay: DateTime.utc(2100, 12, 31),
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    },
                    calendarStyle: CalendarStyle(
                      todayDecoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                      weekendTextStyle: const TextStyle(color: Colors.red),
                      defaultTextStyle: const TextStyle(color: Colors.black),
                    ),
                    headerStyle: const HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const Divider(),
                // Görevler veya seçilmemiş gün mesajı
                _selectedDay == null
                    ? const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(
                          child: Text(
                            "Bir gün seçin",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: _buildTaskList(),
                      ),
                const Divider(),
                // Motivasyon mesajı
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: _buildMotivationalSection(),
                ),
                // Günlük öneriler
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: _buildRecommendations(),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
    floatingActionButton: _selectedDay == null
        ? null
        : FloatingActionButton(
            backgroundColor: Colors.blue,
            onPressed: _showAddTaskDialog,
            child: const Icon(Icons.add),
          ),
  );
}
}*/

  

/* motivasyon yok 
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class DailyPlanningPage extends StatefulWidget {
  const DailyPlanningPage({super.key});

  @override
  State<DailyPlanningPage> createState() => _DailyPlanningPageState();
}

class _DailyPlanningPageState extends State<DailyPlanningPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<String, List<Map<String, dynamic>>> _tasks = {};

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = prefs.getString('tasks');
    if (tasksJson != null) {
      setState(() {
        _tasks = Map<String, List<Map<String, dynamic>>>.from(
          json.decode(tasksJson).map(
            (key, value) => MapEntry(
              key,
              List<Map<String, dynamic>>.from(value),
            ),
          ),
        );
      });
    }
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('tasks', json.encode(_tasks));
  }

  void _addTask(String task) {
    final selectedDateKey = _selectedDay?.toIso8601String().split('T').first ?? '';
    setState(() {
      if (_tasks[selectedDateKey] == null) {
        _tasks[selectedDateKey] = [];
      }
      _tasks[selectedDateKey]?.add({'title': task, 'isCompleted': false});
    });
    _saveTasks();
  }

  void _toggleTaskCompletion(int index) {
    final selectedDateKey = _selectedDay?.toIso8601String().split('T').first ?? '';
    setState(() {
      _tasks[selectedDateKey]?[index]['isCompleted'] = !_tasks[selectedDateKey]![index]['isCompleted'];
    });
    _saveTasks();
  }

  void _showAddTaskDialog() {
    final TextEditingController taskController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Yeni Görev Ekle"),
          content: TextField(
            controller: taskController,
            decoration: const InputDecoration(labelText: "Görev"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (taskController.text.isNotEmpty) {
                  _addTask(taskController.text);
                }
                Navigator.of(context).pop();
              },
              child: const Text("Ekle"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("İptal"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTaskList() {
    final selectedDateKey = _selectedDay?.toIso8601String().split('T').first ?? '';
    final tasksForTheDay = _tasks[selectedDateKey] ?? [];

    return ListView.builder(
      itemCount: tasksForTheDay.length,
      itemBuilder: (context, index) {
        final task = tasksForTheDay[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 4,
          child: ListTile(
            leading: Checkbox(
              value: task['isCompleted'],
              onChanged: (_) {
                _toggleTaskCompletion(index);
              },
            ),
            title: Text(
              task['title'],
              style: TextStyle(
                decoration: task['isCompleted'] ? TextDecoration.lineThrough : null,
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                setState(() {
                  tasksForTheDay.removeAt(index);
                });
                _saveTasks();
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecommendations() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Günlük Öneriler",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
          ),
          const SizedBox(height: 8),
          Row(
            children: const [
              Icon(Icons.local_drink, color: Colors.orange),
              SizedBox(width: 8),
              Text("Günde en az 3 litre su için."),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: const [
              Icon(Icons.fitness_center, color: Colors.green),
              SizedBox(width: 8),
              Text("Düzenli egzersiz yapmayı unutmayın."),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: const [
              Icon(Icons.menu_book, color: Colors.purple),
              SizedBox(width: 8),
              Text("Günde en az 30 dakika kitap okuyun."),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Arka Plan
          Positioned.fill(
            child: Image.asset(
              'assets/menuarkaplan.jpg', // Burada arka plan için kullandığınız görselin yolunu girin
              fit: BoxFit.cover,
            ),
          ),
          // İçerik
          Column(
            children: [
              AppBar(
                title: const Text("Günlük Planlama ve Takvim"),
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
              TableCalendar(
                focusedDay: _focusedDay,
                firstDay: DateTime.utc(2000, 1, 1),
                lastDay: DateTime.utc(2100, 12, 31),
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.8),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.8),
                    shape: BoxShape.circle,
                  ),
                  weekendTextStyle: const TextStyle(color: Colors.red),
                  defaultTextStyle: const TextStyle(color: Colors.black),
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const Divider(),
              Expanded(
                child: _selectedDay == null
                    ? const Center(
                        child: Text(
                          "Bir gün seçin",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      )
                    : _buildTaskList(),
              ),
              const Divider(),
              _buildRecommendations(),
            ],
          ),
        ],
      ),
      floatingActionButton: _selectedDay == null
          ? null
          : FloatingActionButton(
              backgroundColor: Colors.blue,
              onPressed: _showAddTaskDialog,
              child: const Icon(Icons.add),
            ),
    );
  }
}*/




/*çalışıyor(ai yok)
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class DailyPlanningPage extends StatefulWidget {
  const DailyPlanningPage({super.key});

  @override
  State<DailyPlanningPage> createState() => _DailyPlanningPageState();
}

class _DailyPlanningPageState extends State<DailyPlanningPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<String, List<Map<String, dynamic>>> _tasks = {};

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = prefs.getString('tasks');
    if (tasksJson != null) {
      setState(() {
        _tasks = Map<String, List<Map<String, dynamic>>>.from(
          json.decode(tasksJson).map(
            (key, value) => MapEntry(
              key,
              List<Map<String, dynamic>>.from(value),
            ),
          ),
        );
      });
    }
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('tasks', json.encode(_tasks));
  }

  void _addTask(String task) {
    final selectedDateKey = _selectedDay?.toIso8601String().split('T').first ?? '';
    setState(() {
      if (_tasks[selectedDateKey] == null) {
        _tasks[selectedDateKey] = [];
      }
      _tasks[selectedDateKey]?.add({'title': task, 'isCompleted': false});
    });
    _saveTasks();
  }

  void _toggleTaskCompletion(int index) {
    final selectedDateKey = _selectedDay?.toIso8601String().split('T').first ?? '';
    setState(() {
      _tasks[selectedDateKey]?[index]['isCompleted'] = !_tasks[selectedDateKey]![index]['isCompleted'];
    });
    _saveTasks();
  }

  void _showAddTaskDialog() {
    final TextEditingController taskController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Yeni Görev Ekle"),
          content: TextField(
            controller: taskController,
            decoration: const InputDecoration(labelText: "Görev"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (taskController.text.isNotEmpty) {
                  _addTask(taskController.text);
                }
                Navigator.of(context).pop();
              },
              child: const Text("Ekle"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("İptal"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTaskList() {
    final selectedDateKey = _selectedDay?.toIso8601String().split('T').first ?? '';
    final tasksForTheDay = _tasks[selectedDateKey] ?? [];

    return ListView.builder(
      itemCount: tasksForTheDay.length,
      itemBuilder: (context, index) {
        final task = tasksForTheDay[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 4,
          child: ListTile(
            leading: Checkbox(
              value: task['isCompleted'],
              onChanged: (_) {
                _toggleTaskCompletion(index);
              },
            ),
            title: Text(
              task['title'],
              style: TextStyle(
                decoration: task['isCompleted'] ? TextDecoration.lineThrough : null,
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                setState(() {
                  tasksForTheDay.removeAt(index);
                });
                _saveTasks();
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Günlük Planlama ve Takvim"),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          TableCalendar(
            focusedDay: _focusedDay,
            firstDay: DateTime.utc(2000, 1, 1),
            lastDay: DateTime.utc(2100, 12, 31),
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              weekendTextStyle: const TextStyle(color: Colors.red),
              defaultTextStyle: const TextStyle(color: Colors.black),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
          const Divider(),
          Expanded(
            child: _selectedDay == null
                ? const Center(
                    child: Text(
                      "Bir gün seçin",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  )
                : _buildTaskList(),
          ),
        ],
      ),
      floatingActionButton: _selectedDay == null
          ? null
          : FloatingActionButton(
              backgroundColor: Colors.blue,
              onPressed: _showAddTaskDialog,
              child: const Icon(Icons.add),
            ),
    );
  }
}*/


/*Yapay zeka ama çalışmadı
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:convert';

class DailyPlanningPage extends StatefulWidget {
  const DailyPlanningPage({super.key});

  @override
  State<DailyPlanningPage> createState() => _DailyPlanningPageState();
}

class _DailyPlanningPageState extends State<DailyPlanningPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<String, List<Map<String, dynamic>>> _tasks = {};
  Interpreter? _interpreter;

  @override
  void initState() {
    super.initState();
    _loadTasks();
    _loadModel();
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = prefs.getString('tasks');
    if (tasksJson != null) {
      setState(() {
        _tasks = Map<String, List<Map<String, dynamic>>>.from(
          json.decode(tasksJson).map(
            (key, value) => MapEntry(
              key,
              List<Map<String, dynamic>>.from(value),
            ),
          ),
        );
      });
    }
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('tasks', json.encode(_tasks));
  }

  Future<void> _loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('1.tflite');
      if (!mounted) return;
      debugPrint("Yapay Zeka Modeli Başarıyla Yüklendi.");
    } catch (e) {
      debugPrint("Model Yükleme Hatası: $e");
    }
  }

  String _classifyTask(String task) {
    if (_interpreter == null) {
      debugPrint("Model yüklenmedi.");
      return "Bilinmeyen Öncelik";
    }

    List<double> input = List.filled(100, 0.0);
    for (int i = 0; i < task.length && i < 100; i++) {
      input[i] = task.codeUnitAt(i).toDouble();
    }
    List<double> output = List.filled(3, 0.0);

    _interpreter!.run([input], [output]);
    int maxIndex = output.indexOf(output.reduce((a, b) => a > b ? a : b));

    switch (maxIndex) {
      case 0:
        return "Düşük Öncelikli";
      case 1:
        return "Orta Öncelikli";
      case 2:
        return "Yüksek Öncelikli";
      default:
        return "Bilinmeyen Öncelik";
    }
  }

  void _addTask(String task) {
    final selectedDateKey = _selectedDay?.toIso8601String().split('T').first ?? '';
    final priority = _classifyTask(task);
    setState(() {
      if (_tasks[selectedDateKey] == null) {
        _tasks[selectedDateKey] = [];
      }
      _tasks[selectedDateKey]?.add({'title': task, 'isCompleted': false, 'priority': priority});
    });
    _saveTasks();
  }

  void _toggleTaskCompletion(int index) {
    final selectedDateKey = _selectedDay?.toIso8601String().split('T').first ?? '';
    setState(() {
      _tasks[selectedDateKey]?[index]['isCompleted'] = !_tasks[selectedDateKey]![index]['isCompleted'];
    });
    _saveTasks();
  }

  void _showAddTaskDialog() {
    final TextEditingController taskController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Yeni Görev Ekle"),
          content: TextField(
            controller: taskController,
            decoration: const InputDecoration(labelText: "Görev"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (taskController.text.isNotEmpty) {
                  _addTask(taskController.text);
                }
                Navigator.of(context).pop();
              },
              child: const Text("Ekle"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("İptal"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTaskList() {
    final selectedDateKey = _selectedDay?.toIso8601String().split('T').first ?? '';
    final tasksForTheDay = _tasks[selectedDateKey] ?? [];

    return ListView.builder(
      itemCount: tasksForTheDay.length,
      itemBuilder: (context, index) {
        final task = tasksForTheDay[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 4,
          child: ListTile(
            leading: Checkbox(
              value: task['isCompleted'],
              onChanged: (_) {
                _toggleTaskCompletion(index);
              },
            ),
            title: Text(
              task['title'],
              style: TextStyle(
                decoration: task['isCompleted'] ? TextDecoration.lineThrough : null,
              ),
            ),
            subtitle: Text("Öncelik: ${task['priority']}"),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                setState(() {
                  tasksForTheDay.removeAt(index);
                });
                _saveTasks();
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecommendations() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Yapay Zeka Önerileri",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
          ),
          const SizedBox(height: 8),
          const Text("• Günlük en az 3 litre su için."),
          const Text("• Günün başında bir yapılacaklar listesi oluşturun."),
          const Text("• Düzenli egzersiz yapmayı ihmal etmeyin."),
          const Text("• Kendinize dinlenme zamanı ayırın."),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Günlük Planlama ve Takvim"),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          TableCalendar(
            focusedDay: _focusedDay,
            firstDay: DateTime.utc(2000, 1, 1),
            lastDay: DateTime.utc(2100, 12, 31),
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              weekendTextStyle: const TextStyle(color: Colors.red),
              defaultTextStyle: const TextStyle(color: Colors.black),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
          const Divider(),
          Expanded(
            child: _selectedDay == null
                ? const Center(
                    child: Text(
                      "Bir gün seçin",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  )
                : _buildTaskList(),
          ),
          const Divider(),
          Expanded(
            child: _buildRecommendations(),
          ),
        ],
      ),
      floatingActionButton: _selectedDay == null
          ? null
          : FloatingActionButton(
              backgroundColor: Colors.blue,
              onPressed: _showAddTaskDialog,
              child: const Icon(Icons.add),
            ),
    );
  }
}*/