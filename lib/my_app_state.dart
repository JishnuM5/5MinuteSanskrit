// This file contains the MyAppState ChangeNotifier class for state management

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'main.dart';
import 'themes.dart';
import 'classes.dart';

// This class contains app states, lifted out of the widget tree. It uses the Provider model
class MyAppState extends ChangeNotifier {
  int pageIndex = 0;
  int startMS = 0;

  // This method navigates to another page in the application
  // Errors are handled within the methods called
  Future navigateTo(int index) async {
    // If the user is leaving from the quiz page, update quiz mastery and save to database
    if (pageIndex == 4) {
      showDialog(
        context: navigatorKey.currentContext!,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );
      if (checkQuizMastery()) {
        quizzes[currentQuiz].mastered = true;
      }
      // Subtract start time from current time and update elapsed time
      quizzes[currentQuiz].currentSesh.elapsedMS +=
          DateTime.now().millisecondsSinceEpoch - startMS;
      await updateUserStates();

      // Schedule update method to be called after navigation
      WidgetsBinding.instance.addPostFrameCallback((_) {
        updateMasteredQuizzes();
      });
    }

    // If user is entering the quiz page, mark the new start time
    if (index == 4) {
      startMS = DateTime.now().millisecondsSinceEpoch;
    }

    pageIndex = index;
    navigatorKey.currentState!.popUntil((route) => route.isFirst);
    notifyListeners();
  }

  // This is the list of quizzes, the list of hintPages, and related values
  List<Quiz> quizzes = [];
  List<String> masteredQuizzes = [];
  int masteredQuizPoints = 0;
  Map<String, QuizHintPage> hintPages = {};
  late QuizHintPage currentHintPage;

  // This method updates quiz list based on the mastery of quizzes
  void updateMasteredQuizzes() {
    for (int i = quizzes.length - 1; i >= 0; i--) {
      if (quizzes[i].mastered) {
        masteredQuizzes.add(quizzes[i].name);
        masteredQuizPoints += (quizzes[i].points);
        quizzes.removeAt(i);
      }
    }
  }

  // This method checks whether a quiz has been mastered
  bool checkQuizMastery() {
    for (Question question in quizzes[currentQuiz].questions) {
      if (question.timesCorrect < 2) {
        return false;
      }
    }
    return true;
  }

  // This method retrieves quiz data from the Firebase Firestore database
  // Errors from this method are handled in the parent widget
  Future readQuizzes() async {
    try {
      // This snapshot is of the entire quiz collection
      final quizRef = FirebaseFirestore.instance.collection('quizzes');
      QuerySnapshot<Map<String, dynamic>> value = await quizRef.get();

      // Reset values before retrieving data from new account
      quizzes = [];
      masteredQuizzes = [];
      masteredQuizPoints = 0;
      currentQuiz = -1;
      currentQuizName = "";

      // Here, each quiz is retrieved and added if the show flag is true
      for (DocumentSnapshot<Map<String, dynamic>> doc in value.docs) {
        Map<String, dynamic> quizMap = doc.data()!;
        Quiz quiz = Quiz.fromMap(quizMap);
        if (quiz.show && DateTime.now().isAfter(quiz.start)) {
          quizzes.add(quiz);
        }
      }

      await Future.delayed(const Duration(seconds: 4), () {});
      return Future.value(quizzes);
    } catch (error) {
      return Future.error('(From readQuizzes) $error');
    }
  }

  Future readHintPages() async {
    try {
      final hintRef = FirebaseFirestore.instance.collection('hintPages');
      QuerySnapshot<Map<String, dynamic>> value = await hintRef.get();
      hintPages = {};
      for (DocumentSnapshot<Map<String, dynamic>> doc in value.docs) {
        Map<String, dynamic> hintMap = doc.data()!;
        QuizHintPage hintPage = QuizHintPage.fromMap(hintMap);
        hintPages[hintPage.topic] = hintPage;
      }
    } catch (error) {
      return Future.error('(From readHintPages) $error');
    }
  }

// This is the app user and a list of users for the leaderboard
  AppUser appUser = AppUser.empty();
  List<LeaderboardUser> lbUsers = [];
  late LeaderboardUser lbUser;

  // This method updates the user's quiz data in the database
  // When an error is thrown, a snack bar is shown
  Future updateUserStates() async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(
          FirebaseAuth.instance.currentUser!.email!,
        );
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

      // The last answered variable is retrieved
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

      // The last shown variable is retrieved and added to the map
      if (quiz.lastShown != null) {
        quizState['lastShown'] = Timestamp.fromDate(quiz.lastShown!);
      }

      // Updating quizState locally
      appUser.quizStates[quiz.name] = quizState;

      // Calculating the total number of points
      int totalPoints = 0;
      for (Quiz quiz in quizzes) {
        totalPoints = totalPoints + quiz.points + masteredQuizPoints;
      }

