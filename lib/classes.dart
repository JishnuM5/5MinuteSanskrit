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

  factory Question.fromMap(Map<String, dynamic> map) {
    List<String> mapAnswers = [];
    for (dynamic answer in map["answers"]) {
      mapAnswers.add(answer.toString());
    }

    return Question(
      question: map['question'],
      answers: mapAnswers,
      correctIndex: map['correctIndex'],
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
}

class QuizState {
  final String quizName;
  int points = 0;
  bool showSummary = false;
  int currentQ = 0;
  int correctQs = 0;

  QuizState({required this.quizName});
}

// A sample quiz.
Quiz sampleQuiz = Quiz(
  name: "Sample Quiz",
  show: true,
  questions: [
    const Question(
        question: "Question 1",
        answers: ["Answer 1", "Answer 2", "Answer 3", "Answer 4"],
        correctIndex: 0),
    const Question(
        question: "Question 2",
        answers: ["Answer 1", "Answer 2", "Answer 3", "Answer 4"],
        correctIndex: 0),
    const Question(
        question: "Question 3",
        answers: ["Answer 1", "Answer 2", "Answer 3", "Answer 4"],
        correctIndex: 0),
    const Question(
        question: "Question 4",
        answers: ["Answer 1", "Answer 2", "Answer 3", "Answer 4"],
        correctIndex: 0),
    const Question(
        question: "Question 5",
        answers: ["Answer 1", "Answer 2", "Answer 3", "Answer 4"],
        correctIndex: 0),
  ],
);

class User {
  String name;
  List<QuizState> quizStates;

  User({required this.name, required this.quizStates});
}
