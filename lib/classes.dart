// This file contains all of the custom classes used in the project

import 'dart:math';

// The question class manages each question
// It contains a question, a list of answers, and a correct answer index
class Question {
  final String question;
  final List<String> answers;
  final int correctIndex;

  int timesCorrect = 0;
  int timesAnswered = 0;
  DateTime? lastShown;
  DateTime? lastAnswered;

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

  void readFromState(Map<String, dynamic> qState) {
    timesCorrect = qState['timesCorrect'];
    timesAnswered = qState['timesAnswered'];

    final lSState = qState['lastShown'];
    if (lSState != null) {
      lastShown = lSState.toDate();
    }
    final lAState = qState['lastAnswered'];
    if (lAState != null) {
      lastAnswered = lAState.toDate();
    }

    print(
      'Correct: $timesCorrect/$timesAnswered, Last Answered: $lastAnswered, Last Shown: $lastShown',
    );
  }
}

// The quiz class manages a list of questions
// It also contains the quiz name and various variables that keep track of the quiz state
class Quiz {
  final List<Question> questions;
  final String name;
  final bool show;
  //TODO: implement
  final DateTime start;

  bool mastered = false;
  int points = 0;
  bool showSummary = false;
  int currentQ = 0;
  int correctQs = 0;

  Quiz(
      {required this.questions,
      required this.name,
      required this.show,
      required this.start});

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

    return (Quiz(
      questions: questions,
      name: quizMap['name'],
      show: quizMap['show'],
      start: quizMap['start'].toDate(),
    ));
  }

  // This method updates the quiz state variables based on a map
  void readFromState(Map<String, dynamic> quizState) {
    points = quizState['points'];
    showSummary = quizState['showSummary'];
    currentQ = quizState['currentQ'];
    correctQs = quizState['correctQs'];

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
  start: DateTime.fromMicrosecondsSinceEpoch(0),
  questions: [
    Question(
        question: 'Question 1',
        answers: ['Answer 1', 'Answer 2', 'Answer 3', 'Answer 4'],
        correctIndex: 0),
    Question(
        question: 'Question 2',
        answers: ['Answer 1', 'Answer 2', 'Answer 3', 'Answer 4'],
        correctIndex: 0),
    Question(
        question: 'Question 3',
        answers: ['Answer 1', 'Answer 2', 'Answer 3', 'Answer 4'],
        correctIndex: 0),
    Question(
        question: 'Question 4',
        answers: ['Answer 1', 'Answer 2', 'Answer 3', 'Answer 4'],
        correctIndex: 0),
    Question(
        question: 'Question 5',
        answers: ['Answer 1', 'Answer 2', 'Answer 3', 'Answer 4'],
        correctIndex: 0),
  ],
);

// The user class contains a map of quizStates and the user's name
class AppUser {
  String name;
  Map<String, Map<String, dynamic>> quizStates;

  // This constructor creates an empty user, used to initialize a variable;
  AppUser.empty() : this(name: '', quizStates: {});

  AppUser({required this.name, required this.quizStates});

  // This constructor creates a user from a map
  factory AppUser.fromMap(Map<String, dynamic> userMap) {
    return (AppUser(
        name: userMap['name'], quizStates: Map.from(userMap['quizStates'])));
  }
}
