import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gym/features/exercises/view/screens/exercises_display_page.dart';
import 'package:gym/features/home/view/widgets/signout.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        body: SafeArea(
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'Hello',
                      style: TextStyle(fontSize: 27),
                    ),
                    SizedBox(
                      width: 7,
                    ),
                    Text(
                      'Ahmed,',
                      style: TextStyle(
                          fontSize: 27,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    )
                  ],
                ),
                SignOutBtn()
              ],
            ),
            SizedBox(
              height: 5,
            ),
            Expanded(child: ExercisesScreen())
          ],
        ),
      ),
    ));
  }
}
