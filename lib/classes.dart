// This file contains all of the custom classes used in the project

import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'themes.dart';

// The question class manages each question
// It contains a question, a list of answers, a correct answer index, and state variables
// The state variables: counts of the number times each is answered, and answered correctly
class Question {
  final String question;
  final List<String> answers;
  final int correctIndex;

  int timesCorrect = 0;
  int timesAnswered = 0;

  Question({
    required this.question,
    required this.answers,
    required this.correctIndex,
  });

  // This constructor creates a question from a map
  factory Question.fromMap(Map<String, dynamic> qMap) {
    List<String> mapAnswers = [];
    for (dynamic answer in qMap['answers']) {
      mapAnswers.add(answer.toString());
    }

    return Question(
      question: qMap['question'],
      answers: mapAnswers,
      correctIndex: qMap['correctIndex'],
    );
  }

  // This method updates state variables from a map
  void readFromState(Map<String, dynamic> qState) {
    timesCorrect = qState['timesCorrect'];
    timesAnswered = qState['timesAnswered'];
  }
}

// This is an enum to store quiz statuses
enum QuizStatus {
  green,
  yellow,
  red,
  complete,
}

// The quiz class manages a list of questions
// It also contains many variables that keep track of the quiz's metadata and state
class Quiz {
  // These variables must be initialized when creating a quiz object
  final List<Question> questions;
  final String name;
  final bool show;
  final DateTime start;
  final bool showHint;
  final bool canTransliterate;
  final String? hintPageRef;

  bool mastered = false;
  int points = 0;
  bool showSummary = false;
  bool ansSubmitted = false;
  int currentQ = 0;
  int correctQs = 0;
  // TODO: hardcoded to sessions of 5
  Session currentSesh = Session(totalQs: 5);
  DateTime? lastShown;

  QuizStatus status = QuizStatus.green;

  Quiz({
    required this.questions,
    required this.name,
    required this.show,
    required this.start,
    required this.showHint,
    required this.canTransliterate,
    this.hintPageRef,
  });

  // This constructor creates a quiz from a map, with questions ordered in a list
  factory Quiz.fromMap(Map<String, dynamic> quizMap) {
    Map<String, Map<String, dynamic>> qMap = Map.from(quizMap['questions']);
    // The number of questions is found and a list of that length is created
    int maxNum =
        qMap.keys.map((key) => int.parse(key.substring(1))).reduce(max);
    List<Question> questions = List.filled(
      maxNum,
      Question(answers: [], question: '', correctIndex: 0),
      growable: true,
    );

    // Each question is put into the list based on its index (from its name)
    qMap.forEach((key, value) {
      int index = int.parse(key.substring(1)) - 1;
      questions[index] = Question.fromMap(value);
    });

    return Quiz(
      questions: questions,
      name: quizMap['name'],
      show: quizMap['show'],
      start: quizMap['start'].toDate(),
      showHint: quizMap['showHint'],
      canTransliterate: quizMap['canTransliterate'],
      hintPageRef: quizMap['hintPageRef'],
    );
  }

  // This method updates the quiz state variables from a map
  void readFromState(Map<String, dynamic> quizState) {
    mastered = quizState['mastered'];
    points = quizState['points'];
    showSummary = quizState['showSummary'];
    ansSubmitted = quizState['ansSubmitted'];
    currentQ = quizState['currentQ'];
    correctQs = quizState['correctQs'];

    // The last shown variable is only added if it's not null
    final lSState = quizState['lastShown'];
    if (lSState != null) {
      lastShown = lSState.toDate();
    }

    // Reading the state of the current session
    Map<String, dynamic> seshState = Map.from(quizState['currentSesh']);
    currentSesh.readFromState(seshState);

    // Reading the state for all the questions
    for (int i = 0; i < questions.length; i++) {
      Map<String, dynamic>? qState = quizState['qStates']['q$i'];
      if (qState != null) {
        questions[i].readFromState(qState);
      }
    }
  }
}

// A sample quiz
Quiz sampleQuiz = Quiz(
  name: 'Sample Quiz',
  show: true,
  showHint: false,
  canTransliterate: true,
  start: DateTime.fromMicrosecondsSinceEpoch(0),
  questions: [
    Question(
      question: 'Question 1',
      answers: ['Answer 1', 'Answer 2', 'Answer 3', 'Answer 4'],
      correctIndex: 0,
    ),
    Question(
      question: 'Question 2',
      answers: ['Answer 1', 'Answer 2', 'Answer 3', 'Answer 4'],
      correctIndex: 0,
    ),
    Question(
      question: 'Question 3',
      answers: ['Answer 1', 'Answer 2', 'Answer 3', 'Answer 4'],
      correctIndex: 0,
    ),
    Question(
      question: 'Question 4',
      answers: ['Answer 1', 'Answer 2', 'Answer 3', 'Answer 4'],
      correctIndex: 0,
    ),
    Question(
      question: 'Question 5',
      answers: ['Answer 1', 'Answer 2', 'Answer 3', 'Answer 4'],
      correctIndex: 0,
    ),
  ],
);

// The user class contains a map of quizStates and the user's name
class AppUser {
  String name;
  String code;
  Map<String, Map<String, dynamic>> quizStates;

  AppUser({required this.name, required this.code, required this.quizStates});

  // This constructor creates a user from a map
  factory AppUser.fromMap(Map<String, dynamic> userMap) {
    return AppUser(
      name: userMap['name'],
      code: userMap['code'],
      quizStates: Map.from(userMap['quizStates']),
    );
  }
}

