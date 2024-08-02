// This is the main file of the project

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_core/firebase_core.dart';
import 'leaderboard_page.dart';
import 'auth_pages.dart';
import 'classes.dart';
import 'firebase_options.dart';
import 'my_app_state.dart';
import 'profile_page.dart';
import 'quiz_page.dart';
import 'app_bars.dart';
import 'summary_page.dart';
import 'themes.dart';

//This is the main method, from where the code runs
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

// These are global keys that can be accessed from anywhere
// They are primarily for navigation and displaying dialogs/snack bars
final navigatorKey = GlobalKey<NavigatorState>();
final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

// This widget is the root of my application.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // I only have one provider class, but have kept the option of adding more
        ChangeNotifierProvider<MyAppState>(create: (context) => MyAppState()),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        scaffoldMessengerKey: scaffoldMessengerKey,
        debugShowCheckedModeBanner: false,
        title: '5 Minute संस्कृतम्',
        theme: theme,
        home: const AuthNav(),
      ),
    );
  }
}

// This class manages the framework of the app
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title, required this.newUser});
  final String title;
  final bool newUser;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    if (widget.newUser) {
      Future.delayed(Duration.zero, () {
        showDialog(
          context: context,
          builder: (BuildContext context) => const TutorialPopup(),
        );
      });
    }
  }

  // The selected index state manages page navigation
  @override
  Widget build(BuildContext context) {
    Widget page;
    Widget? appBar;
    switch (context.watch<MyAppState>().pageIndex) {
      case 0:
        page = const MainPage();
        appBar = const NavBar(navBarIndex: 0);
        break;
      case 1:
        page = const LeaderboardPage();
        appBar = const NavBar(navBarIndex: 1);
        break;
      case 2:
        page = const ProfilePage();
        appBar = const NavBar(navBarIndex: 2);
        break;
      case 3:
        page = const SummaryPage();
        appBar = const QuizBar(navBarIndex: 1);
        break;
      case 4:
        page = QuizPage(currentQuiz: context.read<MyAppState>().currentQuiz);
        appBar = const QuizBar(navBarIndex: 1);
        break;
      default:
        throw UnimplementedError();
    }

    // The total number of points that a user has is calculated here
    int totalPoints = 0;
    for (Quiz quiz in context.watch<MyAppState>().quizzes) {
      totalPoints += quiz.points;
      totalPoints += context.watch<MyAppState>().masteredQuizPoints;
    }
    return Scaffold(
      // The top bar of the app
      appBar: topBar(context, totalPoints),
      // The bottom navigation bar of the app
      bottomNavigationBar: appBar,
      // The body of the app
      body: Padding(
        padding: const EdgeInsets.all(5.0),
        child: page,
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

// This class is the main page of the app
class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    List<Widget> quizList = [];
    int i = 0;
    for (Quiz quiz in context.watch<MyAppState>().quizzes) {
      quizList.add(QuizTile(quiz: quiz, index: i));
      i++;
    }

    return Scaffold(
      // A scroll view of the quiz tiles
      body: SingleChildScrollView(
        child: Column(
          children: [
            Text(
              "This Week's Quizzes",
              style: Theme.of(context).textTheme.displayLarge,
            ),
            const Padding(
              padding: EdgeInsets.all(5.0),
              child: Divider(),
            ),
            Column(
              children: quizList,
            ),
            const SizedBox(height: 15),
            // An expanding tile that shows mastered quizzes
            ExpansionTile(
              shape: const Border(),
              title: const Text('See mastered quizzes'),
              children: context
                  .watch<MyAppState>()
                  .masteredQuizzes
                  .map((quiz) => Padding(
                        padding: const EdgeInsets.fromLTRB(10, 5, 10, 2.5),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.check_circle_rounded,
                              color: ConstColors.green,
                            ),
                            const SizedBox(width: 10),
                            Text(quiz),
                          ],
                        ),
                      ))
                  .toList(),
            )
          ],
        ),
      ),
    );
  }
}

// This widget is a quiz tile
class QuizTile extends StatelessWidget {
  const QuizTile({
    required this.quiz,
    super.key,
    required this.index,
  });
  final Quiz quiz;
  final int index;

