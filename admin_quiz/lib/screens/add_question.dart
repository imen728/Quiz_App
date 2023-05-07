import 'dart:convert';
import 'package:admin_quiz/screens/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../models/the_question.dart';

class AddQuestionScreen extends StatefulWidget {
  const AddQuestionScreen({super.key});

  @override
  _AddQuestionScreenState createState() => _AddQuestionScreenState();
}

class _AddQuestionScreenState extends State<AddQuestionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();
  final _answerController = TextEditingController();
  final _optionsController = TextEditingController();

  final String _firebaseUrl =
      'https://quizimen-6004e-default-rtdb.firebaseio.com/questions.json';

  void _addQuestion() async {
    String questionText = _questionController.text.trim();
    String answerText = _answerController.text.trim();
    List<String> options = _optionsController.text.trim().split(',');

    if (questionText.isNotEmpty &&
        answerText.isNotEmpty &&
        options.isNotEmpty) {
      //check if answerText is integer, if not it returns -1
      int answer = int.tryParse(answerText) ?? -1;
      //check if answer index is valid
      if (answer >= 0 && answer < options.length) {
        Question question = Question(
          id: '',
          question: questionText,
          answer: answer,
          options: options,
        );
        //store this question into the db
        http.Response response = await http.post(Uri.parse(_firebaseUrl),
            body: jsonEncode(question.toJson()));
        if (response.statusCode == 200) {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Success'),
                content: const Text('question added successfully!'),
                actions: [
                  TextButton(
                    onPressed: () => Get.to(const DashboardScreen()),
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );
        } else {
          // Handle error
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Error'),
                content: const Text(
                    'An error occurred while adding the question. Please try again later.'),
                actions: [
                  TextButton(
                    onPressed: () => Get.to(const DashboardScreen()),
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );
        }
      } else {
        // Handle invalid answer (if answer index is not valid)
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Invalid Answer'),
              content: Text(
                  'Please enter a valid answer index between 0 and ${options.length - 1}.'),
              actions: [
                TextButton(
                  onPressed: () => Get.to(const AddQuestionScreen()),
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Add New Question'),
      ),
      body: Stack(children: [
        const Spacer(),
        const Spacer(),
        SvgPicture.asset("assets/icons/liquid-cheese.svg", fit: BoxFit.fill),
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _questionController,
                decoration: const InputDecoration(
                  fillColor: Color.fromARGB(255, 72, 67, 67),
                  labelText: 'Question Text',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter question text';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _answerController,
                decoration: const InputDecoration(
                  fillColor: Color.fromARGB(255, 72, 67, 67),
                  labelText: 'Answer Index (0-based)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter answer index';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _optionsController,
                decoration: const InputDecoration(
                  fillColor: Color.fromARGB(255, 72, 67, 67),
                  labelText: 'Options (comma-separated)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter options';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              InkWell(
                onTap: () {
                  if (_formKey.currentState!.validate()) {
                    _addQuestion();
                  }
                },
                child: Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(kDefaultPadding * 0.75), // 15
                  decoration: const BoxDecoration(
                    gradient: kPrimaryGradient,
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  child: Text(
                    'Add Question',
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge
                        ?.copyWith(color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
        )
      ]),
    );
  }
}
