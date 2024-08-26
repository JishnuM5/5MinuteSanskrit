// This file contains the quiz page

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:inditrans/inditrans.dart' as transl;
import 'app_bars.dart';
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
  bool isTransliterated = false;
  bool showTranslSwitch = false;

  late String question;
  late List<String> answers;

  // When the page is initialized, if this is a new quiz and it has a hint page, display it
  @override
  void initState() {
    super.initState();
    var readState = context.read<MyAppState>();
    Quiz quiz = readState.quizzes[readState.currentQuiz];
    question = quiz.questions[quiz.currentQ].question;
    answers = List.from(quiz.questions[quiz.currentQ].answers);

    SchedulerBinding.instance.addPostFrameCallback(
      (_) async {
        if (readState.isNewQuiz() && quiz.showHint) {
          showHintPage(context);
        }

        // If the quiz allows for it, initialize the transliteration API
        if (quiz.canTransliterate) {
          try {
            await transl.init();
            setState(() {
              showTranslSwitch = true;
            });
          } catch (error) {
            showTextSnackBar('Error initializing transliterator: $error');
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Various reference variables for readability
    var watchState = context.watch<MyAppState>();
    var readState = context.read<MyAppState>();
    Quiz quiz = watchState.quizzes[widget.currentQuiz];
    Question q = quiz.questions[quiz.currentQ];

    // Display either transliterated or original text, based on the toggle switch value
    if (isTransliterated) {
      setState(() {
        question = transliterate(q.question);
        for (int i = 0; i < 4; i++) {
          answers[i] = transliterate(q.answers[i]);
        }
      });
    } else {
      setState(() {
        question = q.question;
        answers = List.from(q.answers);
      });
    }

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
                    (showTranslSwitch)
                        // A toggle switch, shown if the quiz allows transliteration and the API is initialized
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                "Transliterate:",
                                style: Theme.of(context).textTheme.labelSmall,
                              ),
                              Transform.scale(
                                scale: 0.75,
                                child: Switch(
                                  value: isTransliterated,
                                  onChanged: (value) => setState(() {
                                    isTransliterated = value;
                                  }),
                                ),
                              ),
                            ],
                          )
                        : const SizedBox(height: 10),

                    // The question
                    Padding(
                      padding: const EdgeInsets.all(5),
                      child: Text(
                        question,
                        style: isSanskrit(question)
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
                    const SizedBox(height: 15),

                    // The four answers
                    Expanded(
                      child: AnswerTile(
                        option: answers[0],
                        index: 0,
                        currentQuiz: widget.currentQuiz,
                      ),
                    ),
                    Expanded(
                      child: AnswerTile(
                        option: answers[1],
                        index: 1,
                        currentQuiz: widget.currentQuiz,
                      ),
                    ),
                    Expanded(
                      child: AnswerTile(
                        option: answers[2],
                        index: 2,
                        currentQuiz: widget.currentQuiz,
                      ),
                    ),
                    Expanded(
                      child: AnswerTile(
                        option: answers[3],
                        index: 3,
                        currentQuiz: widget.currentQuiz,
                      ),
                    ),

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

  // This method transliterates a given string from Devanagari to IAST
  String transliterate(String input) {
    // This regular expression identifies devanagari text
    RegExp devanagariRegex = RegExp(
      r'''[\u0900-\u097F\u0966-\u096F\s,()\-\u0964\u0965.!?:"\';]+''',
    );

    // In this sub-method, the API is used to translate a substring
    String transliteratePart(String devanagari) {
      return transl.transliterate(
        devanagari,
        transl.Script.devanagari,
        transl.Script.iast,
      );
    }

    // Substrings up to a match are added to a result string as is
    // Devanagari substrings are transliterated before being added
    StringBuffer result = StringBuffer();
    int lastMatchEnd = 0;
    devanagariRegex.allMatches(input).forEach((match) {
      result.write(input.substring(lastMatchEnd, match.start));
      result.write(transliteratePart(match.group(0)!));
      lastMatchEnd = match.end;
    });

    // If there is any non-Devanagari content at the end of the string, it's added, too
    if (lastMatchEnd < input.length) {
      result.write(input.substring(lastMatchEnd));
    }

    return result.toString();
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
      // If this tile is the selected tile,
      // Set the border to green/red if the answer was submitted and it was right/wrong
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
        // Set the border to blue if answer isn't submitted
      } else {
        border = Border.all(
          color: ConstColors.primary,
          width: 4.0,
        );
      }
      // If the tile wasn't selected
      // Set the border to green if the answer was submitted and this is the correct tile
    } else {
      if (watchState.quizzes[currentQuiz].ansSubmitted &&
          quiz.questions[quiz.currentQ].correctIndex == index) {
        border = Border.all(
          color: ConstColors.green,
          width: 4.0,
        );
        // Else, the tile has no border
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
