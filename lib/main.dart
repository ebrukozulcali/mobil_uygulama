/*bildirim için 
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'regular_homepage.dart';
import 'ikinci_sayfa.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeNotifications();
  tz.initializeTimeZones(); // Timezone kütüphanesini başlatın
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
      home: const SplashScreen(),
    );
  }
}

Future<void> _initializeNotifications() async {
  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await notificationsPlugin.initialize(initializationSettings);

  // Bildirim kanalı oluşturun
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'daily_notifications_channel', // Kanal ID'si
    'Günlük Bildirimler', // Kanal Adı
    description: 'Günaydın ve İyi Geceler Bildirimleri', // Açıklama
    importance: Importance.max, // Önem Derecesi
  );

  await notificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
}

Future<void> _scheduleNotification({
  required int id,
  required String title,
  required String body,
  required int hour,
  required int minute,
}) async {
  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final now = DateTime.now();
  final scheduledTime = DateTime(
    now.year,
    now.month,
    now.day,
    hour,
    minute,
  ).isBefore(now)
      ? DateTime(now.year, now.month, now.day + 1, hour, minute)
      : DateTime(now.year, now.month, now.day, hour, minute);

  await notificationsPlugin.zonedSchedule(
    id,
    title,
    body,
    tz.TZDateTime.from(scheduledTime, tz.local),
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'daily_notifications_channel',
        'Günlük Bildirimler',
        channelDescription: 'Günaydın ve İyi Geceler Bildirimleri',
      ),
    ),
    androidAllowWhileIdle: true,
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
    matchDateTimeComponents: DateTimeComponents.time,
  );
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
    _scheduleDailyNotifications(); // Günlük bildirimleri zamanla
  }

  void _initializeVideo() {
    _controller = VideoPlayerController.asset('assets/parla_2.mp4')
      ..initialize().then((_) {
        setState(() {
          _controller.setVolume(1.0); // Ses seviyesini aç
          _controller.play(); // Videoyu oynat
        });
      }).catchError((error) {
        debugPrint('Video Hatası: $error');
      });
  }

  Future<void> _scheduleDailyNotifications() async {
    // Günaydın Mesajı
    await _scheduleNotification(
      id: 1,
      title: "Günaydın!",
      body: "Bugün harika bir gün olsun!",
      hour: 6,
      minute: 0,
    );

    // İyi Geceler Mesajı
    await _scheduleNotification(
      id: 2,
      title: "İyi Geceler!",
      body: "Tatlı rüyalar!",
      hour: 22,
      minute: 0,
    );
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (!mounted) return;

    if (isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => RegularHomePage(name: prefs.getString('userName') ?? 'Kullanıcı'),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SecondPage()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: _controller.value.isInitialized
                ? AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  )
                : const CircularProgressIndicator(),
          ),
          GestureDetector(
            onTap: _checkLoginStatus,
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ],
      ),
    );
  }
}*/


/*import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'regular_homepage.dart';
import 'ikinci_sayfa.dart';

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
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  void _initializeVideo() {
    _controller = VideoPlayerController.asset('assets/parla_2.mp4')
      ..initialize().then((_) {
        setState(() {
          _controller.setVolume(1.0); // Ses seviyesini aç
          _controller.play(); // Videoyu oynat
        });
      }).catchError((error) {
        debugPrint('Video Hatası: $error');
      });
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (!mounted) return;

    if (isLoggedIn) {
      // Oturum açılmışsa RegularHomePage'e yönlendir
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => RegularHomePage(name: prefs.getString('userName') ?? 'Kullanıcı'),
        ),
      );
    } else {
      // Oturum açılmamışsa İkinci Sayfa'ya yönlendir
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SecondPage()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Video Arka Planı
          Center(
            child: _controller.value.isInitialized
                ? AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  )
                : const CircularProgressIndicator(),
          ),
          // Tıklama Katmanı
          GestureDetector(
            onTap: _checkLoginStatus, // Tıklandığında sayfa kontrolü
            child: Container(
              color: Colors.transparent, // Görünmez bir tıklama katmanı
            ),
          ),
        ],
      ),
    );
  }
}*/
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // dotenv'i import edin
import 'package:http/http.dart' as http; // http paketini import edin
import 'dart:convert';

