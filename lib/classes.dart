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
// It also contains the quiz name and the number of points earned for the quiz.
class Quiz {
  final List<Question> questions;
  final String name;
  // int quizPoints = 0;

  const Quiz({required this.questions, required this.name});
}
