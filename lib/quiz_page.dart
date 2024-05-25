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
  List<Quiz> quizzes = [];

  Future readQuiz() {
    late Map<String, dynamic> quizData;

    final quizRef = FirebaseFirestore.instance.collection('quizzes');
    return quizRef.get().then((value) async {
      try {
        for (DocumentSnapshot<Map<String, dynamic>> doc in value.docs) {
          quizData = doc.data()!;

          final List<Question> questions = [];

          for (dynamic value in quizData.values) {
            if (value is Map<String, dynamic>) {
              questions.add(Question.fromMap(value));
            }
          }
          quizzes.add(Quiz(
            questions: questions,
            name: quizData["name"],
            show: quizData["show"],
          ));
          await Future.delayed(const Duration(seconds: 2), () {});
        }
        return Future.value(quizzes);
      } catch (e) {
        return Future.error('$e');
      }
    }).catchError((error) {
      return Future.error('$error');
    });
  }

  int currentQuiz = -1;
  int selectedIndex = -1;
  bool ansSubmitted = false;

  void onAnsSelected(int index) {
    selectedIndex = index;
    notifyListeners();
  }

  void onAnsSubmitted(int numPoints) {
    Quiz quiz = quizzes[currentQuiz];
    if (selectedIndex == quiz.questions[quiz.currentQ].correctIndex) {
      quiz.points += numPoints;
      quiz.correctQs++;
    }
    ansSubmitted = true;
    notifyListeners();
  }

  // This method resets the question page when entering the quiz or going to the next question.
  void reset() {
    Quiz quiz = quizzes[currentQuiz];
    if (quiz.currentQ == quizzes[currentQuiz].questions.length - 1 &&
        ansSubmitted) {
      quiz.showSummary = true;
    } else {
      if (ansSubmitted) {
        quiz.currentQ++;
      }
    }
    selectedIndex = -1;
    ansSubmitted = false;
    notifyListeners();
  }

  void setCurrentQuiz(int index) {
    currentQuiz = index;
  }
}

class QuizPage extends StatefulWidget {
  const QuizPage({required this.currentQuiz, super.key});
  final int currentQuiz;

  @override
  State<QuizPage> createState() => _QuizPageState();
}

// This class is a quiz page.
class _QuizPageState extends State<QuizPage> {
  @override
  Widget build(BuildContext context) {
    var watchState = context.watch<MyQuizState>();
    var readState = context.read<MyQuizState>();
    var quiz = watchState.quizzes[widget.currentQuiz];
    var currentQ = quiz.currentQ;

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
                      quiz.questions[currentQ].question,
                      style: isSanskrit(quiz.questions[currentQ].question)
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
                    option: quiz.questions[currentQ].answers[0],
                    index: 0,
                    currentQuiz: widget.currentQuiz,
                  )),
                  Expanded(
                      child: AnswerTile(
                    option: quiz.questions[currentQ].answers[1],
                    index: 1,
                    currentQuiz: widget.currentQuiz,
                  )),
                  Expanded(
                      child: AnswerTile(
                    option: quiz.questions[currentQ].answers[2],
                    index: 2,
                    currentQuiz: widget.currentQuiz,
                  )),
                  Expanded(
                      child: AnswerTile(
                    option: quiz.questions[currentQ].answers[3],
                    index: 3,
                    currentQuiz: widget.currentQuiz,
                  )),

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
                                        if (quiz.showSummary)
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
                              borderRadius: BorderRadius.circular(10),
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
