
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'ucuncu_sayfa.dart';

class SecondPage extends StatefulWidget {
  const SecondPage({super.key});

  @override
  State<SecondPage> createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    // Video controller başlat ve otomatik oynat
    _controller = VideoPlayerController.asset('assets/basla.mp4')
      ..initialize().then((_) {
        setState(() {
          _controller.setVolume(0.0); // Ses seviyesini ayarla
          _controller.play(); // Videoyu otomatik başlat
          _controller.setLooping(true); // Döngüye al
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose(); // Bellek sızıntılarını önlemek için controller'ı temizle
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size; // Ekran boyutlarını almak için

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Video Oynatıcı
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
                : const Center(child: CircularProgressIndicator()), // Yükleniyor göstergesi
          ),
          // İçerik Ortası
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // İçerikleri ortalar
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Üçüncü sayfaya geçiş
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const NextPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber, // Buton arka plan rengi
                    foregroundColor: Colors.brown, // Yazı rengi
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.15, // Buton genişliği
                      vertical: size.height * 0.02, // Buton yüksekliği
                    ),
                  ),
                  child: Text(
                    'Devam!',
                    style: TextStyle(
                      fontSize: size.width * 0.05, // Dinamik yazı boyutu
                      fontWeight: FontWeight.bold,
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
}
