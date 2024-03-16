import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

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
        ),
        home: const MyHomePage(title: '5 Minute Sanskrit'),
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
    switch (appState._pageIndex) {
      case 0:
        page = const MainPage();
        break;
      case 1:
        page = const Placeholder();
        break;
      case 2:
        page = const QuizPage();
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
      bottomNavigationBar: NavigationBar(
        //This method is passed as a callback function, so parameter is implicit
        //Still, I'm explicitly calling it here with a lambda function for comprehensibility
        // I also don't need a currentIndex property because I don't need to access it.
        onDestinationSelected: (int index) => appState._onItemTapped(index),
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
      ),
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
                    child: const Text(
                      'Sample Quiz',
                      style: TextStyle(
                          fontSize: 20.0 //DefaultTextStyle.of(context)
                          // .style
                          // .apply(fontSizeFactor: 2.0), <-Future Code
                          ),
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

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // A scroll view of questions
      body: LayoutBuilder(builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
                minWidth: constraints.maxWidth,
                minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  const Text('सः पुरुष्हः कार्यालये _ करोति'),
                  Expanded(child: const AnswerTile(option: 'Answer 1')),
                  Expanded(child: const AnswerTile(option: 'Answer 2')),
                  Expanded(child: const AnswerTile(option: 'Answer 3')),
                  Expanded(child: const AnswerTile(option: 'Answer 4')),
                  const Text('Next'),
                  Container(
                      height: 500,
                      decoration: const BoxDecoration(color: Colors.blue))
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

class AnswerTile extends StatelessWidget {
  const AnswerTile({
    super.key,
    required this.option,
  });

  final String option;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(7)),
          color: Theme.of(context).primaryColorLight,
        ),
        padding: const EdgeInsets.all(15.0),
        alignment: Alignment.center,
        child: Text(
          option,
          style: const TextStyle(fontSize: 10.0 //DefaultTextStyle.of(context)
              // .style
              // .apply(fontSizeFactor: 2.0), <-Future Code
              ),
        ),
      ),
    );
  }
}
