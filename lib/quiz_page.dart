import 'package:flutter/material.dart';
//import 'package:provider/provider.dart';

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
            child: const IntrinsicHeight(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text('सः पुरुष्हः कार्यालये _ करोति'),
                  SizedBox(height: 50),
                  Expanded(child: AnswerTile(option: 'Answer 1')),
                  Expanded(child: AnswerTile(option: 'Answer 2')),
                  Expanded(child: AnswerTile(option: 'Answer 3')),
                  Expanded(child: AnswerTile(option: 'Answer 4')),
                  Text('Next'),
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
          style: DefaultTextStyle.of(context).style.apply(fontSizeFactor: 2.0),
        ),
      ),
    );
  }
}
