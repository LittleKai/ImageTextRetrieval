import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'image_retrieval_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Đảm bảo tất cả các plugin đã được khởi tạo
  await SystemChannels.platform.invokeMethod<void>('SystemChrome.setPreferredOrientations', []);
  // DartVLC.initialize();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Text Retrieval',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
      home: ImageRetrievalPage(),
    );
  }
}