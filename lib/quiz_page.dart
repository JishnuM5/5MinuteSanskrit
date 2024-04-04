import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sanskrit_web_app/main.dart';
import 'classes.dart';

// This class contains app states, specifically for the quiz, lifted out of the widget tree
class MyQuizState extends ChangeNotifier {
  // A sample quiz.
  final quiz = Quiz(
    name: "Sample Quiz",
    questions: [
      Question(
          question: "Question 1",
          answers: ["Answer 1", "Answer 2", "Answer 3", "Answer 4"],
          correctIndex: 0),
      Question(
          question: "Question 2",
          answers: ["Answer 1", "Answer 2", "Answer 3", "Answer 4"],
          correctIndex: 0),
      Question(
          question: "Question 3",
          answers: ["Answer 1", "Answer 2", "Answer 3", "Answer 4"],
          correctIndex: 0),
      Question(
          question: "Question 4",
          answers: ["Answer 1", "Answer 2", "Answer 3", "Answer 4"],
          correctIndex: 0),
      Question(
          question: "Question 5",
          answers: ["Answer 1", "Answer 2", "Answer 3", "Answer 4"],
          correctIndex: 0),
    ],
  );

  int _selectedIndex = -1;
  bool _ansSubmitted = false;
  int currentQ = 0;
  int points = 0;
  bool showSummary = false;

  void _addPoints(int numPoints) {
    if (_selectedIndex == quiz.questions[currentQ].correctIndex) {
      points += numPoints;
    }
  }

  void _onAnsSelected(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  void _onAnsSubmitted() {
    _ansSubmitted = true;
    notifyListeners();
  }

  // This method resets the question page when entering the quiz or going to the next question.
  void reset() {
    if (currentQ == quiz.questions.length - 1) {
      showSummary = true;
    } else {
      if (_ansSubmitted) {
        currentQ++;
      }
    }
    _selectedIndex = -1;
    _ansSubmitted = false;
    notifyListeners();
  }
}

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

// This class is a quiz page.
class _QuizPageState extends State<QuizPage> {
  @override
  Widget build(BuildContext context) {
    var watchState = context.watch<MyQuizState>();
    var readState = context.read<MyQuizState>();
    var currentQ = watchState.currentQ;
    return Scaffold(
      // A scroll view of questions.
      body: LayoutBuilder(builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
                minWidth: constraints.maxWidth,
                minHeight: constraints.maxHeight),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    // The question.
                    Text(watchState.quiz.questions[currentQ].question,
                        style: DefaultTextStyle.of(context)
                            .style
                            .apply(fontSizeFactor: 1.25)),
                    const SizedBox(height: 50),

                    // The four answers.
                    Expanded(
                        child: AnswerTile(
                            option:
                                watchState.quiz.questions[currentQ].answers[0],
                            index: 0)),
                    Expanded(
                        child: AnswerTile(
                            option:
                                watchState.quiz.questions[currentQ].answers[1],
                            index: 1)),
                    Expanded(
                        child: AnswerTile(
                            option:
                                watchState.quiz.questions[currentQ].answers[2],
                            index: 2)),
                    Expanded(
                        child: AnswerTile(
                            option:
                                watchState.quiz.questions[currentQ].answers[3],
                            index: 3)),

                    // This is the next/submit button.
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: OutlinedButton(
                            // If a question option isn't selected, you can't click submit.
                            // If an option is selected, it will add 5 points if the answer is correct and reset the question page.
                            onPressed: (watchState._selectedIndex == -1)
                                ? null
                                : () => {
                                      if (readState._ansSubmitted)
                                        {
                                          readState._addPoints(5),
                                          readState.reset(),
                                          if (watchState.showSummary)
                                            {
                                              context
                                                  .read<MyAppState>()
                                                  .onItemTapped(3)
                                            }
                                        }
                                      else
                                        {readState._onAnsSubmitted()}
                                    },
                            style: OutlinedButton.styleFrom(
                              side: watchState._selectedIndex == -1
                                  ? null
                                  : const BorderSide(width: 1.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(7),
                              ),
                            ),
                            child: Text(
                              watchState._ansSubmitted ? "Next" : "Submit",
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

// This is the framework of an answer tile.
class AnswerTile extends StatelessWidget {
  const AnswerTile({
    super.key,
    required this.index,
    required this.option,
  });

  final int index;
  final String option;

  @override
  Widget build(BuildContext context) {
    var watchState = context.watch<MyQuizState>();
    var readState = context.read<MyQuizState>();
    Border border;

    // Here, the border of an answer is set based on selection/submission.
    if (watchState._selectedIndex == index) {
      if (watchState._ansSubmitted) {
        if (readState.quiz.questions[readState.currentQ].correctIndex ==
            index) {
          border = Border.all(
            color: Colors.green[800]!,
            width: 4.0,
          );
        } else {
          border = Border.all(
            color: Colors.red[900]!,
            width: 4.0,
          );
        }
      } else {
        border = Border.all(
          color: Theme.of(context).primaryColorDark,
          width: 4.0,
        );
      }
    } else {
      if (watchState._ansSubmitted &&
          readState.quiz.questions[readState.currentQ].correctIndex == index) {
        border = Border.all(
          color: Colors.green[800]!,
          width: 4.0,
        );
      } else {
        border = Border.all(color: Colors.black, width: 1.5);
      }
    }

    // This is the widget that contains the answer.
    return Padding(
      padding: const EdgeInsets.all(10),
      child: MouseRegion(
        cursor: watchState._ansSubmitted
            ? SystemMouseCursors.basic
            : SystemMouseCursors.click,
        child: GestureDetector(
          onTap: watchState._ansSubmitted
              ? null
              : () => readState._onAnsSelected(index),
          child: Container(
            decoration: BoxDecoration(
              border: border,
              borderRadius: const BorderRadius.all(Radius.circular(7)),
              color: Theme.of(context).primaryColorLight,
            ),
            padding: const EdgeInsets.all(10.0),
            alignment: Alignment.center,
            child: Text(option),
          ),
        ),
      ),
    );
  }
}

// This is my summary page.
class SummaryPage extends StatelessWidget {
  const SummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Text(
              "उत्तमम् !",
              style:
                  DefaultTextStyle.of(context).style.apply(fontSizeFactor: 2.0),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Divider(),
            ),
            const Padding(
              padding: EdgeInsets.all(20.0),
              //IMAGE HERE
              child: Text(
                "🎉",
                style: TextStyle(fontSize: 200),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
