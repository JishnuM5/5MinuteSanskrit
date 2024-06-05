import 'dart:math';

// The question class manages each question.
// It contains a question, a list of answers, and a correct answer index.
class Question {
  final String question;
  final List<String> answers;
  final int correctIndex;

  const Question({
    required this.question,
    required this.answers,
    required this.correctIndex,
  });

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
}

// The quiz class manages a list of questions.
// It also contains the quiz name and various variables that keep track of the quiz state.
class Quiz {
  final List<Question> questions;
  final String name;
  final bool show;

  int points = 0;
  bool showSummary = false;
  int currentQ = 0;
  int correctQs = 0;

  Quiz({required this.questions, required this.name, required this.show});

  factory Quiz.fromMap(Map<String, dynamic> quizMap) {
    Map<String, Map<String, dynamic>> qMap = Map.from(quizMap['questions']);
    int maxIndex =
        qMap.keys.map((key) => int.parse(key.substring(1))).reduce(max);

    List<Question> questions = List.filled(
      maxIndex,
      const Question(answers: [], question: '', correctIndex: 0),
      growable: true,
    );

    qMap.forEach((key, value) {
      int index = int.parse(key.substring(1)) - 1;
      questions[index] = Question.fromMap(value);
    });

    return (Quiz(
      questions: questions,
      name: quizMap['name'],
      show: quizMap['show'],
    ));
  }

  void updateFromState(Map<String, dynamic> quizState) {
    points = quizState['points'];
    showSummary = quizState['showSummary'];
    currentQ = quizState['currentQ'];
    correctQs = quizState['correctQs'];
  }
}

// A sample quiz.
Quiz sampleQuiz = Quiz(
  name: 'Sample Quiz',
  show: true,
  questions: [
    const Question(
        question: 'Question 1',
        answers: ['Answer 1', 'Answer 2', 'Answer 3', 'Answer 4'],
        correctIndex: 0),
    const Question(
        question: 'Question 2',
        answers: ['Answer 1', 'Answer 2', 'Answer 3', 'Answer 4'],
        correctIndex: 0),
    const Question(
        question: 'Question 3',
        answers: ['Answer 1', 'Answer 2', 'Answer 3', 'Answer 4'],
        correctIndex: 0),
    const Question(
        question: 'Question 4',
        answers: ['Answer 1', 'Answer 2', 'Answer 3', 'Answer 4'],
        correctIndex: 0),
    const Question(
        question: 'Question 5',
        answers: ['Answer 1', 'Answer 2', 'Answer 3', 'Answer 4'],
        correctIndex: 0),
  ],
);

class AppUser {
  String name;
  Map<String, Map<String, dynamic>> quizStates;

  AppUser.empty() : this(name: '', quizStates: {});

  AppUser({required this.name, required this.quizStates});

  factory AppUser.fromMap(Map<String, dynamic> userMap) {
    return (AppUser(
        name: userMap['name'], quizStates: Map.from(userMap['quizStates'])));
  }
}
