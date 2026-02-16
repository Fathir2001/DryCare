import '../models/question_model.dart';

class QuestionnaireDataSource {
  static const List<QuestionModel> questions = [
    QuestionModel(
      id: 1,
      question: 'How does your face feel after washing it? 🧼',
      icon: '🧼',
      options: [
        AnswerOption(text: 'Never tight or dry', score: 0),
        AnswerOption(text: 'Sometimes a little tight', score: 1),
        AnswerOption(text: 'Often feels tight & dry', score: 2),
        AnswerOption(text: 'Always uncomfortably tight', score: 3),
      ],
    ),
    QuestionModel(
      id: 2,
      question: 'Do you notice any flaking or peeling on your skin? 🍂',
      icon: '🍂',
      options: [
        AnswerOption(text: 'None at all', score: 0),
        AnswerOption(text: 'Mild, barely noticeable', score: 1),
        AnswerOption(text: 'Moderate flaking', score: 2),
        AnswerOption(text: 'Severe peeling', score: 3),
      ],
    ),
    QuestionModel(
      id: 3,
      question: 'Does your facial skin ever feel itchy or irritated? 😣',
      icon: '😣',
      options: [
        AnswerOption(text: 'No, never', score: 0),
        AnswerOption(text: 'Rarely happens', score: 1),
        AnswerOption(text: 'Frequently itchy', score: 2),
        AnswerOption(text: 'Constantly irritated', score: 3),
      ],
    ),
    QuestionModel(
      id: 4,
      question: 'How much water do you drink daily? 💧',
      icon: '💧',
      options: [
        AnswerOption(text: '2 liters or more', score: 0),
        AnswerOption(text: '1.5 – 2 liters', score: 1),
        AnswerOption(text: '1 – 1.5 liters', score: 2),
        AnswerOption(text: 'Less than 1 liter', score: 3),
      ],
    ),
    QuestionModel(
      id: 5,
      question: 'How often do you use facial moisturizer? 🧴',
      icon: '🧴',
      options: [
        AnswerOption(text: 'Twice daily (AM & PM)', score: 0),
        AnswerOption(text: 'Once daily', score: 1),
        AnswerOption(text: 'Sometimes, when I remember', score: 2),
        AnswerOption(text: 'Never', score: 3),
      ],
    ),
    QuestionModel(
      id: 6,
      question: 'What temperature water do you use in the shower? 🚿',
      icon: '🚿',
      options: [
        AnswerOption(text: 'Cool / lukewarm', score: 0),
        AnswerOption(text: 'Warm', score: 1),
        AnswerOption(text: 'Hot', score: 2),
        AnswerOption(text: 'Very hot / steamy', score: 3),
      ],
    ),
    QuestionModel(
      id: 7,
      question: 'What\'s the weather like where you live? 🌤',
      icon: '🌤',
      options: [
        AnswerOption(text: 'Humid & tropical', score: 0),
        AnswerOption(text: 'Normal / temperate', score: 1),
        AnswerOption(text: 'Dry climate', score: 2),
        AnswerOption(text: 'Very dry or cold', score: 3),
      ],
    ),
    QuestionModel(
      id: 8,
      question: 'Do you wear sunscreen on your face? ☀️',
      icon: '☀️',
      options: [
        AnswerOption(text: 'Every single day', score: 0),
        AnswerOption(text: 'Sometimes', score: 1),
        AnswerOption(text: 'Rarely', score: 2),
        AnswerOption(text: 'Never', score: 3),
      ],
    ),
    QuestionModel(
      id: 9,
      question: 'How\'s your sleep quality been lately? 😴',
      icon: '😴',
      options: [
        AnswerOption(text: 'Great, well-rested', score: 0),
        AnswerOption(text: 'Okay, could be better', score: 1),
        AnswerOption(text: 'Poor, restless nights', score: 2),
        AnswerOption(text: 'Very poor, insomnia', score: 3),
      ],
    ),
    QuestionModel(
      id: 10,
      question: 'How\'s your diet when it comes to hydrating foods? 🥒',
      icon: '🥒',
      options: [
        AnswerOption(text: 'Very healthy, lots of fruits & veggies', score: 0),
        AnswerOption(text: 'Average, some healthy foods', score: 1),
        AnswerOption(text: 'Low, mostly processed food', score: 2),
        AnswerOption(text: 'Very low, barely any hydrating foods', score: 3),
      ],
    ),
  ];
}
