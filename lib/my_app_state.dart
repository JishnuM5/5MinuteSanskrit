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
  int startMS = 0;
  // This is a reference to the current user's doc in the database
  final userRef = FirebaseFirestore.instance.collection('users').doc(
        FirebaseAuth.instance.currentUser!.email!,
      );

  // This method navigates to another page in the application
  // Errors are handled within the methods called
  Future<void> navigateTo(int index) async {
    if (pageIndex == 2) {
      showDialog(
        context: navigatorKey.currentContext!,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );
      if (checkQuizMastery()) {
        quizzes[currentQuiz].mastered = true;
      }
      quizzes[currentQuiz].currentSesh.elapsedMS +=
          DateTime.now().millisecondsSinceEpoch - startMS;
      await updateUserStates();

      // Schedule update quiz method to be called after navigation
      WidgetsBinding.instance.addPostFrameCallback((_) {
        updateMasteredQuizzes();
      });
    }

    if (index == 2) {
      startMS = DateTime.now().millisecondsSinceEpoch;
    }

    pageIndex = index;
    navigatorKey.currentState!.popUntil((route) => route.isFirst);
    notifyListeners();
  }

  // This is the list of quizzes for this user and the current app user
  List<Quiz> quizzes = [];
  List<String> masteredQuizzes = [];
  int masteredQuizPoints = 0;
  AppUser appUser = AppUser.empty();

  void updateMasteredQuizzes() {
    for (int i = quizzes.length - 1; i >= 0; i--) {
      if (quizzes[i].mastered) {
        masteredQuizzes.add(quizzes[i].name);
        masteredQuizPoints += (quizzes[i].points);
        quizzes.removeAt(i);
      }
    }
  }

  bool checkQuizMastery() {
    for (Question question in quizzes[currentQuiz].questions) {
      if (question.timesCorrect < 2) {
        return false;
      }
    }
    return true;
  }

  // This method updates the user's quiz data in the database
  // When an error is thrown, a snack bar is shown
  Future updateUserStates() async {
    for (Quiz quiz in quizzes) {
      // Turning question data into a map
      final Map<String, Map<String, dynamic>> qStates = {};
      for (int i = 0; i < quiz.questions.length; i++) {
        qStates['q$i'] = {
          'timesCorrect': quiz.questions[i].timesCorrect,
          'timesAnswered': quiz.questions[i].timesAnswered,
        };
      }

      // Turning session data into a map
      Map<String, dynamic> seshState = {
        'elapsedMS': quiz.currentSesh.elapsedMS,
        'totalQs': quiz.currentSesh.totalQs,
        'currentQ': quiz.currentSesh.currentQ,
        'correctQs': quiz.currentSesh.correctQs,
        'points': quiz.currentSesh.points,
      };

      if (quiz.currentSesh.lastAnswered != null) {
        seshState['lastAnswered'] =
            Timestamp.fromDate(quiz.currentSesh.lastAnswered!);
      }

      // Putting all quiz data into a single map
      Map<String, dynamic> quizState = {
        'correctQs': quiz.correctQs,
        'currentQ': quiz.currentQ,
        'points': quiz.points,
        'mastered': quiz.mastered,
        'showSummary': quiz.showSummary,
        'ansSubmitted': quiz.ansSubmitted,
        'qStates': qStates,
        'currentSesh': seshState,
      };
      appUser.quizStates[quiz.name] = quizState;
      try {
        await userRef.update({'quizStates.${quiz.name}': quizState});
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
      updateMasteredQuizzes();

      return Future.value(appUser);
    } catch (error) {
      return Future.error('(From readUser()) $error');
    }
  }

  // This method retrieves quiz data from the Firebase Firestore database
  // Errors from this method are handled in the parent widget
  Future readQuizzes() async {
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
  String currentQuizName = "";
  Map<String, dynamic> get currentQuizState {
    return appUser.quizStates[currentQuizName]!;
  }

  bool lastQAnswered(int index) {
    Quiz quiz = quizzes[index];
    bool onLastQ = quiz.currentSesh.currentQ == quiz.currentSesh.totalQs - 1;
    return onLastQ && quiz.ansSubmitted;
  }

  int selectedIndex = -1;

  // This method updates the currently selected answer
  void onAnsSelected(int index) {
    selectedIndex = index;
    notifyListeners();
  }

  // This method updates the quiz page when an answer is selected
  // It gives the user points if the answer is correct
  void onAnsSubmitted() {
    Quiz quiz = quizzes[currentQuiz];
    Question question = quiz.questions[quiz.currentQ];

    if (selectedIndex == question.correctIndex) {
      int addPoints = (question.timesCorrect == 0) ? 5 : 10;
      quiz.points += addPoints;
      quiz.currentSesh.points += addPoints;
      quiz.correctQs++;
      quiz.currentSesh.correctQs++;
      question.timesCorrect++;
    }
    quiz.currentSesh.lastAnswered = DateTime.now();
    question.timesAnswered++;

    quiz.ansSubmitted = true;
    notifyListeners();
  }

  // This method resets the question page when entering the quiz or going to the next question
  Future<void> reset({bool newSesh = false}) async {
    Quiz quiz = quizzes[currentQuiz];
    // TODO: hardcoded to sessions of 5
    bool isLastSeshQ() {
      return quiz.currentQ == quiz.questions.length - 1 || quiz.currentQ == 4;
    }

    // Quiz UI is reset
    selectedIndex = -1;

    // The user is either taken to the summary page or the next question
    if (quiz.ansSubmitted) {
      if (isLastSeshQ()) {
        quiz.showSummary = true;
      } else {
        if (!newSesh) {
          quiz.currentQ++;
          quiz.currentSesh.currentQ++;
        }
        int skipCount = 0;
        while (quiz.questions[quiz.currentQ].timesCorrect == 2) {
          skipCount++;
          if (isLastSeshQ()) {
            if (skipCount == 5) {
              quiz.currentSesh = Session(totalQs: 5);
              // TODO: hardcoded to session of 5
              if (quiz.currentQ == 4) {
                quiz.currentQ++;
              } else {
                quiz.currentQ = 0;
              }
              continue;
            } else {
              quiz.showSummary = true;
              quiz.currentSesh.totalQs--;
              quiz.currentSesh.currentQ--;
              break;
            }
          }
          quiz.currentSesh.totalQs--;
          quiz.currentQ++;
        }
      }
    }

    if (quiz.showSummary) {
      await navigateTo(3);
    } else {
      quiz.ansSubmitted = false;
    }
    notifyListeners();
  }

  // This method sets the current quiz on the quiz page
  bool setCurrentQuiz(int index) {
    bool newSesh = false;
    currentQuiz = index;
    currentQuizName = quizzes[index].name;
    final quiz = quizzes[currentQuiz];

    if (lastQAnswered(index)) {
      quiz.showSummary = false;

      // TODO: hardcoded to sessions of 5
      quiz.currentQ = (quiz.currentQ == quiz.questions.length - 1) ? 0 : 5;
      quiz.currentSesh = Session(totalQs: 5);
      newSesh = true;
    }
    notifyListeners();
    return newSesh;
  }

  int remainingQs(int index) {
    int remaining = 0;
    Quiz quiz = quizzes[index];
    int tempCurrentQ = quiz.currentQ;

    if (lastQAnswered(index)) {
      tempCurrentQ = (tempCurrentQ == quiz.questions.length - 1) ? 0 : 5;
    }

    final end = (tempCurrentQ < 5) ? 5 : 10;
    for (int i = tempCurrentQ; i < end; i++) {
      if (quiz.questions[i].timesCorrect < 2) {
        remaining++;
      }
    }

    if (remaining == 0) {
      int start = (quiz.currentQ < 5) ? 5 : 0;
      for (int i = start; i < start + 5; i++) {
        if (quiz.questions[i].timesCorrect < 2) {
          remaining++;
        }
      }
    }

    return remaining;
  }

  double pctMastered(int index) {
    double mastered = 0.0;
    for (Question question in quizzes[index].questions) {
      if (question.timesCorrect == 2) {
        mastered++;
      }
    }
    return mastered / quizzes[index].questions.length;
  }
}