void main() async {
  // Uygulama başlamadan önce .env dosyasını yükle
  await dotenv.load(fileName: ".env");

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
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;
  String _aiResponse = '';

  @override
  void initState() {
    super.initState();

    // .env dosyasındaki API Anahtarını test etmek için yazdırın
    final apiKey = dotenv.env['OPENAI_API_KEY'] ?? 'Anahtar Yok';
    debugPrint('API Key: $apiKey');

    _initializeVideo(); // Video oynatıcıyı başlat
    _checkLoginStatus(); // Oturum durumunu kontrol et
  }

  void _initializeVideo() {
    _controller = VideoPlayerController.asset('assets/parla_2.mp4')
      ..initialize().then((_) {
        setState(() {
          _controller.setVolume(1.0); // Ses seviyesini aç
          _controller.play(); // Videoyu oynat
        });
      }).catchError((error) {
        debugPrint('Video Hatası: $error');
      });
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (!mounted) return;

    if (isLoggedIn) {
      // Oturum açılmışsa RegularHomePage'e yönlendir
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              RegularHomePage(name: prefs.getString('userName') ?? 'Kullanıcı'),
        ),
      );
    } else {
      // Oturum açılmamışsa İkinci Sayfa'ya yönlendir
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SecondPage()),
      );
    }
  }

  // OpenAI API'ye HTTP POST isteği
  Future<void> _sendAIRequest(String prompt) async {
    final apiKey = dotenv.env['OPENAI_API_KEY'];
    final url = Uri.parse('https://api.openai.com/v1/completions');

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "model": "text-davinci-003",
          "prompt": prompt,
          "max_tokens": 50,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _aiResponse = data['choices'][0]['text'];
        });
      } else {
        debugPrint('API Hatası: ${response.statusCode} - ${response.body}');
        setState(() {
          _aiResponse = 'Hata: API isteği başarısız.';
        });
      }
    } catch (e) {
      debugPrint('Bir hata oluştu: $e');
      setState(() {
        _aiResponse = 'Hata: $e';
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Video Arka Planı
          Center(
            child: _controller.value.isInitialized
                ? AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  )
                : const CircularProgressIndicator(),
          ),
          // Kullanıcı Arayüzü
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Bir metin girin',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (value) => _sendAIRequest(value),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _aiResponse.isNotEmpty ? 'AI Yanıtı: $_aiResponse' : '',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Placeholder widgetlar (Düzenlenebilir)
class RegularHomePage extends StatelessWidget {
  final String name;
  const RegularHomePage({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Hoş Geldin $name')),
      body: const Center(child: Text('Regular Home Page')),
    );
  }
}

class SecondPage extends StatelessWidget {
  const SecondPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('İkinci Sayfa')),
      body: const Center(child: Text('Second Page')),
    );
  }
}

/*her seferinde bu sayfalar gözüküyor
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'ikinci_sayfa.dart'; // İkinci sayfa
import 'regular_homepage.dart'; // Regular ana sayfa
import 'ucuncu_sayfa.dart'; // Oturum açma sayfası

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
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
    _checkLoginStatus();
  }

  void _initializeVideo() {
    _controller = VideoPlayerController.asset('assets/parla_2.mp4')
      ..initialize().then((_) {
        setState(() {
          _controller.setVolume(1.0);
          _controller.play();
        });
      }).catchError((error) {
        debugPrint('Video Hatası: $error');
      });
  }

  Future<void> _checkLoginStatus() async {
  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  final userName = prefs.getString('userName') ?? "Kullanıcı"; // Varsayılan olarak "Kullanıcı" adı

  await Future.delayed(const Duration(seconds: 3)); // Splash ekranında bekleme

  if (!mounted) return;

  if (isLoggedIn) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => RegularHomePage(name: userName), // Kullanıcı adını gönderiyoruz
      ),
    );
  } else {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SecondPage()), // Giriş yapılmamışsa ikinci sayfaya yönlendir
    );
  }
}


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: _controller.value.isInitialized
                ? AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  )
                : const CircularProgressIndicator(),
          ),
        ],
      ),
    );
  }
}*/

/*çalıştı ilk hali
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'ikinci_sayfa.dart';

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
        // Varsayılan yazı tipi olarak Rubik Bubbles'ı ayarla
        fontFamily: 'RubikBubbles',
      ),
      home: const VideoScreen(),
    );
  }
}

class VideoScreen extends StatefulWidget {
  const VideoScreen({super.key});

  @override
  VideoScreenState createState() => VideoScreenState();
}

class VideoScreenState extends State<VideoScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    // Video controller başlat ve otomatik oynat
    _controller = VideoPlayerController.asset('assets/parla_2.mp4')
      ..initialize().then((_) {
        setState(() {
          _controller.setVolume(1.0); // Ses seviyesini ayarla
        });
        _controller.play(); // Videoyu otomatik oynat
      }).catchError((error) {
        debugPrint('Hata oluştu: $error');
      });
      _controller.play().then((_) {
  debugPrint("Video başladı ve sesi açıldı.");
}).catchError((error) {
  debugPrint("Hata: $error");
});

  }

  @override
  void dispose() {
    _controller.dispose(); // Bellek sızıntılarını önlemek için controller'ı temizle
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Video Oynatıcı
          Center(
            child: _controller.value.isInitialized
                ? AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  )
                : const CircularProgressIndicator(),
          ),
          // Tıklama Katmanı
          GestureDetector(
            onTap: () {
              debugPrint("Tıklama algılandı");
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SecondPage()),
              );
            },
            child: Container(
              color: Colors.transparent, // Tıklama alanını görünmez yapar
            ),
          ),
        ],
      ),
    );
  }
}*/
