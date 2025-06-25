import 'package:flutter/foundation.dart';
import 'dart:async';
import '../models/exam.dart';
import '../models/exam_session.dart';
import '../models/exam_event.dart';
import '../models/question.dart';
import '../models/answer.dart';
import '../models/request_models.dart';
import '../services/api_service.dart';
import '../services/exam_stream_service.dart';
import '../services/storage_service.dart';

class ExamProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final ExamStreamService _streamService = ExamStreamService();
  final StorageService _storageService = StorageService();

  // Current exam state
  Exam? _currentExam;
  ExamSession? _currentSession;
  List<Exam> _hostExams = [];

  // Stream state
  StreamSubscription<ExamEvent>? _examEventSubscription;
  bool _isConnected = false;
  List<ExamEvent> _recentEvents = [];

  // Exam taking state
  int _currentQuestionIndex = 0;
  Map<int, Answer> _selectedAnswers = {};
  Map<int, String> _textAnswers = {};
  Timer? _examTimer;
  int _remainingTimeSeconds = 0;

  // Loading and error states
  bool _isLoading = false;
  String? _error;

  // Getters
  Exam? get currentExam => _currentExam;
  ExamSession? get currentSession => _currentSession;
  List<Exam> get hostExams => _hostExams;
  bool get isConnected => _isConnected;
  List<ExamEvent> get recentEvents => _recentEvents;
  int get currentQuestionIndex => _currentQuestionIndex;
  Question? get currentQuestion => _currentExam?.questions?.isNotEmpty == true
      ? _currentExam!.questions![_currentQuestionIndex]
      : null;
  Answer? get selectedAnswer => _selectedAnswers[currentQuestion?.id];
  String? get textAnswer => _textAnswers[currentQuestion?.id];
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get remainingTimeSeconds => _remainingTimeSeconds;
  double get progress => _currentExam?.questions?.isNotEmpty == true
      ? (_currentQuestionIndex + 1) / _currentExam!.questions!.length
      : 0.0;

  @override
  void dispose() {
    _examEventSubscription?.cancel();
    _examTimer?.cancel();
    super.dispose();
  }

  // Create exam
  Future<bool> createExam(ExamCreateRequest request) async {
    _setLoading(true);
    _clearError();

    try {
      final exam = await _apiService.createExam(request);
      _hostExams.add(exam);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Load host exams
  Future<void> loadHostExams(int hostUserId) async {
    _setLoading(true);
    _clearError();

    try {
      _hostExams = await _apiService.getExamsByHost(hostUserId);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Activate exam
  Future<bool> activateExam(int examId) async {
    _setLoading(true);
    _clearError();

    try {
      final activatedExam = await _apiService.activateExam(examId);

      // Update in host exams list
      final index = _hostExams.indexWhere((exam) => exam.id == examId);
      if (index != -1) {
        _hostExams[index] = activatedExam;
      }

      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Join exam
  Future<bool> joinExam(String joinCode, int userId) async {
    _setLoading(true);
    _clearError();

    try {
      final request = ExamJoinRequest(joinCode: joinCode, userId: userId);
      final session = await _apiService.joinExam(request);

      _currentSession = session;
      await _storageService.saveCurrentSession(session);

      // Load exam details
      final exam = await _apiService.getExam(session.examId, userId);
      _currentExam = exam;

      // Connect to exam stream
      await _connectToExamStream(session.examId, userId);

      // Initialize exam timer if time limit exists
      if (exam.timeLimit != null) {
        _initializeTimer(exam.timeLimit! * 60); // Convert minutes to seconds
      }

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Connect to exam stream
  Future<void> _connectToExamStream(int examId, int userId) async {
    try {
      final stream = _streamService.connectToExam(examId, userId);

      _examEventSubscription = stream.listen(
            (event) {
          _handleExamEvent(event);
        },
        onError: (error) {
          _isConnected = false;
          _setError('Stream connection error: $error');
        },
      );

      _isConnected = true;
      notifyListeners();
    } catch (e) {
      _setError('Failed to connect to exam stream: $e');
    }
  }

  // Handle exam events
  void _handleExamEvent(ExamEvent event) {
    _recentEvents.insert(0, event);
    if (_recentEvents.length > 50) {
      _recentEvents.removeLast();
    }

    switch (event.type) {
      case ExamEventType.userJoined:
        _isConnected = true;
        break;
      case ExamEventType.timeWarning:
        if (event.data is Map && event.data['remainingSeconds'] != null) {
          _remainingTimeSeconds = event.data['remainingSeconds'];
        }
        break;
      case ExamEventType.examEnded:
        _handleExamEnd();
        break;
      default:
        break;
    }

    notifyListeners();
  }

  // Initialize exam timer
  void _initializeTimer(int totalSeconds) {
    _remainingTimeSeconds = totalSeconds;

    _examTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTimeSeconds > 0) {
        _remainingTimeSeconds--;

        // Send time warnings
        if (_remainingTimeSeconds == 300) { // 5 minutes warning
          _addEvent(ExamEvent(
            type: ExamEventType.timeWarning,
            examId: _currentSession?.examId,
            userId: _currentSession?.userId,
            timestamp: DateTime.now(),
            data: {'message': '5 minutes remaining!'},
          ));
        } else if (_remainingTimeSeconds == 60) { // 1 minute warning
          _addEvent(ExamEvent(
            type: ExamEventType.timeWarning,
            examId: _currentSession?.examId,
            userId: _currentSession?.userId,
            timestamp: DateTime.now(),
            data: {'message': '1 minute remaining!'},
          ));
        }

        notifyListeners();
      } else {
        _handleTimeUp();
      }
    });
  }

  // Handle time up
  void _handleTimeUp() {
    _examTimer?.cancel();
    completeExam();
  }

  // Handle exam end
  void _handleExamEnd() {
    _examTimer?.cancel();
    // Handle forced exam completion
  }

  // Navigation methods
  void goToQuestion(int index) {
    if (_currentExam?.questions != null &&
        index >= 0 &&
        index < _currentExam!.questions!.length) {
      _currentQuestionIndex = index;
      notifyListeners();
    }
  }

  void nextQuestion() {
    if (_currentExam?.questions != null &&
        _currentQuestionIndex < _currentExam!.questions!.length - 1) {
      _currentQuestionIndex++;
      notifyListeners();
    }
  }

  void previousQuestion() {
    if (_currentQuestionIndex > 0) {
      _currentQuestionIndex--;
      notifyListeners();
    }
  }

  // Answer methods
  void selectAnswer(Answer answer) {
    if (currentQuestion != null) {
      _selectedAnswers[currentQuestion!.id] = answer;
      _submitCurrentAnswer();
      notifyListeners();
    }
  }

  void setTextAnswer(String text) {
    if (currentQuestion != null) {
      _textAnswers[currentQuestion!.id] = text;
      notifyListeners();
    }
  }

  void submitTextAnswer() {
    if (currentQuestion != null && _textAnswers.containsKey(currentQuestion!.id)) {
      _submitCurrentAnswer();
    }
  }

  // Submit answer to server
  Future<void> _submitCurrentAnswer() async {
    if (_currentSession == null || currentQuestion == null) return;

    try {
      final request = AnswerSubmissionRequest(
        sessionId: _currentSession!.id,
        questionId: currentQuestion!.id,
        answerId: _selectedAnswers[currentQuestion!.id]?.id,
        responseText: _textAnswers[currentQuestion!.id],
      );

      await _apiService.submitAnswer(request);
    } catch (e) {
      print('Error submitting answer: $e');
      // Don't show error to user for individual answer submissions
    }
  }

  // Complete exam
  Future<bool> completeExam() async {
    if (_currentSession == null) return false;

    _setLoading(true);

    try {
      final completedSession = await _apiService.completeExam(_currentSession!.id);
      _currentSession = completedSession;
      await _storageService.saveCurrentSession(completedSession);

      _examTimer?.cancel();

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Disconnect from exam
  void disconnectFromExam() {
    if (_currentSession != null) {
      _streamService.disconnectFromExam(_currentSession!.examId);
    }

    _examEventSubscription?.cancel();
    _examTimer?.cancel();

    _currentExam = null;
    _currentSession = null;
    _isConnected = false;
    _currentQuestionIndex = 0;
    _selectedAnswers.clear();
    _textAnswers.clear();
    _recentEvents.clear();
    _remainingTimeSeconds = 0;

    _storageService.removeCurrentSession();

    notifyListeners();
  }

  // Utility methods
  void _addEvent(ExamEvent event) {
    _recentEvents.insert(0, event);
    if (_recentEvents.length > 50) {
      _recentEvents.removeLast();
    }
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  // Get answered questions count
  int get answeredQuestionsCount {
    return _selectedAnswers.length + _textAnswers.length;
  }

  // Check if current question is answered
  bool get isCurrentQuestionAnswered {
    if (currentQuestion == null) return false;
    return _selectedAnswers.containsKey(currentQuestion!.id) ||
        _textAnswers.containsKey(currentQuestion!.id);
  }

  // Get time remaining formatted
  String get formattedTimeRemaining {
    final hours = _remainingTimeSeconds ~/ 3600;
    final minutes = (_remainingTimeSeconds % 3600) ~/ 60;
    final seconds = _remainingTimeSeconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }
}