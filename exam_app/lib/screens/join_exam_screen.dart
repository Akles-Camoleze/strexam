import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/exam_provider.dart';
import '../widgets/common/loading_widget.dart';
import 'exam_screen.dart';

class JoinExamScreen extends StatefulWidget {
  @override
  _JoinExamScreenState createState() => _JoinExamScreenState();
}

class _JoinExamScreenState extends State<JoinExamScreen> {
  final _formKey = GlobalKey<FormState>();
  final _joinCodeController = TextEditingController();

  @override
  void dispose() {
    _joinCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join Exam'),
      ),
      body: Consumer<ExamProvider>(
        builder: (context, examProvider, _) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.login,
                    size: 100,
                    color: Colors.green,
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Join an Exam',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enter the exam code provided by your instructor',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  TextFormField(
                    controller: _joinCodeController,
                    decoration: const InputDecoration(
                      labelText: 'Exam Code',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.vpn_key),
                      hintText: 'Enter 6-character code',
                    ),
                    textCapitalization: TextCapitalization.characters,
                    maxLength: 6,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the exam code';
                      }
                      if (value.length != 6) {
                        return 'Exam code must be 6 characters';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      // Auto-format to uppercase
                      final upperValue = value.toUpperCase();
                      if (upperValue != value) {
                        _joinCodeController.value = _joinCodeController.value.copyWith(
                          text: upperValue,
                          selection: TextSelection.collapsed(offset: upperValue.length),
                        );
                      }
                    },
                  ),

                  const SizedBox(height: 24),

                  // Error message
                  if (examProvider.error != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        border: Border.all(color: Colors.red),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              examProvider.error!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Join button
                  if (examProvider.isLoading)
                    const Center(child: LoadingWidget())
                  else
                    ElevatedButton.icon(
                      onPressed: _joinExam,
                      icon: const Icon(Icons.login),
                      label: const Text('Join Exam'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),

                  const SizedBox(height: 32),

                  // Info card
                  Card(
                    color: Colors.blue[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info, color: Colors.blue[700]),
                              const SizedBox(width: 8),
                              Text(
                                'How to join an exam:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[700],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '1. Get the 6-character exam code from your instructor\n'
                            '2. Enter the code above\n'
                            '3. Click "Join Exam" to start\n'
                            '4. Make sure you have a stable internet connection',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _joinExam() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final examProvider = Provider.of<ExamProvider>(context, listen: false);

    if (authProvider.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final success = await examProvider.joinExam(
      _joinCodeController.text.trim().toUpperCase(),
      authProvider.currentUser!.id,
    );

    if (success && mounted) {
      // Navigate to exam screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ExamScreen()),
      );
    }
  }
}