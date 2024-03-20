import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'quiz_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of my application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
          //fontFamily:
        ),
        home: const MyHomePage(title: '5 Minute संस्कृतम्'),
      ),
    );
  }
}

// This class contains app states lifted out of the widget tree
class MyAppState extends ChangeNotifier {
  int _pageIndex = 0;

  void _onItemTapped(int index) {
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
    var appState = context.watch<MyAppState>();
    Widget page;
    Widget appBar;
    switch (appState._pageIndex) {
      case 0:
        page = const MainPage();
        appBar = NavBar(
          appState: appState,
          navBarIndex: 0,
        );

        break;
      case 1:
        page = const Placeholder();
        appBar = NavBar(
          appState: appState,
          navBarIndex: 1,
        );
        break;
      case 2:
        page = const QuizPage();
        appBar = QuizBar(
          appState: appState,
          navBarIndex: 1,
        );
      default:
        throw UnimplementedError();
    }

    return Scaffold(
      // The top bar of the app
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Row(
          children: [
            Image(
              image: AssetImage('assets/logo.png'),
              height: 30,
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: Text('App Name'),
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
              child: const Text('',
                  style:
                      TextStyle(fontSize: 20.0) //DefaultTextStyle.of(context)
                  // .style
                  // .apply(fontSizeFactor: 2.0), <-Future Code
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

//This is the navigation bar that will be displayed on the main page
class NavBar extends StatelessWidget {
  const NavBar({super.key, required this.appState, required this.navBarIndex});

  final MyAppState appState;
  final int navBarIndex;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      //This method is passed as a callback function, so parameter is implicit
      //Still, I'm explicitly calling it here with a lambda function for comprehensibility
      // I also don't need a currentIndex property because I don't need to access it.
      onDestinationSelected: (int index) => appState._onItemTapped(index),
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

class QuizBar extends StatelessWidget {
  const QuizBar({
    super.key,
    required this.appState,
    required this.navBarIndex,
  });

  final MyAppState appState;
  final int navBarIndex;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: navBarIndex,
      onDestinationSelected: (int index) => appState._onItemTapped(index),
      //indicatorColor: Colors.transparent,
      destinations: <Widget>[
        const NavigationDestination(
          icon: Icon(Icons.arrow_back),
          label: 'Home',
        ),
        const Center(child: Text('Sample Quiz')),
        Center(
          child: Container(
            padding: const EdgeInsets.fromLTRB(10, 2.5, 10, 2.5),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.black,
              ),
              borderRadius: const BorderRadius.all(Radius.circular(7)),
              color: Theme.of(context).primaryColor,
            ),
            child: Text(
              '⅕',
              style:
                  DefaultTextStyle.of(context).style.apply(fontSizeFactor: 2.0),
            ),
          ),
        )
      ],
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
            const Text("This Week's Quizzes", style: TextStyle(fontSize: 40)),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Divider(),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              // A single quiz tile
              child: InkWell(
                onTap: () {
                  context.read<MyAppState>()._onItemTapped(2);
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
                      style: DefaultTextStyle.of(context)
                          .style
                          .apply(fontSizeFactor: 2.0),
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
