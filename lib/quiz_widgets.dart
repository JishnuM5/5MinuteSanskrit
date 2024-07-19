// This class contains other widgets used on the quiz page

import 'dart:ui';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'classes.dart';
import 'my_app_state.dart';
import 'themes.dart';

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
      if (watchState.quizzes[currentQuiz].ansSubmitted &&
          quiz.questions[quiz.currentQ].correctIndex == index) {
        border = Border.all(
          color: Colors.green[800]!,
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
              color: Theme.of(context).primaryColorLight,
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

// This is the summary page shown after the user answers all questions
class SummaryPage extends StatefulWidget {
  const SummaryPage({super.key});

  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  final _confettiController = ConfettiController();
  bool isHovering = false;

  @override
  void initState() {
    super.initState();
    playConfettiAnimation();
  }

  void playConfettiAnimation() {
    _confettiController.play();
    Future.delayed(const Duration(milliseconds: 200), () {
      _confettiController.stop();
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    int currentQuiz = context.read<MyAppState>().currentQuiz;
    Session currentSesh =
        context.read<MyAppState>().quizzes[currentQuiz].currentSesh;

    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Column(
              children: [
                // A congraulatory message
                Text(
                  'उत्तमम्!',
                  style: textTheme.headlineLarge,
                ),
                const Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Divider(),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: MouseRegion(
                    onEnter: (event) => setState(() {
                      isHovering = true;
                    }),
                    onExit: (event) => setState(() {
                      isHovering = false;
                    }),
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                        onTap: playConfettiAnimation,
                        child: SizedBox(
                          height: 210,
                          width: 210,
                          child: Align(
                            alignment: Alignment.center,
                            child: Stack(
                              children: <Widget>[
                                Transform.translate(
                                  offset: const Offset(5, 5),
                                  child: ImageFiltered(
                                    imageFilter:
                                        ImageFilter.blur(sigmaY: 7, sigmaX: 7),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.transparent,
                                          width: 0,
                                        ),
                                      ),
                                      child: Opacity(
                                        opacity: 0.4,
                                        child: ColorFiltered(
                                          colorFilter: const ColorFilter.mode(
                                              Colors.black, BlendMode.srcATop),
                                          child: Image(
                                            image: const AssetImage(
                                              'assets/party-popper.png',
                                            ),
                                            height: (isHovering) ? 210 : 200,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Image(
                                  image: const AssetImage(
                                      'assets/party-popper.png'),
                                  height: (isHovering) ? 210 : 200,
                                ),
                              ],
                            ),
                          ),
                        )),
                  ),
                ),
                Row(
                  children: [
                    StatsBox(
                      stat: '${currentSesh.correctQs}/${currentSesh.totalQs}',
                      label: 'correct this session',
                    ),
                    StatsBox(
                      stat: formatMilliseconds(currentSesh.elapsedMS),
                      label: 'time spent',
                    ),
                    StatsBox(
                      stat: '${currentSesh.points}',
                      label: 'points earned this session',
                    ),
                  ],
                )
              ],
            ),
            ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              emissionFrequency: 0.2,
            ),
          ],
        ),
      ),
    );
  }

  String formatMilliseconds(int milliseconds) {
    int seconds = milliseconds ~/ 1000;
    int minutes = seconds ~/ 60;
    seconds = seconds % 60;

    String minutesStr = minutes.toString().padLeft(2, '0');
    String secondsStr = seconds.toString().padLeft(2, '0');

    return '$minutesStr:$secondsStr';
  }
}

class StatsBox extends StatelessWidget {
  const StatsBox({
    super.key,
    required this.stat,
    required this.label,
  });

  final String stat;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        // A box showing the number of points earned from this quiz
        child: InkWellBox(
          maxWidth: 400,
          maxHeight: 200,
          color: Theme.of(context).primaryColorLight,
          child: Column(
            children: [
              const SizedBox(height: 30),
              Text(
                stat,
                style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
          onTap: () {},
        ),
      ),
    );
  }
}
