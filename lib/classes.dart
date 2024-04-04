// The question class manages each question.
// It contains a question, a list of answers, and a correct answer index.
class Question {
  final String question;
  final List<String> answers;
  final int correctIndex;

  Question({
    required this.question,
    required this.answers,
    required this.correctIndex,
  });
}

// The quiz class manages a list of questions.
// It also contains the quiz name and the number of points earned for the quiz.
class Quiz {
  final List<Question> questions;
  final String name;
  int quizPoints = 0;

  Quiz({required this.questions, required this.name});
}
