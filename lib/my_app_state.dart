// This file contains the MyAppState ChangeNotifier class for state management

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sanskrit_web_app/main.dart';
import 'package:sanskrit_web_app/themes.dart';
import 'classes.dart';

// This class contains app states, lifted out of the widget tree. It uses the Provider model
class MyAppState extends ChangeNotifier {
  int pageIndex = 0;
  // This is a reference to the current user's doc in the database
  final userRef = FirebaseFirestore.instance.collection('users').doc(
        FirebaseAuth.instance.currentUser!.email!,
      );

  // This method navigates to another page in the application
  // Errors are handled within the methods called
  void navigateTo(int index) async {
    if (pageIndex == 2) {
      // If the app is navigating out from the quiz page, quiz progress is saved
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

  // This is the list of quizzes for this user and the current app user
  List<Quiz> quizzes = [];
  //TODO: implement
  List<String> masteredQuizzes = ['String 1', 'String 2', 'String 3'];
  AppUser appUser = AppUser.empty();

  // This method updates the user's quiz data in the database
  // When an error is thrown, a snack bar is shown
  Future updateUserStates() async {
    for (Quiz quiz in quizzes) {
      final Map<String, Map<String, dynamic>> qStates = {};
      for (int i = 0; i < quiz.questions.length; i++) {
        qStates['q$i'] = {};
        qStates['q$i']!['timesCorrect'] = quiz.questions[i].timesCorrect;
        qStates['q$i']!['timesAnswered'] = quiz.questions[i].timesAnswered;

        if (quiz.questions[i].lastShown != null) {
          qStates['q$i']!['lastShown'] =
              Timestamp.fromDate(quiz.questions[i].lastShown!);
        }
        if (quiz.questions[i].lastAnswered != null) {
          qStates['q$i']!['lastAnswered'] =
              Timestamp.fromDate(quiz.questions[i].lastAnswered!);
        }
      }

      try {
        await userRef.update({
          'quizStates.${quiz.name}.correctQs': quiz.correctQs,
          'quizStates.${quiz.name}.currentQ': quiz.currentQ,
          'quizStates.${quiz.name}.points': quiz.points,
          'quizStates.${quiz.name}.showSummary': quiz.showSummary,
          'quizStates.${quiz.name}.qStates': qStates
        });
      } catch (error) {
        showTextSnackBar('Error saving data: $error');
      }
    }
  }

  // This method updates the user's name locally. It is called when a new user account is created
  void updateUserName(String name) {
    appUser.name = name;
  }

  // This method updates the user's name locally and in the database
  Future updateUser(String name) async {
    updateUserName(name);
    try {
      await (userRef.update({'name': name}));
    } on Exception catch (error) {
      Future.error('$error');
    }
  }

  // This method creates a user document in the database with quiz name
  // Errors from this method are handled in the parent widget
  Future createUserInDB() async {
    print('Creating user in database...');
    try {
      await userRef.set({'name': appUser.name, 'quizStates': {}});
      return Future.value();
    } on Exception catch (error) {
      return Future.error('(From createUserInDB()) $error');
    }
  }

  // This method retrieves user data from the Firebase Firestore database
  // Errors from this method are handled in the parent widget
  Future readUser() async {
    print('Retrieving user data from database...');
    try {
      DocumentSnapshot<Map<String, dynamic>> value = await userRef.get();
      Map<String, dynamic> userMap = value.data()!;
      appUser = AppUser.fromMap(userMap);

      // Here, for each quiz, data is retrieved
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

  // This method retrieves quiz data from the Firebase Firestore database
  // Errors from this method are handled in the parent widget
  Future readQuiz() async {
    try {
      final quizRef = FirebaseFirestore.instance.collection('quizzes');
      // This snapshot is of the entire quiz collection
      QuerySnapshot<Map<String, dynamic>> value = await quizRef.get();
      quizzes = [];

      // Here, each quiz is retrieved and added if the show flag is true
      for (DocumentSnapshot<Map<String, dynamic>> doc in value.docs) {
        Map<String, dynamic> quizMap = doc.data()!;
        Quiz quiz = Quiz.fromMap(quizMap);
        if (quiz.show && DateTime.now().isAfter(quiz.start)) {
          for (Question question in quiz.questions) {
            question.lastShown = DateTime.now();
          }
          quizzes.add(quiz);
        }
      }

      await Future.delayed(const Duration(seconds: 2), () {});
      return Future.value(quizzes);
    } catch (error) {
      return Future.error('(From readQuiz()) $error');
    }
  }

  // These variables are for the quiz page's UI
  int currentQuiz = -1;
  int selectedIndex = -1;
  bool ansSubmitted = false;

  // This method updates the currently selected answer
  void onAnsSelected(int index) {
    selectedIndex = index;
    notifyListeners();
  }

  // This method updates the quiz page when an answer is selected
  // It gives the user points if the answer is corrent
  void onAnsSubmitted() {
    Quiz quiz = quizzes[currentQuiz];
    Question question = quiz.questions[quiz.currentQ];

    if (selectedIndex == question.correctIndex) {
      quiz.points += (question.timesCorrect == 0) ? 5 : 10;
      quiz.correctQs++;
      question.timesCorrect++;
    }
    question.lastAnswered = DateTime.now();
    question.timesAnswered++;

    ansSubmitted = true;
    notifyListeners();
  }

  // This method resets the question page when entering the quiz or going to the next question
  void reset() {
    Quiz quiz = quizzes[currentQuiz];
    // The user is either taken to the summary page or the next question
    if (quiz.currentQ == quiz.questions.length - 1 && ansSubmitted) {
      quiz.showSummary = true;
    } else {
      if (ansSubmitted) {
        quiz.currentQ++;
      }
    }
    // Quiz UI is reset
    selectedIndex = -1;
    ansSubmitted = false;
    notifyListeners();
  }

  // This method sets the current quiz on the quiz page
  void setCurrentQuiz(int index) {
    currentQuiz = index;
    notifyListeners();
  }
}
