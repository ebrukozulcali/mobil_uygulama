/*pazartesi aktif
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'monday_homepage.dart';
import 'regular_homepage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PARLA',
      theme: ThemeData(
        fontFamily: 'RubikBubbles',
      ),
      home: const NextPage(),
    );
  }
}

class NextPage extends StatefulWidget {
  const NextPage({super.key});

  @override
  State<NextPage> createState() => _NextPageState();
}

class _NextPageState extends State<NextPage> {
  late VideoPlayerController _controller;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _birthdateController = TextEditingController();
  String? _selectedGender;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/3.mp4')
      ..initialize().then((_) {
        _controller.setLooping(true);
        _controller.play();
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    _surnameController.dispose();
    _birthdateController.dispose();
    super.dispose();
  }

  void _validateAndProceed() async {
    final birthdatePattern = RegExp(r'^\d{2}/\d{2}/\d{4}$');

    if (_nameController.text.isEmpty ||
        _surnameController.text.isEmpty ||
        _birthdateController.text.isEmpty ||
        _selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Lütfen tüm alanları doldurun ve cinsiyet seçin."),
          backgroundColor: Colors.red,
        ),
      );
    } else if (!birthdatePattern.hasMatch(_birthdateController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Doğum tarihini doğru formatta girin: dd/MM/yyyy"),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      final today = DateTime.now();
      final userName = _nameController.text;

      if (today.weekday == 1) {
        // Pazartesi sayfasına yönlendir
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MondayHomepage(name: userName),
          ),
        );
      } else {
        // Diğer günler için yönlendirme
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RegularHomepage(name: userName),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Arka Plan Videosu
          Positioned.fill(
            child: _controller.value.isInitialized
                ? FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _controller.value.size.width,
                      height: _controller.value.size.height,
                      child: VideoPlayer(_controller),
                    ),
                  )
                : const Center(child: CircularProgressIndicator()),
          ),
          Container(
            color: Colors.black.withOpacity(0.2),
          ),
          Positioned(
            top: size.height * 0.25,
            left: size.width * 0.1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLabel("Adınız:", size),
                SizedBox(height: size.height * 0.01),
                _buildTextField(size, _nameController),
                SizedBox(height: size.height * 0.02),
                _buildLabel("Soyadınız:", size),
                SizedBox(height: size.height * 0.01),
                _buildTextField(size, _surnameController),
                SizedBox(height: size.height * 0.02),
                _buildLabel("Doğum Tarihiniz:", size),
                SizedBox(height: size.height * 0.01),
                _buildTextField(
                  size,
                  _birthdateController,
                  placeholder: "10/10/2001",
                  hintOpacity: 0.5,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d/]')),
                    LengthLimitingTextInputFormatter(10),
                  ],
                ),
                SizedBox(height: size.height * 0.02),
                _buildLabel("Cinsiyetiniz:", size),
                SizedBox(height: size.height * 0.01),
                Row(
                  children: [
                    _genderButton("KADIN", size),
                    SizedBox(width: size.width * 0.02),
                    _genderButton("ERKEK", size),
                  ],
                ),
                SizedBox(height: size.height * 0.04),
                ElevatedButton(
                  onPressed: _validateAndProceed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.1,
                      vertical: size.height * 0.012,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    "Devam",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.brown,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text, Size size) {
    return Row(
      children: [
        const Text(
          "★",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 213, 182, 79),
          ),
        ),
        SizedBox(width: size.width * 0.01),
        Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    Size size,
    TextEditingController controller, {
    String? placeholder,
    double? hintOpacity,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return SizedBox(
      width: size.width * 0.6,
      child: TextField(
        controller: controller,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          hintText: placeholder,
          hintStyle: TextStyle(
            color: Colors.grey.withOpacity(hintOpacity ?? 1.0),
          ),
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: Colors.brown,
              width: 2.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: Colors.orange,
              width: 2.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _genderButton(String label, Size size) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGender = label;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: _selectedGender == label ? Colors.amber : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.brown, width: 1.5),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.03,
          vertical: size.height * 0.007,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: _selectedGender == label ? Colors.white : Colors.brown,
          ),
        ),
      ),
    );
  }
}*/


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'regular_homepage.dart';

