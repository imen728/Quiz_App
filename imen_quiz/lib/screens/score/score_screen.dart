import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imen_quiz/constants.dart';
import 'package:imen_quiz/controllers/question_controller.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import '../../models/the_question.dart';

final databaseUrl = 'https://quizimen-6004e-default-rtdb.firebaseio.com/';

Future<void> updateScore(String name, int score) async {
  final queryParams = {
    'orderBy': '"name"',
    'equalTo': '"$name"',
  };

  final response =
      await http.get(Uri.parse('$databaseUrl/users.json?$queryParams'));

  if (response.statusCode == 200) {
    final decodedResponse = json.decode(response.body) as Map<String, dynamic>;
    decodedResponse.forEach((key, value) async {
      if (value['name'] == name) {
        final updateResponse = await http.patch(
            Uri.parse('$databaseUrl/users/$key.json'),
            body: json.encode({'score': score}));
        if (updateResponse.statusCode != 200) {
          throw Exception('Failed to update score');
        }
      }
    });
  } else {
    throw Exception('Failed to retrieve user data');
  }
}

class ScoreScreen extends StatelessWidget {
  final String name;
  const ScoreScreen(this.name, {super.key});
  @override
  Widget build(BuildContext context) {
    QuestionController qnController = Get.put(QuestionController());
    return FutureBuilder(
        future: qnController.questions as Future<List<Question>>,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Center(
                child: Text('${snapshot.error}'),
              );
            } else if (snapshot.hasData) {
              var extractedData = snapshot.data as List<Question>;
              updateScore(name, qnController.numOfCorrectAns * 10);
              return Scaffold(
                body: Stack(
                  fit: StackFit.expand,
                  children: [
                    SvgPicture.asset("assets/icons/liquid-cheese.svg",
                        fit: BoxFit.fill),
                    Column(
                      children: [
                        const Spacer(flex: 3),
                        Text(
                          "Score",
                          style: Theme.of(context)
                              .textTheme
                              .displaySmall
                              ?.copyWith(color: kSecondaryColor),
                        ),
                        const Spacer(),
                        Text(
                          "${qnController.numOfCorrectAns * 10}/${extractedData.length * 10}",
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(color: kSecondaryColor),
                        ),
                        const Spacer(flex: 3),
                      ],
                    )
                  ],
                ),
              );
            }
          } else {
            return const Center(child: CircularProgressIndicator());
          }
          return const Center(
            child: Text('Error'),
          );
        });
  }
}
