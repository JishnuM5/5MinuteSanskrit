import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'quiz_page.dart';
import 'app_bars.dart';
import 'themes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of my application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
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

// This class contains app states lifted out of the widget tree
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

// This class is the manages the framework of the app
class _MyHomePageState extends State<MyHomePage> {
  // The selected index state manages page navigation
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
        page = const Placeholder();
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
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
            child: Container(
              padding: const EdgeInsets.all(5.0),
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
                    offset: const Offset(0, 1), // Changes position of shadow
                  ),
                ],
              ),
              child: Text('${context.watch<MyQuizState>().points}',
                  style: const TextStyle(fontSize: 20.0)),
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
                      'Sample Quiz',
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
