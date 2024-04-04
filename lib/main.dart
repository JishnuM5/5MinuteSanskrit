import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'quiz_page.dart';
import 'app_bars.dart';
import 'themes.dart';
import 'package:firebase_database/firebase_database.dart';

//This is the main method, from where the code runs.
void main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

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
        debugShowCheckedModeBanner: false,
        title: '5 Minute संस्कृतम्',
        theme: theme,
        home: const MyHomePage(title: '5 Minute संस्कृतम्'),
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
    Widget appBar;
    switch (context.watch<MyAppState>()._pageIndex) {
      case 0:
        page = const MainPage();
        appBar = const NavBar(navBarIndex: 0);
        break;
      case 1:
        page = const Placeholder();
        appBar = const NavBar(navBarIndex: 1);
        break;
      case 2:
        page = const QuizPage();
        appBar = const QuizBar(navBarIndex: 1);
      case 3:
        page = const SummaryPage();
        appBar = const QuizBar(navBarIndex: 1);
        break;
      default:
        throw UnimplementedError();
    }

    return Scaffold(
      // The top bar of the app
      appBar: AppBar(
        toolbarHeight: 60,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            // const Image(
            //   image: AssetImage('assets/logo.png'),
            //   height: 30,
            // ),
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
              child: Text(
                '${context.watch<MyQuizState>().points}',
                style: TextStyle(
                  fontSize: 27.5,
                  fontFamily: GoogleFonts.courierPrime().fontFamily,
                ),
              ),
            ),
          ),
        ],
      ),
      // The bottom navigation bar of the app
      bottomNavigationBar: appBar,
      // The body of the app
      body: page,
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
    return Scaffold(
      // A scroll view of the quiz tiles
      body: SingleChildScrollView(
        child: Column(
          children: [
            Text(
              "This Week's Quizzes",
              style:
                  DefaultTextStyle.of(context).style.apply(fontSizeFactor: 2.0),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Divider(),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              // A single quiz tile
              child: InkWell(
                onTap: () {
                  context.read<MyAppState>().onItemTapped(2);
                  context.read<MyQuizState>().reset();
                },
                highlightColor: Colors.blueGrey.withOpacity(0.2),
                splashColor: Colors.blueGrey.withOpacity(0.5),
                child: Ink(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(7)),
                    color: Theme.of(context).primaryColor,
                  ),
                  child: Container(
                    constraints:
                        const BoxConstraints.tightFor(width: 800, height: 200),
                    padding: const EdgeInsets.all(15.0),
                    alignment: Alignment.center,
                    child: Text(
                      context.read<MyQuizState>().quiz.name,
                      style: DefaultTextStyle.of(context).style.apply(
                          fontSizeFactor: 2.0,
                          fontFamily: GoogleFonts.courierPrime().fontFamily),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// This is a text animation I want to use later in my code; possibly for the login/loading page.
Widget useLater() {
  return AnimatedTextKit(
    isRepeatingAnimation: true,
    repeatForever: false,
    animatedTexts: [
      TypewriterAnimatedText(
        'some text',
        cursor: '।',
        speed: const Duration(milliseconds: 100),
      )
    ],
  );
}