class NextPage extends StatefulWidget {
  const NextPage({super.key});

  @override
  State<NextPage> createState() => _NextPageState();
}

class _NextPageState extends State<NextPage> {
  late VideoPlayerController _controller;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _birthdateController = TextEditingController();
  String? _selectedGender;

  @override
  void initState() {
    super.initState();
    // Video başlatma
    _controller = VideoPlayerController.asset('assets/3.mp4')
      ..initialize().then((_) {
        _controller.setLooping(true);
        _controller.play();
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    _surnameController.dispose();
    _birthdateController.dispose();
    super.dispose();
  }

  Future<void> _saveUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', _nameController.text);
    await prefs.setString('userSurname', _surnameController.text);
    await prefs.setString('userBirthdate', _birthdateController.text);
    await prefs.setString('userGender', _selectedGender ?? '');
    await prefs.setBool('isLoggedIn', true); // Oturum açma bilgisi
  }

  void _validateAndProceed() async {
    final birthdatePattern = RegExp(r'^\d{2}/\d{2}/\d{4}$');

    if (_nameController.text.isEmpty ||
        _surnameController.text.isEmpty ||
        _birthdateController.text.isEmpty ||
        _selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Lütfen tüm alanları doldurun ve cinsiyet seçin."),
          backgroundColor: Colors.red,
        ),
      );
    } else if (!birthdatePattern.hasMatch(_birthdateController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Doğum tarihini doğru formatta girin: dd/MM/yyyy"),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      // Kullanıcı bilgilerini kaydet
      await _saveUserDetails();
      if (!mounted) return;

// RegularHomePage'e yönlendirme
Navigator.pushReplacement(
  context,
  MaterialPageRoute(
    builder: (context) => RegularHomePage(name: _nameController.text), // Ad gönderiliyor
  ),
);


      // RegularHomePage'e yönlendirme
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              RegularHomePage(name: _nameController.text), // Ad gönderiliyor
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Arka Plan Videosu
          Positioned.fill(
            child: _controller.value.isInitialized
                ? FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _controller.value.size.width,
                      height: _controller.value.size.height,
                      child: VideoPlayer(_controller),
                    ),
                  )
                : const Center(child: CircularProgressIndicator()),
          ),
          Container(
            color: Colors.black.withOpacity(0.2),
          ),
          Positioned(
            top: size.height * 0.25,
            left: size.width * 0.1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLabel("Adınız:", size),
                SizedBox(height: size.height * 0.01),
                _buildTextField(size, _nameController),
                SizedBox(height: size.height * 0.02),
                _buildLabel("Soyadınız:", size),
                SizedBox(height: size.height * 0.01),
                _buildTextField(size, _surnameController),
                SizedBox(height: size.height * 0.02),
                _buildLabel("Doğum Tarihiniz:", size),
                SizedBox(height: size.height * 0.01),
                _buildTextField(
                  size,
                  _birthdateController,
                  placeholder: "10/10/2001",
                  hintOpacity: 0.5,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d/]')),
                    LengthLimitingTextInputFormatter(10),
                  ],
                ),
                SizedBox(height: size.height * 0.02),
                _buildLabel("Cinsiyetiniz:", size),
                SizedBox(height: size.height * 0.01),
                Row(
                  children: [
                    _genderButton("KADIN", size),
                    SizedBox(width: size.width * 0.02),
                    _genderButton("ERKEK", size),
                  ],
                ),
                SizedBox(height: size.height * 0.04),
                ElevatedButton(
                  onPressed: _validateAndProceed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.1,
                      vertical: size.height * 0.012,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    "Devam",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.brown,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text, Size size) {
    return Row(
      children: [
        const Text(
          "★",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 213, 182, 79),
          ),
        ),
        SizedBox(width: size.width * 0.01),
        Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    Size size,
    TextEditingController controller, {
    String? placeholder,
    double? hintOpacity,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return SizedBox(
      width: size.width * 0.6,
      child: TextField(
        controller: controller,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          hintText: placeholder,
          hintStyle: TextStyle(
            color: Colors.grey.withOpacity(hintOpacity ?? 1.0),
          ),
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: Colors.brown,
              width: 2.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: Colors.orange,
              width: 2.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _genderButton(String label, Size size) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGender = label;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: _selectedGender == label ? Colors.amber : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.brown, width: 1.5),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.03,
          vertical: size.height * 0.007,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: _selectedGender == label ? Colors.white : Colors.brown,
          ),
        ),
      ),
    );
  }
}

