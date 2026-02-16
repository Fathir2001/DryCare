class QuestionModel {
  final int id;
  final String question;
  final String icon;
  final List<AnswerOption> options;

  const QuestionModel({
    required this.id,
    required this.question,
    required this.icon,
    required this.options,
  });
}

class AnswerOption {
  final String text;
  final int score;

  const AnswerOption({
    required this.text,
    required this.score,
  });
}
