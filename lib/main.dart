import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_core/firebase_core.dart';
import 'auth_pages.dart';
import 'classes.dart';
import 'firebase_options.dart';
import 'my_app_state.dart';
import 'profile_page.dart';
import 'quiz_page.dart';
import 'app_bars.dart';
import 'quiz_widgets.dart';
import 'themes.dart';

//This is the main method, from where the code runs
void main() async {
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
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
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
        page = const ProfilePage();
        appBar = const NavBar(navBarIndex: 1);
        break;
      case 2:
        page = QuizPage(currentQuiz: context.read<MyAppState>().currentQuiz);
        appBar = const QuizBar(navBarIndex: 1);
      case 3:
        page = const SummaryPage();
        appBar = const QuizBar(navBarIndex: 1);
        break;
      default:
        throw UnimplementedError();
    }

    int totalPoints = 0;
    for (Quiz quiz in context.watch<MyAppState>().quizzes) {
      totalPoints += quiz.points;
    }

    return Scaffold(
      // The top bar of the app
      appBar: AppBar(
        toolbarHeight: 60,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
              child: logo,
            )
          ],
        ),
        actions: <Widget>[
          // This widget is the point counter
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
            child: Container(
              alignment: Alignment.center,
              width: 50,
              height: 37.5,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black,
                ),
                borderRadius: BorderRadius.circular(10),
                color: Theme.of(context).primaryColor,
                boxShadow: [shadow],
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 2.5),
                child: Text(
                  '$totalPoints',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
              ),
            ),
          ),
        ],
      ),
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
    int counter = 0;
    for (Quiz quiz in context.watch<MyAppState>().quizzes) {
      quizList.add(QuizTile(quiz: quiz, index: counter));
      counter++;
    }

    return Scaffold(
      // A scroll view of the quiz tiles
      body: SingleChildScrollView(
        child: Column(
          children: [
            Text("This Week's Quizzes",
                style: Theme.of(context).textTheme.displayLarge),
            const Padding(
              padding: EdgeInsets.all(5.0),
              child: Divider(),
            ),
            Column(
              children: quizList,
            ),
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
    return Padding(
      padding: const EdgeInsets.all(10.0),
      // A single box tile
      child: InkWellBox(
        maxWidth: 800,
        maxHeight: 200,
        color: Theme.of(context).primaryColor,
        child: Text(
          quiz.name,
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        // When a quiz tile is pressed, the app navigates to the respective quiz
        // Quiz page variables are set accordingly and previous temporary UI is reset
        onTap: () {
          context.read<MyAppState>().setCurrentQuiz(index);
          if (context.read<MyAppState>().quizzes[index].showSummary) {
            context.read<MyAppState>().navigateTo(3);
          } else {
            context.read<MyAppState>().navigateTo(2);
          }
          context.read<MyAppState>().reset();
        },
      ),
    );
  }
}

// This is the animated logo that is displayed on the main page.
Widget animatedLogo(BuildContext context, bool animate) {
  return Column(
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
      SizedBox(
        width: 50,
        height: 50,
        child: CircularProgressIndicator(
          color: Theme.of(context).primaryColor,
        ),
      )
    ],
  );
}
