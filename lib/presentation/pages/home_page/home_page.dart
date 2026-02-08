import 'package:flutter/material.dart';
import 'package:flutter_moodic/presentation/pages/home_page/widgets/home_feed_card.dart';
import 'package:flutter_moodic/presentation/pages/write_page/write_page.dart';
import 'package:flutter_moodic/presentation/widgets/custom_bottom_nav_bar.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const WritePage()),
          );
        },
      ),
      appBar: AppBar(
        centerTitle: true,
        title: Image.asset('assets/images/logo.png', width: 70),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 0,
        onTap: (index) {},
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
        ).copyWith(bottom: 120),
        itemBuilder: (context, index) {
          return HomeFeedCard();
        },
        separatorBuilder: (context, index) {
          return const SizedBox(height: 20);
        },
        itemCount: 2,
      ),
    );
  }
}
