// This is the framework of an answer tile.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'classes.dart';
import 'quiz_page.dart';
import 'themes.dart';

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
    var watchState = context.watch<MyQuizState>();
    var readState = context.read<MyQuizState>();
    Quiz quiz = readState.quizzes[currentQuiz];
    Border border;

    // Here, the border of an answer is set based on selection/submission.
    if (watchState.selectedIndex == index) {
      if (watchState.ansSubmitted) {
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
      if (watchState.ansSubmitted &&
          quiz.questions[quiz.currentQ].correctIndex == index) {
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
        cursor: watchState.ansSubmitted
            ? SystemMouseCursors.basic
            : SystemMouseCursors.click,
        child: GestureDetector(
          onTap: watchState.ansSubmitted
              ? null
              : () => readState.onAnsSelected(index),
          child: Container(
            decoration: BoxDecoration(
              border: border,
              borderRadius: const BorderRadius.all(Radius.circular(7)),
              color: Theme.of(context).primaryColorLight,
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

// This is my summary page.
class SummaryPage extends StatelessWidget {
  const SummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    Quiz quiz = context
        .read<MyQuizState>()
        .quizzes[context.read<MyQuizState>().currentQuiz];

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Text(
              "उत्तमम्!",
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const Padding(
              padding: EdgeInsets.all(5.0),
              child: Divider(),
            ),
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Image(
                image: AssetImage('assets/party-popper.png'),
                height: 200,
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: InkWellBox(
                      color: Theme.of(context).primaryColorLight,
                      maxWidth: 400,
                      maxHeight: 200,
                      child: Text(
                        "${quiz.correctQs}/${quiz.questions.length}",
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      onTap: () {},
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: InkWellBox(
                      maxWidth: 400,
                      maxHeight: 200,
                      color: Theme.of(context).primaryColorLight,
                      child: Text(
                        "${quiz.points} points earned",
                        style: Theme.of(context).textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      onTap: () {},
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

bool isSanskrit(String text) {
  var sanskrit = RegExp(r'[\u0900-\u097F]');
  return sanskrit.hasMatch(text);
}
