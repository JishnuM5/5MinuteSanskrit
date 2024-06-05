import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'classes.dart';

// This class contains app states, lifted out of the widget tree.
class MyAppState extends ChangeNotifier {
  int pageIndex = 0;

  void onItemTapped(int index) async {
    if (pageIndex == 2) {
      await updateUser();
    }
    pageIndex = index;
    notifyListeners();
  }

  List<Quiz> quizzes = [];
  AppUser appUser = AppUser.empty();

  Future updateUser() {
    for (Quiz quiz in quizzes) {
      final userRef = FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.email);
      userRef.update({
        'quizStates.${quiz.name}.correctQs': quiz.correctQs,
        'quizStates.${quiz.name}.currentQ': quiz.currentQ,
        'quizStates.${quiz.name}.points': quiz.points,
        'quizStates.${quiz.name}.showSummary': quiz.showSummary,
      });
    }
    return Future.value();
  }

  Future readQuiz() {
    final quizRef = FirebaseFirestore.instance.collection('quizzes');
    return quizRef.get().then((value) async {
      try {
        for (DocumentSnapshot<Map<String, dynamic>> doc in value.docs) {
          Map<String, dynamic> quizMap = doc.data()!;
          quizzes.add(Quiz.fromMap(quizMap));
        }

        await Future.delayed(const Duration(seconds: 4), () {});
        return Future.value(quizzes);
      } catch (e) {
        return Future.error('$e');
      }
    }).catchError((error) {
      return Future.error('$error');
    });
  }

  Future readUser() async {
    final userRef = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.email);
    try {
      DocumentSnapshot<Map<String, dynamic>> value = await userRef.get();
      Map<String, dynamic> userMap = value.data()!;
      appUser = AppUser.fromMap(userMap);

      for (Quiz quiz in quizzes) {
        Map<String, dynamic>? quizState = appUser.quizStates[quiz.name];
        if (quizState != null) {
          quiz.updateFromState(quizState);
        }
      }
      return Future.value(appUser);
    } catch (error) {
      return Future.error('$error');
    }
  }

  int currentQuiz = -1;
  int selectedIndex = -1;
  bool ansSubmitted = false;

  void onAnsSelected(int index) {
    selectedIndex = index;
    notifyListeners();
  }

  void onAnsSubmitted(int numPoints) {
    Quiz quiz = quizzes[currentQuiz];
    if (selectedIndex == quiz.questions[quiz.currentQ].correctIndex) {
      quiz.points += numPoints;
      quiz.correctQs++;
    }
    ansSubmitted = true;
    notifyListeners();
  }

  // This method resets the question page when entering the quiz or going to the next question.
  void reset() {
    Quiz quiz = quizzes[currentQuiz];
    if (quiz.currentQ == quizzes[currentQuiz].questions.length - 1 &&
        ansSubmitted) {
      quiz.showSummary = true;
    } else {
      if (ansSubmitted) {
        quiz.currentQ++;
      }
    }
    selectedIndex = -1;
    ansSubmitted = false;
    notifyListeners();
  }

  void setCurrentQuiz(int index) {
    currentQuiz = index;
  }
}
