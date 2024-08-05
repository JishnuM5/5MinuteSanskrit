// This file contains all the app bars used throughout the project

import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'my_app_state.dart';
import 'themes.dart';

// This is the navigation bar that will be displayed on the main page
class NavBar extends StatelessWidget {
  const NavBar({super.key, required this.navBarIndex});

  final int navBarIndex;

  // Users can switch between the home, leaderboard, and profile page with this bar
  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      onDestinationSelected: (int index) {
        context.read<MyAppState>().navigateTo(index);
      },
      selectedIndex: navBarIndex,
      destinations: const <Widget>[
        NavigationDestination(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.leaderboard),
          label: 'Leaderboard',
        ),
        NavigationDestination(
          icon: Icon(Icons.account_circle_rounded),
          label: 'Profile',
        ),
      ],
    );
  }
}

// This navigation bar is for the quiz page
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
      onDestinationSelected: (int index) {
        context.read<MyAppState>().navigateTo(index);
      },
      destinations: <Widget>[
        // This button navigates to the home page after saving quiz data and running other tasks
        const NavigationDestination(
          icon: Icon(Icons.arrow_back),
          label: 'Save & Exit',
        ),

        // This is the current quiz name, displayed in the app bar
        Center(
          child: Text(
            currentQuiz.name,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        Center(
          child: Container(
            alignment: Alignment.center,
            width: 70,
            height: 40,
            decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 1.5),
                borderRadius: BorderRadius.circular(10),
                color: ConstColors.primary,
                boxShadow: [shadow]),

            // This is the question counter
            child: Text(
              '${currentQuiz.currentQ + 1} / ${currentQuiz.questions.length}',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: ConstColors.grey,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        )
      ],
    );
  }
}

// This is the top app bar
AppBar topBar(BuildContext context, int totalPoints) {
  MyAppState readState = context.read<MyAppState>();
  bool showHint = context.watch<MyAppState>().pageIndex == 4 &&
      readState.quizzes[readState.currentQuiz].showHint;

  return AppBar(
    toolbarHeight: 60,
    backgroundColor: ConstColors.background,
    scrolledUnderElevation: 0,
    title: Row(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
          child: (isSmallScreen(context)) ? condensedLogo : logo,
        )
      ],
    ),
    actions: <Widget>[
      // This widget either opens up quiz hints or the tutorial, depending on the page
      (showHint)
          ? IconButton(
              onPressed: () => showHintPage(context),
              icon: const Image(
                image: AssetImage('assets/bulb.png'),
                height: 30,
              ),
              tooltip: 'Show hint',
            )
          : IconButton(
              onPressed: () => showDialog(
                context: context,
                builder: (BuildContext context) => const TutorialPopup(),
              ),
              icon: const Icon(Icons.help, size: 30),
              tooltip: 'Show tutorial',
            ),
      // This widget is the point counter
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Container(
          alignment: Alignment.center,
          height: 37.5,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 1.5),
            borderRadius: BorderRadius.circular(10),
            color: ConstColors.primary,
            boxShadow: [shadow],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 7.5, vertical: 2.5),
            child: Row(
              children: [
                const Image(
                  image: AssetImage('assets/star.png'),
                  height: 15,
                ),
                const SizedBox(width: 5),
                Text(
                  '$totalPoints',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: ConstColors.yellow,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}

// THis is the widget that shows up on the tutorial dialog
class TutorialPopup extends StatelessWidget {
  const TutorialPopup({super.key});
  // The tutorial strings used to build the carousel
  static const List<String> titles = [
    'Welcome to 5 Minute संस्कृतम्!',
    'How It Works',
    'Earning Points',
    'Maximize Your Points',
  ];
  static const List<String> info = [
    'A microlearning web application to enhance your Sanskrit skills in just 5 minutes/day with weekly quizzes.',
    'Quizzes are divided into "sessions" of up to 5 questions each.',
    'Answering questions on time = more points. Quiz tiles indicate how long ago a session was assigned and the points per correct answer.',
    'There are other point bonuses:'
  ];
  static const List<List<String>> bulletInfo = [
    [],
    [
      'New sessions unlock daily at 12 pm if the previous session is completed.',
      'To master a quiz, answer each question correctly twice.',
    ],
    [
      'Green border: <1 day ago, 5 pts.',
      'Yellow border: 1-3 days ago, 3 pts.',
      'Red border: >3 days ago, 1 pt.',
    ],
    [
      '+5 pts for correctly answering a question 2 times (mastery).',
      '+2 pts for never answering question wrong.',
    ],
  ];
  static const List<String> postInfo = [
    '',
    'This means at least 4 sessions/week.',
    '',
    'Answer questions correctly and promptly and climb the leaderboard!'
  ];
  static const List<String> assetNames = [
    'welcome.gif',
    'calendar.gif',
    'quiz.gif',
    'leaderboard.gif',
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: ConstColors.background,
      child: SingleChildScrollView(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.8,
          child: Stack(
            children: [
              // The carousel is built as a swiper with various pages
              Swiper(
                itemBuilder: (BuildContext context, int index) {
                  return TutorialSlide(
                    title: titles[index],
                    content: info[index],
                    assetName: assetNames[index],
                    bulletContent: bulletInfo[index],
                    postContent: postInfo[index],
                  );
                },
                itemCount: 4,
                pagination: const SwiperPagination(),
                control: const SwiperControl(
                  size: 20,
                  padding: EdgeInsets.all(10),
                ),
              ),
              Positioned(
                right: 7.5,
                top: 7.5,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// This widget is used to build the individual slides on the tutorial page
class TutorialSlide extends StatelessWidget {
  final String title;
  final String assetName;
  final String content;
  final List<String> bulletContent;
  final String postContent;

  const TutorialSlide({
    super.key,
    required this.title,
    required this.assetName,
    required this.content,
    required this.bulletContent,
    required this.postContent,
  });

  // A tutorial slide consists of a title, paragraph, and graphic
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.displaySmall!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 5),
          Paragraph(
            content: content,
            bulletContent: bulletContent,
            postContent: postContent,
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Align(
              alignment: Alignment.center,
              child: Image(
                image: AssetImage('assets/$assetName'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// This method shows the quiz hint page in a modal sheet
Future<void> showHintPage(BuildContext context) {
  return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: ConstColors.background,
      builder: (context) {
        return context.read<MyAppState>().currentHintPage;
      });
}
