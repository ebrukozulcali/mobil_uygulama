
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:mobil_uygulama/menuler.dart';

class RegularHomePage extends StatefulWidget {
  final String name;

  const RegularHomePage({super.key, required this.name});

  @override
  State<RegularHomePage> createState() => RegularHomePageState();
}

class RegularHomePageState extends State<RegularHomePage>{
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    // Video arka planını başlatma
    _controller = VideoPlayerController.asset('assets/regularpage.mp4')
      ..initialize().then((_) {
        _controller.setLooping(true);
        _controller.play();
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () {
        // Menüler Sayfası'na yönlendirme
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const MenulerSayfasi(),
          ),
        );
      },
      child: Scaffold(
        body: Stack(
          children: [
            // Arka plan videosu
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
            // Yazı katmanı
            Positioned.fill(
              child: Column(
                children: [
                  // Hoşgeldin yazısı
                  Padding(
                    padding: EdgeInsets.only(top: size.height * 0.15),
                    child: Text(
                      "Hoşgeldin ${widget.name}",
                      style: TextStyle(
                        fontFamily: 'RubikBubbles',
                        fontSize: size.width * 0.08,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: size.height * 0.05), // Boşluk
                  // Yüksel, Parla yazısı
                  Text(
                    "Yüksel,\nParla,\nBaşını dik tut!",
                    style: TextStyle(
                      fontFamily: 'RubikBubbles',
                      fontSize: size.width * 0.1,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 131, 86, 3),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}