/*import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'regular_homepage.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PARLA',
      theme: ThemeData(
        fontFamily: 'RubikBubbles',
      ),
      home: const NextPage(),
    );
  }
}

class NextPage extends StatefulWidget {
  const NextPage({super.key});

  @override
  State<NextPage> createState() => _NextPageState();
}

class _NextPageState extends State<NextPage> {
  late VideoPlayerController _controller;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _birthdateController = TextEditingController();
  String? _selectedGender;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/3.mp4')
      ..initialize().then((_) {
        _controller.setLooping(true);
        _controller.play();
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    _surnameController.dispose();
    _birthdateController.dispose();
    super.dispose();
  }

  void _validateAndProceed() {
    final birthdatePattern = RegExp(r'^\d{2}/\d{2}/\d{4}$');

    if (_nameController.text.isEmpty ||
        _surnameController.text.isEmpty ||
        _birthdateController.text.isEmpty ||
        _selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Lütfen tüm alanları doldurun ve cinsiyet seçin."),
          backgroundColor: Colors.red,
        ),
      );
    } else if (!birthdatePattern.hasMatch(_birthdateController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Doğum tarihini doğru formatta girin: dd/MM/yyyy"),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      final userName = _nameController.text;

      // Tüm günler için RegularHomepage'e yönlendir
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RegularHomePage(name: userName),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Arka Plan Videosu
          Positioned.fill(
            child: _controller.value.isInitialized
                ? FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _controller.value.size.width,
                      height: _controller.value.size.height,
                      child: VideoPlayer(_controller),
                    ),
                  )
                : const Center(child: CircularProgressIndicator()),
          ),
          Container(
            color: Colors.black.withOpacity(0.2),
          ),
          Positioned(
            top: size.height * 0.25,
            left: size.width * 0.1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLabel("Adınız:", size),
                SizedBox(height: size.height * 0.01),
                _buildTextField(size, _nameController),
                SizedBox(height: size.height * 0.02),
                _buildLabel("Soyadınız:", size),
                SizedBox(height: size.height * 0.01),
                _buildTextField(size, _surnameController),
                SizedBox(height: size.height * 0.02),
                _buildLabel("Doğum Tarihiniz:", size),
                SizedBox(height: size.height * 0.01),
                _buildTextField(
                  size,
                  _birthdateController,
                  placeholder: "10/10/2001",
                  hintOpacity: 0.5,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d/]')),
                    LengthLimitingTextInputFormatter(10),
                  ],
                ),
                SizedBox(height: size.height * 0.02),
                _buildLabel("Cinsiyetiniz:", size),
                SizedBox(height: size.height * 0.01),
                Row(
                  children: [
                    _genderButton("KADIN", size),
                    SizedBox(width: size.width * 0.02),
                    _genderButton("ERKEK", size),
                  ],
                ),
                SizedBox(height: size.height * 0.04),
                ElevatedButton(
                  onPressed: _validateAndProceed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.1,
                      vertical: size.height * 0.012,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    "Devam",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.brown,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text, Size size) {
    return Row(
      children: [
        const Text(
          "★",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 213, 182, 79),
          ),
        ),
        SizedBox(width: size.width * 0.01),
        Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    Size size,
    TextEditingController controller, {
    String? placeholder,
    double? hintOpacity,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return SizedBox(
      width: size.width * 0.6,
      child: TextField(
        controller: controller,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          hintText: placeholder,
          hintStyle: TextStyle(
            color: Colors.grey.withOpacity(hintOpacity ?? 1.0),
          ),
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: Colors.brown,
              width: 2.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: Colors.orange,
              width: 2.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _genderButton(String label, Size size) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGender = label;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: _selectedGender == label ? Colors.amber : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.brown, width: 1.5),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.03,
          vertical: size.height * 0.007,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: _selectedGender == label ? Colors.white : Colors.brown,
          ),
        ),
      ),
    );
  }
}*/