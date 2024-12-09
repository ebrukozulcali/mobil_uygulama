import 'package:flutter/material.dart';

class ShoppingTravelPage extends StatefulWidget {
  const ShoppingTravelPage({super.key});

  @override
  State<ShoppingTravelPage> createState() => _ShoppingTravelPageState();
}

class _ShoppingTravelPageState extends State<ShoppingTravelPage> {
  List<String> travelDestinations = [];
  List<String> travelPackingList = [];
  List<String> shoppingList = [];
  final TextEditingController _inputController = TextEditingController();

  void _addItem(String title, List<String> targetList) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: _inputController,
            decoration: const InputDecoration(hintText: "Bir şey ekleyin"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("İptal"),
            ),
            TextButton(
              onPressed: () {
                if (_inputController.text.isNotEmpty) {
                  setState(() {
                    targetList.add(_inputController.text);
                  });
                  _inputController.clear();
                  Navigator.pop(context);
                }
              },
              child: const Text("Ekle"),
            ),
          ],
        );
      },
    );
  }

  void _removeItem(String item, List<String> targetList) {
    setState(() {
      targetList.remove(item);
    });
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
          // İçerik
          Column(
            children: [
              AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                backgroundColor: const Color.fromARGB(255, 216, 169, 87),
                elevation: 0,
                title: const Text(
                  "Alışveriş ve Seyahat",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                centerTitle: true,
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        _buildSection(
                          title: "Seyahat Yapılacak Yerler",
                          icon: Icons.map,
                          itemList: travelDestinations,
                          color: Colors.blue,
                          addFunction: () =>
                              _addItem("Yeni Seyahat Noktası Ekle", travelDestinations),
                        ),
                        const SizedBox(height: 16),
                        _buildSection(
                          title: "Seyahatte Yanına Alınacaklar",
                          icon: Icons.luggage,
                          itemList: travelPackingList,
                          color: Colors.orange,
                          addFunction: () =>
                              _addItem("Yeni Alınacak Ekle", travelPackingList),
                        ),
                        const SizedBox(height: 16),
                        _buildSection(
                          title: "Alışveriş Listesi",
                          icon: Icons.shopping_cart,
                          itemList: shoppingList,
                          color: Colors.green,
                          addFunction: () =>
                              _addItem("Yeni Alışveriş Ürünü Ekle", shoppingList),
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text("Yapay Zeka Önerileri"),
                                  content: const Text(
                                      "Seyahat yerleri veya alınacaklar için öneriler sunulabilir."),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text("Tamam"),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          icon: const Icon(Icons.lightbulb),
                          label: const Text("Yapay Zeka Önerileri"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
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

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<String> itemList,
    required Color color,
    required VoidCallback addFunction,
  }) {
    return Card(
      color: color.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(color: color, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const Divider(),
            ...itemList.map(
              (item) => ListTile(
                title: Text(item),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _removeItem(item, itemList),
                ),
              ),
            ),
            TextButton.icon(
              onPressed: addFunction,
              icon: const Icon(Icons.add, color: Colors.blue),
              label: const Text("Yeni Ekle"),
            ),
          ],
        ),
      ),
    );
  }
}