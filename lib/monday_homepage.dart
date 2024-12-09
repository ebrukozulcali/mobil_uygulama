/* pazartesi için istsina kuralları uygulansaydı kullanılacaktı*/

import 'package:flutter/material.dart';

class MondayHomepage extends StatelessWidget {
  const MondayHomepage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pazartesi Ana Sayfa"),
      ),
      body: const Center(
        child: Text(
          "Bu, yalnızca pazartesi günleri görünen özel ana sayfadır.",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
