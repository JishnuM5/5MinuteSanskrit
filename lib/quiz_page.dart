// This file contains the quiz page

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'my_app_state.dart';
import 'quiz_widgets.dart';
import 'themes.dart';

// This class is the quiz page of the application
class QuizPage extends StatefulWidget {
  const QuizPage({required this.currentQuiz, super.key});
  final int currentQuiz;

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  @override
  Widget build(BuildContext context) {
    var watchState = context.watch<MyAppState>();
    var readState = context.read<MyAppState>();
    var quiz = watchState.quizzes[widget.currentQuiz];
    var currentQ = quiz.currentQ;

    return Scaffold(
      // This is a scroll view of questions
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
                  // The question
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

                  // The four answers
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

                  // This is the next/submit button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: OutlinedButton(
                          // If a question option isn't selected, the user can't click submit
                          // If an option is selected, it submits the answer
                          // If answer has been submitted, it resets the page and move to the next question
                          onPressed: (watchState.selectedIndex == -1)
                              ? null
                              : () {
                                  if (readState.ansSubmitted) {
                                    readState.reset();
                                    if (quiz.showSummary) {
                                      context.read<MyAppState>().navigateTo(3);
                                    }
                                  } else {
                                    readState.onAnsSubmitted();
                                  }
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
                            watchState.ansSubmitted ? 'Next' : 'Submit',
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
