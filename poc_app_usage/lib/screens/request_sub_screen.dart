import 'package:flutter/material.dart';

class RequestSubScreen extends StatelessWidget {
  const RequestSubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('요청하기')),
      body: const Center(
        child: Text('여기에 없는 OTT를 요청하는 화면'),
      ),
    );
  }
}
