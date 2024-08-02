// This file contains the quiz page

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'classes.dart';
import 'my_app_state.dart';
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
    Quiz quiz = watchState.quizzes[widget.currentQuiz];
    //var currentQ = watchState.showQs[sesh.currentQ - watchState.offsetIndex];
    var currentQ = quiz.questions[quiz.currentQ];

    return Scaffold(
      // This is a scroll view of questions
      body: LayoutBuilder(
        builder: (context, constraints) {
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
                        currentQ.question,
                        style: isSanskrit(currentQ.question)
                            ? Theme.of(context)
                                .textTheme
                                .displayMedium!
                                .copyWith(
                                  fontFamily:
                                      GoogleFonts.montserrat().fontFamily,
                                )
                            : Theme.of(context).textTheme.displaySmall,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 5),

                    // The four answers
                    Expanded(
                        child: AnswerTile(
                      option: currentQ.answers[0],
                      index: 0,
                      currentQuiz: widget.currentQuiz,
                    )),
                    Expanded(
                        child: AnswerTile(
                      option: currentQ.answers[1],
                      index: 1,
                      currentQuiz: widget.currentQuiz,
                    )),
                    Expanded(
                        child: AnswerTile(
                      option: currentQ.answers[2],
                      index: 2,
                      currentQuiz: widget.currentQuiz,
                    )),
                    Expanded(
                        child: AnswerTile(
                      option: currentQ.answers[3],
                      index: 3,
                      currentQuiz: widget.currentQuiz,
                    )),

                    // This is the next/submit button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: SizedBox(
                            width: 125,
                            child: ElevatedButton(
                              // If a question option isn't selected, the user can't click submit
                              // If an option is selected, it submits the answer
                              // If answer has been submitted, it resets the page and move to the next question
                              onPressed: (watchState.selectedIndex == -1)
                                  ? null
                                  : () {
                                      if (quiz.ansSubmitted) {
                                        readState.reset();
                                      } else {
                                        readState.onAnsSubmitted();
                                      }
                                    },
                              style: watchState.selectedIndex == -1
                                  ? OutlinedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      backgroundColor:
                                          ConstColors.primary.withOpacity(0.7),
                                    )
                                  : null,
                              child: Text(
                                quiz.ansSubmitted ? 'Next' : 'Submit',
                              ),
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
        },
      ),
    );
  }
}

// This widget is an answer tile, shown on the quiz page with an answer option
class AnswerTile extends StatelessWidget {
  const AnswerTile({
    super.key,
    required this.index,
    required this.option,
    required this.currentQuiz,
  });

  final int index;
  final String option;
  final int currentQuiz;

  @override
  Widget build(BuildContext context) {
    var watchState = context.watch<MyAppState>();
    var readState = context.read<MyAppState>();
    Quiz quiz = readState.quizzes[currentQuiz];
    Border? border;

    // Here, the border of an answer is set based on selection/submission
    if (watchState.selectedIndex == index) {
      if (watchState.quizzes[currentQuiz].ansSubmitted) {
        if (quiz.questions[quiz.currentQ].correctIndex == index) {
          border = Border.all(
            color: ConstColors.green,
            width: 4.0,
          );
        } else {
          border = Border.all(
            color: ConstColors.red,
            width: 4.0,
          );
        }
      } else {
        border = Border.all(
          color: ConstColors.primary,
          width: 4.0,
        );
      }
    } else {
      if (watchState.quizzes[currentQuiz].ansSubmitted &&
          quiz.questions[quiz.currentQ].correctIndex == index) {
        border = Border.all(
          color: ConstColors.green,
          width: 4.0,
        );
      } else {
        border = null;
      }
    }

    // This is the widget that contains the answer
    return Padding(
      padding: const EdgeInsets.all(10),
      child: MouseRegion(
        cursor: watchState.quizzes[currentQuiz].ansSubmitted
            ? SystemMouseCursors.basic
            : SystemMouseCursors.click,
        child: GestureDetector(
          onTap: watchState.quizzes[currentQuiz].ansSubmitted
              ? null
              : () => readState.onAnsSelected(index),
          child: Container(
            decoration: BoxDecoration(
              border: border,
              borderRadius: BorderRadius.circular(10),
              color: ConstColors.shade,
              boxShadow: [shadow],
            ),
            padding: const EdgeInsets.all(10.0),
            alignment: Alignment.center,
            child: Text(
              option,
              style: isSanskrit(option)
                  ? Theme.of(context).textTheme.bodyLarge
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}
