import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/common/loading_widget.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _fullNameController = TextEditingController();

  bool _isCreatingAccount = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isCreatingAccount ? 'Criar Conta' : 'Login'),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.school,
                    size: 100,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Strexam',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Username field
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Nome de Usuário',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira o nome de usuário';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Show additional fields for account creation
                  if (_isCreatingAccount) ...[
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira o e-mail';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                          return 'Por favor, insira um e-mail válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _fullNameController,
                      decoration: const InputDecoration(
                        labelText: 'Nome Completo',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.badge),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira seu nome completo';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Error message
                  if (authProvider.error != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        border: Border.all(color: Colors.red),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        authProvider.error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),

                  // Login/Create button
                  if (authProvider.isLoading)
                    const LoadingWidget()
                  else
                    ElevatedButton(
                      onPressed: _handleSubmit,
                      child: Text(_isCreatingAccount ? 'Criar Conta' : 'Login'),
                    ),

                  const SizedBox(height: 16),

                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isCreatingAccount = !_isCreatingAccount;
                        _emailController.clear();
                        _fullNameController.clear();
                      });
                    },
                    child: Text(_isCreatingAccount
                        ? 'Já possui uma conta? Login'
                        : 'Não possui uma conta? Crie uma'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    bool success;

    if (_isCreatingAccount) {
      success = await authProvider.createUser(
        _usernameController.text.trim(),
        _emailController.text.trim(),
        _fullNameController.text.trim(),
      );
    } else {
      success = await authProvider.loginWithUsername(_usernameController.text.trim());
    }

    if (success) {
      // Navigation is handled by the Consumer in main.dart
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isCreatingAccount
              ? 'Conta criada com sucesso!'
              : 'Login realizado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}