import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SelectContent extends StatefulWidget {
  const new({super.key});

  @override
  State<SelectContent> createState() => _SelectContentState();
}

class _SelectContentState extends State<SelectContent> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Halo'),
      ),
    );
  }
}