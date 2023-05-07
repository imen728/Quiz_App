import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:imen_quiz/models/db_connect.dart';
import 'package:imen_quiz/models/the_question.dart';
import 'package:imen_quiz/screens/score/score_screen.dart';
import 'package:imen_quiz/screens/welcome/name.dart';

final databaseReference = FirebaseDatabase.instance.ref();

// We use get package for our state management
class QuestionController extends GetxController
    with GetSingleTickerProviderStateMixin {

  late final String name;
  QuestionController() {
    name = Name.geName();
  }

  // Lets animate our progress bar
  late AnimationController _animationController;
  late Animation _animation;
  
  // so that we can access our animation outside
  Animation get animation => _animation;

  late PageController _pageController;
  PageController get pageController => _pageController;

  late Future _questions;
  Future get questions => _questions;

  var db = DBConnect();

  Future<List<Question>> getData() async {
    return db.fetchQuestions();
  }

  bool _isAnswered = false;
  bool get isAnswered => _isAnswered;

  late int _correctAns;
  int get correctAns => _correctAns;

  late int _selectedAns;
  int get selectedAns => _selectedAns;

  // for more about obs please check documentation
  final RxInt _questionNumber = 1.obs;
  RxInt get questionNumber => _questionNumber;

  int _numOfCorrectAns = 0;
  int get numOfCorrectAns => _numOfCorrectAns;

  // called immediately after the widget is allocated memory
  @override
  void onInit() {
    _questions = getData();
    // Our animation duration is 60 s
    // so our plan is to fill the progress bar within 60s
    _animationController =
        AnimationController(duration: const Duration(seconds: 60), vsync: this);
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController)
      ..addListener(() {
        // update like setState
        update();
      });

    // start our animation
    // Once 60s is completed go to the next qn
    _animationController.forward().whenComplete(nextQuestion);
    _pageController = PageController();
    super.onInit();
  }

  // called just before the Controller is deleted from memory
  @override
  void onClose() {
    super.onClose();
    _animationController.dispose();
    _pageController.dispose();
  }

  void checkAns(Question question, int selectedIndex) {
    // because once user press any option then it will run
    _isAnswered = true;
    _correctAns = question.answer;
    _selectedAns = selectedIndex;

    if (_correctAns == _selectedAns) _numOfCorrectAns++;

    // It will stop the counter
    _animationController.stop();
    update();

    // Once user select an ans after 3s it will go to the next qn
    Future.delayed(const Duration(seconds: 2), () {
      nextQuestion();
    });
  }

  Future<void> nextQuestion() async {
    final questions = await _questions;
    // Wait for Firebase value before moving to next question
    DatabaseReference reference =
        FirebaseDatabase.instance.ref().child("quiz/");
    reference.onValue.listen((event) {
      var data = event.snapshot.value;
      if (data != null && data is Map<String, dynamic>) {
        // Check if the value of the "currentQuestion" key has incremented
        if (data['currentQuestion'] == _questionNumber.value + 1) {
          //if there are more questions
          if (_questionNumber.value != questions.length) {

            //the quiz is not completed yet
            _isAnswered = false;

            // Update the current question number
            _questionNumber.value = data['currentQuestion'];

            // Move to the next question
            _pageController.nextPage(
                duration: const Duration(milliseconds: 250),
                curve: Curves.ease);
            // Reset the counter
            _animationController.reset();
            _animationController.forward().whenComplete(nextQuestion);
          } else {
            // Get package provide us simple way to navigate to another page
            Get.to(ScoreScreen(name));
          }
        }
      }
    });
  }

  void updateTheQnNum(int index) {
    _questionNumber.value = index + 1;
  }
}