// This is a simpler user class for the leaderboard
class LeaderboardUser {
  String name;
  int lbPoints;

  LeaderboardUser({required this.name, required this.lbPoints});

  factory LeaderboardUser.fromMap(Map<String, dynamic> userMap) {
    return LeaderboardUser(
        name: userMap['name'], lbPoints: userMap['lbPoints']);
  }
}

// A sample leaderboard list
List<LeaderboardUser> sampleLBUsers = [
  LeaderboardUser(name: "LeBron James", lbPoints: 205),
  LeaderboardUser(name: "Serena Williams", lbPoints: 200),
  LeaderboardUser(name: "Lionel Messi", lbPoints: 175),
  LeaderboardUser(name: "Roger Federer", lbPoints: 220),
  LeaderboardUser(name: "Cristiano Ronaldo", lbPoints: 190),
  LeaderboardUser(name: "Usain Bolt", lbPoints: 140),
  LeaderboardUser(name: "Michael Phelps", lbPoints: 210),
  LeaderboardUser(name: "Simone Biles", lbPoints: 160),
  LeaderboardUser(name: "Tom Brady", lbPoints: 180),
  LeaderboardUser(name: "Rafael Nadal", lbPoints: 170),
  LeaderboardUser(name: "Virat Kohli", lbPoints: 155),
];

// The session class contains data variables which keep track of a batch of 5 questions
class Session {
  int elapsedMS;
  int totalQs;
  int currentQ;
  int correctQs;
  int points;
  DateTime? lastAnswered;

  Session({
    required this.totalQs,
    this.elapsedMS = 0,
    this.currentQ = 0,
    this.correctQs = 0,
    this.points = 0,
  });

  // This method updates state variables from a map
  void readFromState(Map<String, dynamic> seshState) {
    final lAState = seshState['lastAnswered'];
    if (lAState != null) {
      lastAnswered = lAState.toDate();
    }
    elapsedMS = seshState['elapsedMS'];
    totalQs = seshState['totalQs'];
    currentQ = seshState['currentQ'];
    correctQs = seshState['correctQs'];
    points = seshState['points'];
  }

  // This method returns a session as a map
  Map<String, dynamic> toMap() {
    Map<String, dynamic> seshMap = {
      'elapsedMS': elapsedMS,
      'totalQs': totalQs,
      'currentQ': currentQ,
      'correctQs': correctQs,
      'points': points,
    };

    // The last answered variable is only added if not null
    if (lastAnswered != null) {
      seshMap['lastAnswered'] = Timestamp.fromDate(lastAnswered!);
    }

    return seshMap;
  }
}

// The quiz hint page class creates a page widget that can be shown during a quiz
class QuizHintPage extends StatelessWidget {
  const QuizHintPage({
    super.key,
    required this.topic,
    required this.explainContent,
    required this.explainBullets,
    required this.explainPost,
    required this.exampleContent,
    required this.exampleBullets,
    required this.examplePost,
  });

  // Various string variables make up the quiz page
  final String topic;
  final String explainContent;
  final List<String> explainBullets;
  final String explainPost;
  final String exampleContent;
  final List<String> exampleBullets;
  final String examplePost;

  // This constructor builds a hint page from a map
  // All newline characters are replaced with new lines
  factory QuizHintPage.fromMap(Map<String, dynamic> hintMap) {
    List<String> explainBullets = [];
    for (dynamic explainBullet in hintMap['explainBullets']) {
      explainBullets.add(explainBullet.toString().replaceAll('\\n', '\n'));
    }

    List<String> exampleBullets = [];
    for (dynamic exampleBullet in hintMap['exampleBullets']) {
      exampleBullets.add(exampleBullet.toString().replaceAll('\\n', '\n'));
    }

    return QuizHintPage(
      topic: hintMap['topic'].replaceAll('\\n', '\n'),
      explainContent: hintMap['explainContent'].replaceAll('\\n', '\n'),
      explainBullets: explainBullets,
      explainPost: hintMap['explainPost'].replaceAll('\\n', '\n'),
      exampleContent: hintMap['exampleContent'].replaceAll('\\n', '\n'),
      exampleBullets: exampleBullets,
      examplePost: hintMap['examplePost'].replaceAll('\\n', '\n'),
    );
  }

  // The widget consists of a title and two paragraphs with information
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height - 50,
      width: MediaQuery.of(context).size.width - 15,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7.5, horizontal: 12.5),
        child: SingleChildScrollView(
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Image(
                        image: AssetImage('assets/colored-bulb.png'),
                        height: 30,
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Text(
                            'Hint: $topic',
                            style: Theme.of(context)
                                .textTheme
                                .displayMedium!
                                .copyWith(
                                  fontFamily:
                                      GoogleFonts.montserrat().fontFamily,
                                ),
                            softWrap: false,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Here an explanation of the concept is given
                  const SizedBox(height: 20),
                  Paragraph(
                    title: 'कः विषयः? (The Concept)',
                    content: explainContent,
                    bulletContent: explainBullets,
                    postContent: explainPost,
                  ),
                  // Here are some examples of the concept
                  const SizedBox(height: 15),
                  Paragraph(
                    title: 'उदाहरणानि (Examples)',
                    content: exampleContent,
                    bulletContent: exampleBullets,
                    postContent: examplePost,
                  ),
                ],
              ),
              Positioned(
                right: 2.5,
                top: 2.5,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
