import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyQuizState extends ChangeNotifier {
  int _selectedIndex = -1;
  final int _correctIndex = 0;

  void _onAnswerSelected(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  bool _onAnswerSubmitted() {
    notifyListeners();
    return _correctIndex == _selectedIndex;
  }
}

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
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text(
                      'सः पुरुष्हः कार्यालये _ करोति',
                      style: DefaultTextStyle.of(context)
                          .style
                          .apply(fontSizeFactor: 1.25),
                    ),
                    const SizedBox(height: 50),
                    const Expanded(
                        child: AnswerTile(option: 'Answer 1', index: 0)),
                    const Expanded(
                        child: AnswerTile(option: 'Answer 2', index: 1)),
                    const Expanded(
                        child: AnswerTile(option: 'Answer 3', index: 2)),
                    const Expanded(
                        child: AnswerTile(option: 'Answer 4', index: 3)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: OutlinedButton(
                            onPressed: () => {},
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(width: 1.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(7),
                              ),
                            ),
                            child: const Text("Submit"),
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
    var quizState = context.watch<MyQuizState>();
    Border border;
    if (quizState._selectedIndex == index) {
      border = Border.all(
        color: Theme.of(context).primaryColorDark,
        width: 4.0,
      );
    } else {
      border = Border.all(color: Colors.black, width: 1.5);
    }
    return Padding(
      padding: const EdgeInsets.all(10),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => context.read<MyQuizState>()._onAnswerSelected(index),
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
