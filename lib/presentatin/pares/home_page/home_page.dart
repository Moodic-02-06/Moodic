import 'package:flutter/material.dart';
import 'package:flutter_moodic/presentatin/pares/home_page/widgets/home_feed_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(children: [HomeFeedCard(), HomeFeedCard()]),
      ),
    );
  }
}
