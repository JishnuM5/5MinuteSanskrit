import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main.dart';
import 'classes.dart';
import 'quiz_page_helpers.dart';

// This class contains app states, specifically for the quiz, lifted out of the widget tree.
class MyQuizState extends ChangeNotifier {
  late Quiz quiz;

  // A sample quiz.
  final sampleQuiz = const Quiz(
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

  Future<Quiz> readQuiz() {
    late Map<String, dynamic> data;
    late String name;

    final quiz1Doc =
        FirebaseFirestore.instance.collection('quizzes').doc('quiz1');
    return quiz1Doc.get().then(
      (DocumentSnapshot doc) async {
        data = doc.data() as Map<String, dynamic>;
        final List<Question> questions = [];
        for (dynamic question in data.values) {
          if (question is Map<String, dynamic>) {
            questions.add(Question.fromMap(question));
          } else {
            name = question;
          }
        }

        quiz = Quiz(questions: questions, name: name);
        await Future.delayed(const Duration(seconds: 4), () {});
        return Future.value(quiz);
      },
    );
  }

  int selectedIndex = -1;
  bool ansSubmitted = false;
  int currentQ = 0;
  int points = 0;
  int correctQs = 0;
  bool showSummary = false;

  void onAnsSelected(int index) {
    selectedIndex = index;
    notifyListeners();
  }

  void onAnsSubmitted(int numPoints) {
    if (selectedIndex == quiz.questions[currentQ].correctIndex) {
      points += numPoints;
      correctQs++;
    }
    ansSubmitted = true;
    notifyListeners();
  }

  // This method resets the question page when entering the quiz or going to the next question.
  void reset() {
    if (currentQ == quiz.questions.length - 1) {
      showSummary = true;
    } else {
      if (ansSubmitted) {
        currentQ++;
      }
    }
    selectedIndex = -1;
    ansSubmitted = false;
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
            child: IntrinsicHeight(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // The question.
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 5.0, vertical: 25),
                    child: Text(
                      watchState.quiz.questions[currentQ].question,
                      style: isSanskrit(
                              watchState.quiz.questions[currentQ].question)
                          ? Theme.of(context).textTheme.displayMedium!.copyWith(
                              fontFamily: GoogleFonts.montserrat().fontFamily)
                          : Theme.of(context).textTheme.displaySmall,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 5),

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
                          // If an option is selected, it will submit the answer and add 5 points if the it's is correct.
                          // If answer has already been submitted, this button will reset the question page and move on to the next question.
                          onPressed: (watchState.selectedIndex == -1)
                              ? null
                              : () => {
                                    if (readState.ansSubmitted)
                                      {
                                        readState.reset(),
                                        if (watchState.showSummary)
                                          {
                                            context
                                                .read<MyAppState>()
                                                .onItemTapped(3)
                                          }
                                      }
                                    else
                                      {readState.onAnsSubmitted(5)}
                                  },
                          style: OutlinedButton.styleFrom(
                            side: watchState.selectedIndex == -1
                                ? null
                                : const BorderSide(width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(7),
                            ),
                          ),
                          child: Text(
                            watchState.ansSubmitted ? "Next" : "Submit",
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
