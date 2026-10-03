import 'package:flutter/material.dart';

class ComplainScreen extends StatelessWidget {
  const ComplainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complain'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'Complain Page',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
