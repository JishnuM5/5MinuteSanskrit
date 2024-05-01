// This is the framework of an answer tile.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'quiz_page.dart';
import 'themes.dart';

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
    if (watchState.selectedIndex == index) {
      if (watchState.ansSubmitted) {
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
      if (watchState.ansSubmitted &&
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
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Text(
              "उत्तमम् !",
              style: Theme.of(context).textTheme.headlineLarge,
              //TODO
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
                        "${context.read<MyQuizState>().correctQs}/5 correct",
                        style: Theme.of(context).textTheme.headlineSmall, //TODO
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
                        "${context.read<MyQuizState>().points} points earned",
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
