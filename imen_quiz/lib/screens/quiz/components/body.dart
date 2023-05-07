import 'package:flutter/material.dart'
    show
        BoxFit,
        BuildContext,
        Center,
        CircularProgressIndicator,
        Column,
        ConnectionState,
        CrossAxisAlignment,
        Divider,
        EdgeInsets,
        Expanded,
        FutureBuilder,
        Key,
        NeverScrollableScrollPhysics,
        Padding,
        PageView,
        SafeArea,
        SizedBox,
        Stack,
        StackFit,
        StatelessWidget,
        Text,
        TextSpan,
        Theme,
        Widget;
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:imen_quiz/constants.dart';
import 'package:imen_quiz/controllers/question_controller.dart';
import '../../../models/the_question.dart';
import 'progress_bar.dart';
import 'question_card.dart';

class Body extends StatelessWidget {
  const Body({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // So that we have acccess our controller
    QuestionController questionController = Get.put(QuestionController());
    return FutureBuilder(
        future: questionController.questions as Future<List<Question>>,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Center(
                child: Text('${snapshot.error}'),
              );
            } else if (snapshot.hasData) {
              var extractedData = snapshot.data as List<Question>;
              return Stack(
                fit: StackFit.expand,
                children: [
                  SvgPicture.asset("assets/icons/liquid-cheese.svg",
                      fit: BoxFit.fill),
                  SafeArea(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: kDefaultPadding),
                          child: ProgressBar(
                            key: null,
                          ),
                        ),
                        const SizedBox(height: kDefaultPadding),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: kDefaultPadding),
                          child: Obx(
                            () => Text.rich(
                              TextSpan(
                                text:
                                    "Question ${questionController.questionNumber.value}",
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(color: kSecondaryColor),
                                children: [
                                  TextSpan(
                                    text: "/${extractedData.length}",
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(color: kSecondaryColor),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const Divider(thickness: 1.5),
                        const SizedBox(height: kDefaultPadding),
                        Expanded(
                            child: PageView.builder(
                          // Block swipe to next qn
                          physics: const NeverScrollableScrollPhysics(),
                          controller: questionController.pageController,
                          onPageChanged: questionController.updateTheQnNum,
                          itemCount: extractedData.length,
                          itemBuilder: (context, index) => QuestionCard(
                            question: extractedData[index],
                            key: null,
                            //index: index,
                          ),
                        ))
                      ],
                    ),
                  )
                ],
              );
            }
          } else {
            return const Center(child: CircularProgressIndicator());
          }
          return const Center(
            child: Text('No Data'),
          );
        });
  }
}
