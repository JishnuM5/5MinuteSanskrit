import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sanskrit_web_app/login_page.dart';

import 'classes.dart';
import 'firebase_options.dart';
import 'profile_page.dart';
import 'quiz_page.dart';
import 'app_bars.dart';
import 'quiz_page_helpers.dart';
import 'themes.dart';

//This is the main method, from where the code runs.
void main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

final navigatorKey = GlobalKey<NavigatorState>();

// This widget is the root of my application.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // I have two Provider classes, which contain app states lifted out of the widget.
        ChangeNotifierProvider<MyAppState>(create: (context) => MyAppState()),
        ChangeNotifierProvider<MyQuizState>(create: (context) => MyQuizState()),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        title: '5 Minute संस्कृतम्',
        theme: theme,
        home: const LoginPage(),
      ),
    );
  }
}

// This class contains app states lifted out of the widget tree.
class MyAppState extends ChangeNotifier {
  int _pageIndex = 0;

  void onItemTapped(int index) {
    _pageIndex = index;
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// This class manages the framework of the app.
class _MyHomePageState extends State<MyHomePage> {
  // The selected index state manages page navigation.
  @override
  Widget build(BuildContext context) {
    Widget page;
    Widget? appBar;
    switch (context.watch<MyAppState>()._pageIndex) {
      case 0:
        page = const MainPage();
        appBar = const NavBar(navBarIndex: 0);
        break;
      case 1:
        page = const ProfilePage();
        appBar = const NavBar(navBarIndex: 1);
        break;
      case 2:
        page = QuizPage(currentQuiz: context.read<MyQuizState>().currentQuiz);
        appBar = const QuizBar(navBarIndex: 1);
      case 3:
        page = const SummaryPage();
        appBar = const QuizBar(navBarIndex: 1);
        break;
      default:
        throw UnimplementedError();
    }

    int totalPoints = 0;
    for (Quiz quiz in context.watch<MyQuizState>().quizzes) {
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
          // This widget is the point counter.
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
                borderRadius: const BorderRadius.all(Radius.circular(7)),
                color: Theme.of(context).primaryColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 3,
                    blurRadius: 5,
                    offset: const Offset(0, 1),
                  ),
                ],
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
    for (Quiz quiz in context.watch<MyQuizState>().quizzes) {
      if (quiz.show) {
        quizList.add(QuizTile(quiz: quiz, index: counter));
        counter++;
      }
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
            const SizedBox(width: 300, height: 300),
            const AddtoDB(),
          ],
        ),
      ),
    );
  }
}

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
      // A single quiz tile
      child: InkWellBox(
        maxWidth: 800,
        maxHeight: 200,
        color: Theme.of(context).primaryColor,
        child: Text(
          quiz.name,
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        onTap: () {
          context.read<MyQuizState>().setCurrentQuiz(index);
          if (context.read<MyQuizState>().quizzes[index].showSummary) {
            context.read<MyAppState>().onItemTapped(3);
          } else {
            context.read<MyAppState>().onItemTapped(2);
          }
          context.read<MyQuizState>().reset();
        },
      ),
    );
  }
}

class AddtoDB extends StatefulWidget {
  const AddtoDB({
    super.key,
  });

  @override
  State<AddtoDB> createState() => _AddtoDBState();
}

// This class is a small widget at the end of the home page that enables users to write to the database.
class _AddtoDBState extends State<AddtoDB> {
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 50,
          width: 800,
          child: TextField(controller: controller),
        ),
        IconButton(
          onPressed: () {
            final question = controller.text;
            createQuestion(question);
          },
          icon: const Icon(
            Icons.add,
          ),
        )
      ],
    );
  }
}

// This is a method that writes a question to the database.
Future createQuestion(String question) async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  final quiz2 = firestore.collection('quizzes').doc('quiz2');

  final json = {'question': question};

  await quiz2.set(json);
}

// This is the animated logo that is displayed on the main page.
Widget animatedLogo(BuildContext context, bool animate) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
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
                TyperAnimatedText(""),
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
