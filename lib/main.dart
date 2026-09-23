import 'package:flutter/material.dart';
import 'presentation/screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const VLibrasApp());
}

class VLibrasApp extends StatelessWidget {
  const VLibrasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VLibras Tradutor',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        brightness: Brightness.dark,
      ),
      home: const HomeScreen(),
    );
  }
}
