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
