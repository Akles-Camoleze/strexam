import 'package:flutter/material.dart';
import '../../models/question.dart';
import '../../models/answer.dart';

class QuestionWidget extends StatelessWidget {
  final Question question;
  final Answer? selectedAnswer;
  final String? textAnswer;
  final Function(Answer) onAnswerSelected;
  final Function(String) onTextChanged;
  final VoidCallback onTextSubmitted;

  const QuestionWidget({
    Key? key,
    required this.question,
    this.selectedAnswer,
    this.textAnswer,
    required this.onAnswerSelected,
    required this.onTextChanged,
    required this.onTextSubmitted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Chip(
                      label: Text(_getQuestionTypeDisplay(question.type)),
                      backgroundColor: Colors.blue[100],
                    ),
                    Chip(
                      label: Text('${question.points} ponto${question.points > 1 ? 's' : ''}'),
                      backgroundColor: Colors.green[100],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  question.questionText,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Answer section
          if (question.type == QuestionType.shortAnswer)
            _buildShortAnswerSection(context)
          else
            _buildMultipleChoiceSection(context),
        ],
      ),
    );
  }

  Widget _buildShortAnswerSection(BuildContext context) {
    final controller = TextEditingController(text: textAnswer ?? '');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sua resposta:',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: controller,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Escreva sua resposta aqui...',
          ),
          maxLines: 5,
          onChanged: onTextChanged,
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onTextSubmitted,
            icon: const Icon(Icons.check),
            label: const Text('Enviar resposta'),
          ),
        ),
      ],
    );
  }

  Widget _buildMultipleChoiceSection(BuildContext context) {
    final answers = question.answers ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selecione sua resposta:',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...answers.map((answer) => _buildAnswerOption(answer)).toList(),
      ],
    );
  }

  Widget _buildAnswerOption(Answer answer) {
    final isSelected = selectedAnswer?.id == answer.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => onAnswerSelected(answer),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? Colors.blue : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
            color: isSelected ? Colors.blue[50] : Colors.white,
          ),
          child: Row(
            children: [
              Icon(
                isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                color: isSelected ? Colors.blue : Colors.grey,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  answer.answerText,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected ? Colors.blue[700] : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getQuestionTypeDisplay(QuestionType type) {
    switch (type) {
      case QuestionType.multipleChoice:
        return 'Múltipla Escolha';
      case QuestionType.trueFalse:
        return 'Verdadeiro/False';
      case QuestionType.shortAnswer:
        return 'Aberta';
    }
  }
}