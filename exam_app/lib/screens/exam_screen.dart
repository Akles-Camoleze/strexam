import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/exam_provider.dart';
import '../widgets/common/connection_status_widget.dart';
import '../widgets/exam/progress_widget.dart';
import '../widgets/exam/question_widget.dart';
import '../widgets/exam/timer_widget.dart';
import 'exam_results_screen.dart';

class ExamScreen extends StatefulWidget {
  @override
  _ExamScreenState createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final examProvider = Provider.of<ExamProvider>(context, listen: false);
      if (examProvider.currentSession == null || examProvider.currentExam == null) {
        _showNoSessionDialog();
      }
    });
  }

  void _showNoSessionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('No Active Exam'),
        content: const Text('No active exam session found. Please join an exam first.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text('Go to Home'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Consumer<ExamProvider>(
            builder: (context, examProvider, _) {
              return Text(examProvider.currentExam?.title ?? 'Exam');
            },
          ),
          automaticallyImplyLeading: false,
          actions: [
            Consumer<ExamProvider>(
              builder: (context, examProvider, _) {
                return ConnectionStatusWidget(
                  isConnected: examProvider.isConnected,
                );
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Consumer<ExamProvider>(
          builder: (context, examProvider, _) {
            if (examProvider.currentExam == null || examProvider.currentSession == null) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 80, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('No active exam session'),
                  ],
                ),
              );
            }

            final exam = examProvider.currentExam!;
            final questions = exam.questions ?? [];

            if (questions.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.quiz_outlined, size: 80, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('No questions available in this exam'),
                  ],
                ),
              );
            }

            return Column(
              children: [
                // Timer and Progress Bar
                Container(
                  color: Colors.grey[100],
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      if (exam.timeLimit != null)
                        TimerWidget(
                          remainingSeconds: examProvider.remainingTimeSeconds,
                          totalSeconds: exam.timeLimit! * 60,
                        ),
                      const SizedBox(height: 8),
                      ProgressWidget(
                        current: examProvider.currentQuestionIndex + 1,
                        total: questions.length,
                        progress: examProvider.progress,
                      ),
                    ],
                  ),
                ),

                // Question Content
                Expanded(
                  child: examProvider.currentQuestion == null
                      ? const Center(child: Text('Question not found'))
                      : Padding(
                    padding: const EdgeInsets.all(16),
                    child: QuestionWidget(
                      question: examProvider.currentQuestion!,
                      selectedAnswer: examProvider.selectedAnswer,
                      textAnswer: examProvider.textAnswer,
                      onAnswerSelected: examProvider.selectAnswer,
                      onTextChanged: examProvider.setTextAnswer,
                      onTextSubmitted: examProvider.submitTextAnswer,
                    ),
                  ),
                ),

                // Navigation Buttons
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Row(
                      children: [
                        // Previous Button
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: examProvider.currentQuestionIndex > 0
                                ? examProvider.previousQuestion
                                : null,
                            icon: const Icon(Icons.arrow_back),
                            label: const Text('Previous'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[600],
                              disabledBackgroundColor: Colors.grey[300],
                            ),
                          ),
                        ),

                        const SizedBox(width: 16),

                        // Question Counter
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${examProvider.currentQuestionIndex + 1} / ${questions.length}',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${examProvider.answeredQuestionsCount} answered',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(width: 16),

                        // Next/Complete Button
                        Expanded(
                          child: _isLastQuestion(examProvider)
                              ? ElevatedButton.icon(
                            onPressed: examProvider.isLoading ? null : _completeExam,
                            icon: examProvider.isLoading
                                ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                                : const Icon(Icons.check),
                            label: const Text('Complete'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                          )
                              : ElevatedButton.icon(
                            onPressed: _canGoNext(examProvider)
                                ? examProvider.nextQuestion
                                : null,
                            icon: const Icon(Icons.arrow_forward),
                            label: const Text('Next'),
                            style: ElevatedButton.styleFrom(
                              disabledBackgroundColor: Colors.grey[300],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        // Floating Action Button for emergency exit
        floatingActionButton: FloatingActionButton(
          onPressed: _showExitDialog,
          backgroundColor: Colors.red,
          child: const Icon(Icons.exit_to_app),
          tooltip: 'Exit Exam',
        ),
      ),
    );
  }

  bool _isLastQuestion(ExamProvider examProvider) {
    final totalQuestions = examProvider.currentExam?.questions?.length ?? 0;
    return examProvider.currentQuestionIndex >= totalQuestions - 1;
  }

  bool _canGoNext(ExamProvider examProvider) {
    final totalQuestions = examProvider.currentExam?.questions?.length ?? 0;
    return examProvider.currentQuestionIndex < totalQuestions - 1;
  }

  Future<bool> _onWillPop() async {
    return await _showExitDialog() ?? false;
  }

  Future<bool?> _showExitDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Exam?'),
        content: const Text(
          'Are you sure you want to exit the exam? Your current progress will be saved, but you may not be able to continue depending on the exam settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, true);
              _exitExam();
            },
            child: const Text('Exit'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );
  }

  void _exitExam() {
    final examProvider = Provider.of<ExamProvider>(context, listen: false);
    examProvider.disconnectFromExam();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _completeExam() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete Exam?'),
        content: const Text(
          'Are you sure you want to complete the exam? You cannot make changes after submission.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Complete'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final examProvider = Provider.of<ExamProvider>(context, listen: false);
      final success = await examProvider.completeExam();

      if (success && mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Exam completed successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to results
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ExamResultsScreen(),
          ),
        );
      } else if (mounted) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(examProvider.error ?? 'Failed to complete exam'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}