      try {
        await userRef.update(
            {'quizStates.${quiz.name}': quizState, 'lbPoints': totalPoints});
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
    final userRef = FirebaseFirestore.instance.collection('users').doc(
          FirebaseAuth.instance.currentUser!.email!,
        );
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
    final userRef = FirebaseFirestore.instance.collection('users').doc(
          FirebaseAuth.instance.currentUser!.email!,
        );
    try {
      await userRef
          .set({'name': appUser.name, 'quizStates': {}, 'lbPoints': 0});
      return Future.value();
    } on Exception catch (error) {
      return Future.error('(From createUserInDB) $error');
    }
  }

  // This method retrieves user data from the Firebase Firestore database
  // Errors from this method are handled in the parent widget
  Future readUser() async {
    final usersRef = FirebaseFirestore.instance.collection('users');

    try {
      QuerySnapshot<Map<String, dynamic>> usersSnapshot = await usersRef.get();
      lbUsers = [];

      // Each user document is iterated through and processed
      for (var doc in usersSnapshot.docs) {
        Map<String, dynamic> userMap = doc.data();
        lbUsers.add(LeaderboardUser.fromMap(userMap));

        // Check if this is the current user's document, and process if so
        if (doc.id == FirebaseAuth.instance.currentUser!.email!) {
          appUser = AppUser.fromMap(userMap);
          lbUser = LeaderboardUser.fromMap(userMap);

          // Here, the current user's quiz data is retrieved
          for (Quiz quiz in quizzes) {
            Map<String, dynamic>? quizState = appUser.quizStates[quiz.name];
            if (quizState != null) {
              quiz.readFromState(quizState);
            }
          }
          updateMasteredQuizzes();
        }
      }
      return Future.value(appUser);
    } catch (error) {
      return Future.error('(From readUser) $error');
    }
  }

  // These variables are for the quiz page's UI
  int currentQuiz = -1;
  String currentQuizName = "";
  int selectedIndex = -1;

  // This method checks whether the last question of the session was answered
  bool lastQAnswered(int index) {
    Quiz quiz = quizzes[index];
    bool onLastQ = quiz.currentSesh.currentQ == quiz.currentSesh.totalQs - 1;
    return onLastQ && quiz.ansSubmitted;
  }

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
      int addPoints = (quiz.status == QuizStatus.green)
          ? 5
          : (quiz.status == QuizStatus.yellow)
              ? 3
              : 1;
      if (question.timesCorrect == 1) {
        addPoints += 5;
        if (question.timesAnswered == 1) {
          addPoints += 2;
        }
      }
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

    if (quiz.ansSubmitted) {
      // If previous answer was submitted and it's the last question of the session, show summary page
      if (isLastSeshQ()) {
        quiz.showSummary = true;
        // Else if answer submitted, go to next question if not a new session
      } else {
        if (!newSesh) {
          quiz.currentQ++;
          quiz.currentSesh.currentQ++;
        }
        int skipCount = 0;
        // Skip all questions that are already mastered
        while (quiz.questions[quiz.currentQ].timesCorrect == 2) {
          skipCount++;
          if (isLastSeshQ()) {
            // If on the last question, if the entire session was skipped, go to next session
            if (skipCount == 5) {
              quiz.currentSesh = Session(totalQs: 5);
              // TODO: hardcoded to session of 5
              if (quiz.currentQ == 4) {
                quiz.currentQ++;
              } else {
                quiz.currentQ = 0;
              }
              continue;
              // Else, go to the summary page
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

    // Navigate to the summary page if needed, or reset variables
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

    // If the last question in a session was answered, set up a new session
    if (lastQAnswered(index)) {
      quiz.showSummary = false;

      // TODO: hardcoded to sessions of 5
      quiz.currentQ = (quiz.currentQ == quiz.questions.length - 1) ? 0 : 5;
      quiz.currentSesh = Session(totalQs: 5);
      newSesh = true;
    }

    if (quiz.showHint) {
      print(hintPages);
      print(quiz.hintPageRef);
      currentHintPage = hintPages[quiz.hintPageRef!]!;
    }

    notifyListeners();
    return newSesh;
  }

  void setQuizStatus(int index, QuizStatus status) {
    final quiz = quizzes[index];
    quiz.status = status;
  }

  // This method calculates the number of remaining questions in a session
  int remainingQs(int index) {
    int remaining = 0;
    Quiz quiz = quizzes[index];
    int tempCurrentQ = quiz.currentQ;

    // If at the end of the session, start counting for the next one
    if (lastQAnswered(index)) {
      tempCurrentQ = (tempCurrentQ == quiz.questions.length - 1) ? 0 : 5;
    }

    // Add all non-mastered questions to count
    final end = (tempCurrentQ < 5) ? 5 : 10;
    for (int i = tempCurrentQ; i < end; i++) {
      if (quiz.questions[i].timesCorrect < 2) {
        remaining++;
      }
    }

    // If the session had all mastered questions, count the next session
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

  // This method calculates the percentage of questions mastered in a quiz
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
