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
        title: const Text('Entrar no Exame'),
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
                    'Participar de um Exame',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Digite o código do exame fornecido pelo seu instrutor',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  TextFormField(
                    controller: _joinCodeController,
                    decoration: const InputDecoration(
                      labelText: 'Código do Exame',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.vpn_key),
                      hintText: 'Insira o código de 6 caracteres',
                    ),
                    textCapitalization: TextCapitalization.characters,
                    maxLength: 6,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira o código do exame';
                      }
                      if (value.length != 6) {
                        return 'O código do exame deve conter 6 caracteres';
                      }
                      return null;
                    },
                    onChanged: (value) {
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
                      label: const Text('Entrar no Exame'),
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
                                'Como participar de um exame:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[700],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '1. Obtenha o código de exame de 6 caracteres\n'
                            '2. Digite o código acima\n'
                            '3. Clique em "Entrar no Exame" para começar\n'
                            '4. Certifique-se de ter uma conexão de internet estável',
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
          content: Text('Por favor, realize o login primeiro'),
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