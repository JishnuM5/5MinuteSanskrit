// This class the summary page

import 'dart:ui';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'classes.dart';
import 'my_app_state.dart';
import 'themes.dart';

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

  // This method briefly plays the confetti animation
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
                // A congratulatory message
                Text(
                  'उत्तमम्!',
                  style: textTheme.displayMedium!.copyWith(
                    fontSize: 31.5,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Divider(),
                ),
                // A party popper button that scales when hovered on and shoots plays confetti on click
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
                                      // A custom shadow in the background
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
                                    'assets/party-popper.png',
                                  ),
                                  height: (isHovering) ? 210 : 200,
                                ),
                              ],
                            ),
                          ),
                        )),
                  ),
                ),
                // Various statistics about the current session
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        StatsTile(
                          stat:
                              '${currentSesh.correctQs} / ${currentSesh.totalQs}',
                          label: 'correct this session',
                          color: ConstColors.shadeLight,
                        ),
                        const SizedBox(width: 10),
                        StatsTile(
                          stat: formatMilliseconds(currentSesh.elapsedMS),
                          label: 'time spent',
                          color: ConstColors.shade,
                        ),
                        const SizedBox(width: 10),
                        StatsTile(
                          stat: '${currentSesh.points}',
                          label: 'points earned this session',
                          color: ConstColors.shadeDark,
                        ),
                      ],
                    ),
                  ),
                ),
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

  // This method formats milliseconds to minutes and seconds to display
  String formatMilliseconds(int milliseconds) {
    int seconds = milliseconds ~/ 1000;
    int minutes = seconds ~/ 60;
    seconds = seconds % 60;

    String minutesStr = minutes.toString().padLeft(2, '0');
    String secondsStr = seconds.toString().padLeft(2, '0');

    return '$minutesStr:$secondsStr';
  }
}

class StatsTile extends StatelessWidget {
  const StatsTile({
    super.key,
    required this.stat,
    required this.label,
    required this.color,
  });

  final String stat;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final tTheme = Theme.of(context).textTheme;
    TextStyle? statStyle =
        isSmallScreen(context) ? tTheme.displaySmall : tTheme.displayLarge;
    TextStyle? labelStyle =
        isSmallScreen(context) ? tTheme.labelSmall : tTheme.headlineSmall;

    return Expanded(
      child: InkWellBox(
        color: color,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              stat,
              style: statStyle!.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: labelStyle,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        onTap: () {},
      ),
    );
  }
}
