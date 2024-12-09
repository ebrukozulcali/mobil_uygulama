
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BudgetPaymentsPage extends StatefulWidget {
  const BudgetPaymentsPage({super.key});

  @override
  State<BudgetPaymentsPage> createState() => _BudgetPaymentsPageState();
}

class _BudgetPaymentsPageState extends State<BudgetPaymentsPage> {
  double _monthlyLimit = 0.0;
  double _fixedIncome = 0.0;
  double _fixedExpenses = 0.0;
  double _otherIncome = 0.0;
  double _otherExpenses = 0.0;
  double _totalExpenses = 0.0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _monthlyLimit = prefs.getDouble('monthlyLimit') ?? 0.0;
      _fixedIncome = prefs.getDouble('fixedIncome') ?? 0.0;
      _fixedExpenses = prefs.getDouble('fixedExpenses') ?? 0.0;
      _otherIncome = prefs.getDouble('otherIncome') ?? 0.0;
      _otherExpenses = prefs.getDouble('otherExpenses') ?? 0.0;
      _totalExpenses = prefs.getDouble('totalExpenses') ?? 0.0;
    });
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('monthlyLimit', _monthlyLimit);
    await prefs.setDouble('fixedIncome', _fixedIncome);
    await prefs.setDouble('fixedExpenses', _fixedExpenses);
    await prefs.setDouble('otherIncome', _otherIncome);
    await prefs.setDouble('otherExpenses', _otherExpenses);
    await prefs.setDouble('totalExpenses', _totalExpenses);
  }

  void _showAddDialog(String title, String key) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            title,
            style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: "Bir değer girin",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("İptal"),
            ),
            TextButton(
              onPressed: () {
                final value = double.tryParse(controller.text) ?? 0.0;
                setState(() {
                  if (key == 'monthlyLimit') {
                    _monthlyLimit = value;
                  } else if (key == 'fixedIncome') {
                    _fixedIncome = value;
                  } else if (key == 'fixedExpenses') {
                    _fixedExpenses = value;
                  } else if (key == 'otherIncome') {
                    _otherIncome = value;
                  } else if (key == 'otherExpenses') {
                    _otherExpenses = value;
                  }
                  _totalExpenses = _fixedExpenses + _otherExpenses;
                });
                _saveData();
                Navigator.of(context).pop();
              },
              child: const Text("Kaydet"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSummaryTile(String title, double value, String key, Color color) {
    return Card(
      color: color.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(color: color.withOpacity(0.5), width: 1.5),
      ),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "${value.toStringAsFixed(2)} ₺",
              style: TextStyle(color: color),
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.grey),
              onPressed: () => _showAddDialog(title, key),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double totalIncome = _fixedIncome + _otherIncome;
    final double remainingBudget = _monthlyLimit - _totalExpenses;

    return Scaffold(
      body: Stack(
        children: [
          // Arka Plan
          Positioned.fill(
            child: Image.asset(
              'assets/menuarkaplan.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Column(
            children: [
              AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                title: const Text(
                  "Bütçe ve Ödemeler",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                backgroundColor: const Color.fromARGB(255, 123, 132, 19),
                elevation: 0,
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildSummaryTile("Tahmini Aylık Harcama Limiti", _monthlyLimit,
                            'monthlyLimit', Colors.orange),
                        _buildSummaryTile("Sabit Gelirler", _fixedIncome, 'fixedIncome',
                            Colors.green),
                        _buildSummaryTile("Sabit Giderler", _fixedExpenses, 'fixedExpenses',
                            Colors.red),
                        _buildSummaryTile("Diğer Gelirler", _otherIncome, 'otherIncome',
                            Colors.blue),
                        _buildSummaryTile("Diğer Giderler", _otherExpenses, 'otherExpenses',
                            Colors.purple),
                        const Divider(height: 30, color: Colors.grey),
                        Card(
                          color: Colors.blue.shade50,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: ListTile(
                            title: const Text(
                              "Toplam Gelir",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            trailing: Text(
                              "${totalIncome.toStringAsFixed(2)} ₺",
                              style: const TextStyle(color: Colors.blue),
                            ),
                          ),
                        ),
                        Card(
                          color: Colors.red.shade50,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: ListTile(
                            title: const Text(
                              "Toplam Harcamalar",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            trailing: Text(
                              "${_totalExpenses.toStringAsFixed(2)} ₺",
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ),
                        Card(
                          color: remainingBudget >= 0
                              ? Colors.green.shade50
                              : Colors.red.shade50,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: ListTile(
                            title: const Text(
                              "Kalan Bütçe",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            trailing: Text(
                              "${remainingBudget.toStringAsFixed(2)} ₺",
                              style: TextStyle(
                                  color: remainingBudget >= 0
                                      ? Colors.green
                                      : Colors.red),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
