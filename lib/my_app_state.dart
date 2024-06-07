import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sanskrit_web_app/main.dart';
import 'package:sanskrit_web_app/themes.dart';
import 'classes.dart';

// This class contains app states, lifted out of the widget tree.
class MyAppState extends ChangeNotifier {
  int pageIndex = 0;
  final userRef = FirebaseFirestore.instance.collection('users').doc(
        FirebaseAuth.instance.currentUser!.email!,
      );

  void navigateTo(int index) async {
    if (pageIndex == 2) {
      showDialog(
        context: navigatorKey.currentContext!,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );
      await updateUserStates();
    }
    pageIndex = index;
    navigatorKey.currentState!.popUntil((route) => route.isFirst);

    notifyListeners();
  }

  List<Quiz> quizzes = [];
  AppUser appUser = AppUser.empty();

  Future updateUserStates() async {
    for (Quiz quiz in quizzes) {
      try {
        await userRef.update({
          'quizStates.${quiz.name}.correctQs': quiz.correctQs,
          'quizStates.${quiz.name}.currentQ': quiz.currentQ,
          'quizStates.${quiz.name}.points': quiz.points,
          'quizStates.${quiz.name}.showSummary': quiz.showSummary,
        });
      } on Exception catch (error) {
        showTextSnackBar('Error saving data: $error');
      }
    }
  }

  void createUser(String name) {
    appUser.name = name;
  }

  Future updateUser(String name) async {
    createUser(name);
    try {
      await (userRef.update({'name': name}));
    } on Exception catch (error) {
      Future.error('$error');
    }
  }

  Future createUserInDB() async {
    print('Creating user in database...');
    try {
      await userRef.set({'name': appUser.name, 'quizStates': {}});
      return Future.value();
    } on Exception catch (error) {
      return Future.error('(From createUserInDB()) $error');
    }
  }

  Future readUser() async {
    print('Retrieving user data from database...');
    try {
      DocumentSnapshot<Map<String, dynamic>> value = await userRef.get();
      Map<String, dynamic> userMap = value.data()!;
      appUser = AppUser.fromMap(userMap);

      // Here, for each quiz retrieved
      for (Quiz quiz in quizzes) {
        Map<String, dynamic>? quizState = appUser.quizStates[quiz.name];
        if (quizState != null) {
          quiz.readFromState(quizState);
        }
      }
      return Future.value(appUser);
    } catch (error) {
      return Future.error('(From readUser()) $error');
    }
  }

  Future readQuiz() async {
    try {
      final quizRef = FirebaseFirestore.instance.collection('quizzes');
      QuerySnapshot<Map<String, dynamic>> value = await quizRef.get();
      quizzes = [];
      for (DocumentSnapshot<Map<String, dynamic>> doc in value.docs) {
        Map<String, dynamic> quizMap = doc.data()!;
        Quiz quiz = Quiz.fromMap(quizMap);
        if (quiz.show) {
          quizzes.add(quiz);
        }
      }

      await Future.delayed(const Duration(seconds: 4), () {});
      return Future.value(quizzes);
    } catch (error) {
      return Future.error('(From readQuiz()) $error');
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
    notifyListeners();
  }
}
