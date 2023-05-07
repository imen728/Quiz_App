import 'dart:convert';
import 'package:http/http.dart' as http;
import 'the_question.dart';

class DBConnect {
  final url = Uri.parse(
      'https://quizimen-6004e-default-rtdb.firebaseio.com/questions.json');

  Future<void> addQuestion(Question question) async {
    http.post(url,
        body: json.encode({
          'id': question.id,
          'question': question.question,
          'options': question.options,
          'answer': question.answer
        }));
  }

  Future<List<Question>> fetchQuestions() async {
    return http.get(url).then((response) {
      List<Question> newQuestions = [];
      var data = json.decode(response.body) as Map<String, dynamic>;
      data.forEach((key, value) {
        var newQuestion = Question(
            id: key,
            question: value['question'],
            options: List.castFrom(value['options']),
            answer: value['answer']);
        newQuestions.add(newQuestion);
      });
      return newQuestions;
    });
  }
}
