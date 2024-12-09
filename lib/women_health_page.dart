import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:table_calendar/table_calendar.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/services.dart';


class WomenHealthPage extends StatefulWidget {
  const WomenHealthPage({super.key});

  @override
  State<WomenHealthPage> createState() => _WomenHealthPageState();
}

class _WomenHealthPageState extends State<WomenHealthPage> {
  final TextEditingController _cycleLengthController = TextEditingController();
  final TextEditingController _periodLengthController = TextEditingController();
  DateTime? _lastPeriodDate;
  DateTime? _nextPeriodDate;

  late VideoPlayerController _videoController;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
    _loadData();
  }

  @override
  void dispose() {
    _videoController.dispose();
    _cycleLengthController.dispose();
    _periodLengthController.dispose();
    super.dispose();
  }

  void _initializeVideo() {
    _videoController = VideoPlayerController.asset('assets/regl.mp4')
      ..initialize().then((_) {
        _videoController.setLooping(true);
        _videoController.play();
        setState(() {});
      });
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      final lastPeriodDate = prefs.getString('lastPeriodDate');
      if (lastPeriodDate != null) {
        _lastPeriodDate = DateTime.parse(lastPeriodDate);
      }
      _cycleLengthController.text = prefs.getString('cycleLength') ?? '';
      _periodLengthController.text = prefs.getString('periodLength') ?? '';
      _calculateNextPeriod();
    });
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    if (_lastPeriodDate != null) {
      prefs.setString('lastPeriodDate', _lastPeriodDate!.toIso8601String());
    }
    prefs.setString('cycleLength', _cycleLengthController.text);
    prefs.setString('periodLength', _periodLengthController.text);
  }

  void _calculateNextPeriod() {
    final int? cycleLength = int.tryParse(_cycleLengthController.text);
    if (_lastPeriodDate != null && cycleLength != null) {
      setState(() {
        _nextPeriodDate = _lastPeriodDate!.add(Duration(days: cycleLength));
      });
    }
  }

  void _showDatePicker() {
    showDatePicker(
      context: context,
      initialDate: _lastPeriodDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    ).then((selectedDate) {
      if (selectedDate != null) {
        setState(() {
          _lastPeriodDate = selectedDate;
        });
        _calculateNextPeriod();
        _saveData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Regl Takibi",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 224, 4, 77),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
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
          Container(
            color: Colors.black.withOpacity(0.2),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              _buildLabel("Döngü Uzunluğu (gün)", _cycleLengthController, size),
              const SizedBox(height: 20),
              _buildLabel("Regl Süresi (gün)", _periodLengthController, size),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _showDatePicker,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 149, 0, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Regl Başlangıç Tarihini Seç",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),
              if (_nextPeriodDate != null)
                Text(
                  "Tahmini Regl Başlangıç Tarihi: ${_nextPeriodDate!.toLocal().toString().split(' ')[0]}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              const SizedBox(height: 20),
              /*Expanded(
                child: TableCalendar(
                  focusedDay: _nextPeriodDate ?? DateTime.now(),
                  firstDay: DateTime(2000),
                  lastDay: DateTime(2100),
                  calendarStyle: const CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Colors.pink,
                      shape: BoxShape.circle,
                    ),
                  ),
                  selectedDayPredicate: (day) => isSameDay(_lastPeriodDate, day),
                ),
              ),*/
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String label, TextEditingController controller, Size size) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white.withOpacity(0.2),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.pinkAccent),
              ),
            ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
          ),
        ],
      ),
    );
  }
}