  @override
  Widget build(BuildContext context) {
    // Here, data values are retrieved and stored
    Quiz quiz = context.watch<MyAppState>().quizzes[index];
    int remainingQs = context.read<MyAppState>().remainingQs(index);
    double pctMastered = context.read<MyAppState>().pctMastered(index);

    // This method and boolean control whether the user can access the next session
    bool showSesh = true;
    DateTime? noonAfterLastAns;

    if (context.read<MyAppState>().lastQAnswered(index)) {
      final lastAns = quiz.currentSesh.lastAnswered!;
      noonAfterLastAns = DateTime(lastAns.year, lastAns.month, lastAns.day, 12);

      if (lastAns.isAfter(noonAfterLastAns)) {
        noonAfterLastAns = noonAfterLastAns.add(const Duration(days: 1));
      }
      if (DateTime.now().isBefore(noonAfterLastAns)) {
        showSesh = false;
      } else {
        quiz.lastShown = noonAfterLastAns;
      }
    }

    if (showSesh) {
      DateTime lastShown = quiz.lastShown ?? quiz.start;
      Duration diff = DateTime.now().difference(lastShown);
      if (diff <= const Duration(days: 1)) {
        context.read<MyAppState>().setQuizStatus(index, QuizStatus.green);
      } else if (diff <= const Duration(days: 3)) {
        context.read<MyAppState>().setQuizStatus(index, QuizStatus.yellow);
      } else {
        context.read<MyAppState>().setQuizStatus(index, QuizStatus.red);
      }
    } else {
      context.read<MyAppState>().setQuizStatus(index, QuizStatus.complete);
    }

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: SizedBox(
        height: 155,
        child: Stack(
          children: [
            // This container shows a progress bar of quiz mastery
            Positioned(
              left: 10,
              right: 10,
              bottom: 0,
              height: 55,
              child: Container(
                decoration: BoxDecoration(
                  color: ConstColors.shade.withOpacity(
                    (quiz.status == QuizStatus.complete) ? 0.7 : 1,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.fromLTRB(7.5, 25, 7.5, 7.5),
                child: Row(
                  children: [
                    Text(
                      'Mastery:',
                      style: Theme.of(context).textTheme.labelSmall!.copyWith(
                            color: const Color.fromARGB(255, 234, 234, 234),
                          ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: LinearProgressIndicator(
                        minHeight: 10,
                        value: pctMastered,
                        backgroundColor: Colors.white.withOpacity(0.3),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          ConstColors.primary.withOpacity(
                            (quiz.status == QuizStatus.complete) ? 0.7 : 1,
                          ),
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    )
                  ],
                ),
              ),
            ),
            // This is the clickable quiz tile
            Material(
              elevation: 10.0,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: (quiz.status == QuizStatus.green)
                      ? ConstColors.green
                      : (quiz.status == QuizStatus.yellow)
                          ? ConstColors.yellow
                          : (quiz.status == QuizStatus.red)
                              ? ConstColors.red
                              : Colors.transparent,
                  width: 5,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: InkWellBox(
                maxWidth: double.maxFinite,
                maxHeight: 120,
                color: ConstColors.primary.withOpacity(
                  (quiz.status == QuizStatus.complete) ? 0.7 : 1,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      quiz.name,
                      style: (isSanskrit(quiz.name))
                          ? Theme.of(context).textTheme.displayMedium!.copyWith(
                                color: ConstColors.grey,
                              )
                          : Theme.of(context)
                              .textTheme
                              .headlineMedium!
                              .copyWith(color: ConstColors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    // Here, the remaining number of questions in the current session are displayed
                    Text(
                      (showSesh)
                          ? "$remainingQs question(s) remaining this session"
                          : "Daily session complete!",
                      style: const TextStyle(color: ConstColors.grey),
                    ),
                  ],
                ),
                onTap: () {
                  // When the tile is clicked, the quiz page is prepared, and the user navigates there
                  // However, the user gets an info message if the session is complete and the next isn't ready
                  if (showSesh) {
                    bool newSesh =
                        context.read<MyAppState>().setCurrentQuiz(index);
                    context.read<MyAppState>().navigateTo(4);
                    context.read<MyAppState>().reset(newSesh: newSesh);
                  } else {
                    showTextSnackBar(
                        'Session completed! A new session will be available after 12 p.m.');
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// This is the animated logo that is displayed on the main page.
Widget animatedLogo(BuildContext context, bool animate) {
  return Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // The logo can be animated or static
          (animate)
              ? AnimatedTextKit(
                  isRepeatingAnimation: false,
                  repeatForever: false,
                  animatedTexts: [
                    TypewriterAnimatedText(
                      '5 Minute',
                      textStyle: Theme.of(context).textTheme.headlineMedium,
                      cursor: '।',
                      speed: const Duration(milliseconds: 200),
                    ),
                  ],
                )
              : Padding(
                  padding: const EdgeInsets.fromLTRB(6, 5, 0, 0),
                  child: Text(
                    '5 Minute ',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
          (animate)
              ? AnimatedTextKit(
                  pause: const Duration(milliseconds: 3000),
                  isRepeatingAnimation: false,
                  repeatForever: false,
                  animatedTexts: [
                    TyperAnimatedText(''),
                    TypewriterAnimatedText(
                      'संस्कृतम् ।',
                      textStyle: Theme.of(context).textTheme.displayMedium,
                      cursor: '।',
                      speed: const Duration(milliseconds: 200),
                    ),
                  ],
                )
              : Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 4, 0),
                  child: Text('संस्कृतम् । ',
                      style: Theme.of(context).textTheme.displayMedium),
                ),
          const SizedBox(height: 10),
          const SizedBox(
            width: 50,
            height: 50,
            child: CircularProgressIndicator(
              color: ConstColors.primary,
            ),
          ),
        ],
      ),
    ),
  );
}
