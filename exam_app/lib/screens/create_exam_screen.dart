import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/request_models.dart';
import '../providers/auth_provider.dart';
import '../providers/exam_provider.dart';

class CreateExamScreen extends StatefulWidget {
  @override
  _CreateExamScreenState createState() => _CreateExamScreenState();
}

class _CreateExamScreenState extends State<CreateExamScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _timeLimitController = TextEditingController();

  bool _allowRetake = false;
  List<QuestionData> _questions = [];

  @override
  void initState() {
    super.initState();
    _addQuestion();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _timeLimitController.dispose();
    for (var question in _questions) {
      question.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Exame'),
        actions: [
          Consumer<ExamProvider>(
            builder: (context, examProvider, _) {
              return examProvider.isLoading
                  ? const Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              )
                  : TextButton(
                onPressed: _questions.isNotEmpty ? _createExam : null,
                child: const Text(
                  'CRIAR',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<ExamProvider>(
        builder: (context, examProvider, _) {
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Exam basic info
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Informação do Exame',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            labelText: 'Título do Exame *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.title),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, insira o título do exame';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Descrição (opcional)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.description),
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _timeLimitController,
                          decoration: const InputDecoration(
                            labelText: 'Tempo de Duração (minutos)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.timer),
                            suffixText: 'minutos',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              final timeLimit = int.tryParse(value);
                              if (timeLimit == null || timeLimit <= 0) {
                                return 'Por favor, insira um tempo de duração válido';
                              }
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        SwitchListTile(
                          title: const Text('Permitir Retomada'),
                          subtitle: const Text('Alunos podem refazer o exame'),
                          value: _allowRetake,
                          onChanged: (value) {
                            setState(() {
                              _allowRetake = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Questions section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Questões (${_questions.length})',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _addQuestion,
                      icon: const Icon(Icons.add),
                      label: const Text('Nova Questão'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Questions list
                ..._questions.asMap().entries.map((entry) {
                  final index = entry.key;
                  final question = entry.value;
                  return _buildQuestionCard(index, question);
                }).toList(),

                // Error message
                if (examProvider.error != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(top: 16),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      border: Border.all(color: Colors.red),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      examProvider.error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuestionCard(int index, QuestionData question) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Questão ${index + 1}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () => _removeQuestion(index),
                      icon: const Icon(Icons.delete, color: Colors.red),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: question.questionController,
              decoration: const InputDecoration(
                labelText: 'Texto da Questão *',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, insira o texto da questão';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: question.type,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de Questão',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'MULTIPLE_CHOICE',
                        child: Text('Múltipla Escolha'),
                      ),
                      DropdownMenuItem(
                        value: 'TRUE_FALSE',
                        child: Text('Verdadeiro/Falso'),
                      ),
                      DropdownMenuItem(
                        value: 'SHORT_ANSWER',
                        child: Text('Aberta'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        question.type = value!;
                        question.setupAnswers();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 100,
                  child: TextFormField(
                    controller: question.pointsController,
                    decoration: const InputDecoration(
                      labelText: 'Pontos',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      final points = int.tryParse(value);
                      if (points == null || points <= 0) {
                        return 'Invalid';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),

            // Answers section (only for multiple choice and true/false)
            if (question.type != 'SHORT_ANSWER') ...[
              const SizedBox(height: 16),
              const Text(
                'Opções de Resposta:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...question.answers.asMap().entries.map((entry) {
                final answerIndex = entry.key;
                final answer = entry.value;
                return _buildAnswerField(question, answerIndex, answer);
              }).toList(),
              if (question.type == 'MULTIPLE_CHOICE')
                TextButton.icon(
                  onPressed: () => setState(() => question.addAnswer()),
                  icon: const Icon(Icons.add),
                  label: const Text('Nova Opção'),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerField(QuestionData question, int index, AnswerData answer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Radio<int>(
            value: index,
            groupValue: question.correctAnswerIndex,
            onChanged: (value) {
              setState(() {
                question.correctAnswerIndex = value!;
              });
            },
          ),
          Expanded(
            child: TextFormField(
              controller: answer.controller,
              decoration: InputDecoration(
                labelText: question.type == 'TRUE_FALSE'
                    ? (index == 0 ? 'Verdadeiro' : 'Falso')
                    : 'Opção ${index + 1}',
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Required';
                }
                return null;
              },
            ),
          ),
          if (question.type == 'MULTIPLE_CHOICE' && question.answers.length > 2)
            IconButton(
              onPressed: () {
                setState(() {
                  question.removeAnswer(index);
                });
              },
              icon: const Icon(Icons.remove_circle, color: Colors.red),
            ),
        ],
      ),
    );
  }

  void _addQuestion() {
    setState(() {
      _questions.add(QuestionData());
    });
  }

  void _removeQuestion(int index) {
    setState(() {
      _questions[index].dispose();
      _questions.removeAt(index);
    });
  }

  void _createExam() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate that each question has a correct answer
    for (int i = 0; i < _questions.length; i++) {
      final question = _questions[i];
      if (question.type != 'SHORT_ANSWER' && question.correctAnswerIndex == -1) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Por favor, selecione a resposta correta para a Questão ${i + 1}'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final examProvider = Provider.of<ExamProvider>(context, listen: false);

    final questions = _questions.map((q) => q.toRequest()).toList();

    final request = ExamCreateRequest(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      hostUserId: authProvider.currentUser!.id,
      timeLimit: _timeLimitController.text.isEmpty
          ? null
          : int.parse(_timeLimitController.text),
      allowRetake: _allowRetake,
      questions: questions,
    );

    final success = await examProvider.createExam(request);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Exame criado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }
}

class QuestionData {
  final TextEditingController questionController = TextEditingController();
  final TextEditingController pointsController = TextEditingController(text: '1');
  String type = 'MULTIPLE_CHOICE';
  List<AnswerData> answers = [];
  int correctAnswerIndex = -1;

  QuestionData() {
    setupAnswers();
  }

  void setupAnswers() {
    for (var answer in answers) {
      answer.dispose();
    }
    answers.clear();
    correctAnswerIndex = -1;

    switch (type) {
      case 'MULTIPLE_CHOICE':
        answers = [
          AnswerData(),
          AnswerData(),
        ];
        break;
      case 'TRUE_FALSE':
        answers = [
          AnswerData(text: 'Verdadeiro'),
          AnswerData(text: 'Falso'),
        ];
        break;
      case 'SHORT_ANSWER':
        break;
    }
  }

  void addAnswer() {
    if (type == 'MULTIPLE_CHOICE') {
      answers.add(AnswerData());
    }
  }

  void removeAnswer(int index) {
    if (answers.length > 2 && index < answers.length) {
      answers[index].dispose();
      answers.removeAt(index);

      if (correctAnswerIndex == index) {
        correctAnswerIndex = -1;
      } else if (correctAnswerIndex > index) {
        correctAnswerIndex--;
      }
    }
  }

  QuestionCreateRequest toRequest() {
    List<AnswerCreateRequest>? answerRequests;

    if (type != 'SHORT_ANSWER') {
      answerRequests = answers.asMap().entries.map((entry) {
        final index = entry.key;
        final answer = entry.value;
        return AnswerCreateRequest(
          answerText: answer.controller.text.trim(),
          isCorrect: index == correctAnswerIndex,
        );
      }).toList();
    }

    return QuestionCreateRequest(
      questionText: questionController.text.trim(),
      type: type,
      points: int.parse(pointsController.text),
      answers: answerRequests,
    );
  }

  void dispose() {
    questionController.dispose();
    pointsController.dispose();
    for (var answer in answers) {
      answer.dispose();
    }
  }
}

class AnswerData {
  final TextEditingController controller = TextEditingController();

  AnswerData({String? text}) {
    if (text != null) {
      controller.text = text;
    }
  }

  void dispose() {
    controller.dispose();
  }
}