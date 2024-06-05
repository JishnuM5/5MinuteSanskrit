import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'main.dart';
import 'my_app_state.dart';
import 'themes.dart';

// This is the navigation bar that will be displayed on the main page.
class NavBar extends StatelessWidget {
  const NavBar({super.key, required this.navBarIndex});

  final int navBarIndex;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      // This method is passed as a callback function, so the parameter is implicit.
      // Still, I'm explicitly calling it here with a lambda function for comprehensibility
      // I also don't need a currentIndex property because I don't need to access it.
      onDestinationSelected: (int index) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) =>
              const Center(child: CircularProgressIndicator()),
        );
        context.read<MyAppState>().onItemTapped(index);
        navigatorKey.currentState!.popUntil((route) => route.isFirst);
      },
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
    var currentQuiz = context
        .watch<MyAppState>()
        .quizzes[context.watch<MyAppState>().currentQuiz];

    return NavigationBar(
      selectedIndex: navBarIndex,
      onDestinationSelected: (int index) =>
          context.read<MyAppState>().onItemTapped(index),
      destinations: <Widget>[
        const NavigationDestination(
          icon: Icon(Icons.arrow_back),
          label: 'Save and Exit',
        ),
        Center(
          child: Text(
            currentQuiz.name,
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
                borderRadius: BorderRadius.circular(10),
                color: Theme.of(context).primaryColor,
                boxShadow: [shadow]),

            // This is the question counter.
            child: Text(
              '${currentQuiz.currentQ + 1}/${currentQuiz.questions.length}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
        )
      ],
    );
  }
}
