import 'package:flutter/material.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const Center(child: Text('Menu', style: TextStyle(fontSize: 15))),
    const Center(child: Text('Data', style: TextStyle(fontSize: 15))),
    const Center(child: Text('Profile', style: TextStyle(fontSize: 15))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('OpenANR Application'),
        backgroundColor: Colors.lightBlueAccent,
      ),

      body: _pages[_currentIndex],
    );
  }
}
