import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'main.dart';
import 'quiz_page.dart';

//This is the navigation bar that will be displayed on the main page.
class NavBar extends StatelessWidget {
  const NavBar({super.key, required this.navBarIndex});

  final int navBarIndex;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      //This method is passed as a callback function, so the parameter is implicit.
      //Still, I'm explicitly calling it here with a lambda function for comprehensibility
      // I also don't need a currentIndex property because I don't need to access it.
      onDestinationSelected: (int index) =>
          context.read<MyAppState>().onItemTapped(index),
      selectedIndex: navBarIndex,
      destinations: const <Widget>[
        NavigationDestination(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.account_circle_rounded),
          label: 'Profile',
        ),
      ],
    );
  }
}

// This navigation bar is for the quiz page.
class QuizBar extends StatelessWidget {
  const QuizBar({
    super.key,
    required this.navBarIndex,
  });

  final int navBarIndex;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: navBarIndex,
      onDestinationSelected: (int index) =>
          context.read<MyAppState>().onItemTapped(index),
      destinations: <Widget>[
        const NavigationDestination(
          icon: Icon(Icons.arrow_back),
          label: 'Home',
        ),
        Center(
          child: Text(
            context.watch<MyQuizState>().quiz.name,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        Center(
          child: Container(
            alignment: Alignment.center,
            width: 50,
            height: 40,
            decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(7)),
                color: Theme.of(context).primaryColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 3,
                    blurRadius: 5,
                    offset: const Offset(0, 1),
                  )
                ]),

            // This is the question counter.
            child: Text(
              '${context.watch<MyQuizState>().currentQ + 1}/5',
              style: DefaultTextStyle.of(context).style.apply(
                  fontSizeFactor: 1.5,
                  fontFamily: GoogleFonts.courierPrime().fontFamily),
            ),
          ),
        )
      ],
    );
  }
}
