import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';
import '../config/app_config.dart';
import '../models/exam_event.dart';

class ExamStreamService {
  static final ExamStreamService _instance = ExamStreamService._internal();
  factory ExamStreamService() => _instance;
  ExamStreamService._internal();

  final Map<int, StreamSubscription> _activeStreams = {};
  final Map<int, BehaviorSubject<ExamEvent>> _eventSubjects = {};
  final Map<int, http.Client> _clients = {};
  final Map<int, Timer> _reconnectTimers = {};

  Stream<ExamEvent> connectToExam(int examId, int userId) {
    // If already connected, return existing stream
    if (_eventSubjects.containsKey(examId)) {
      return _eventSubjects[examId]!.stream;
    }

    // Create new subject for this exam
    _eventSubjects[examId] = BehaviorSubject<ExamEvent>();

    // Start streaming
    _startExamStream(examId, userId);

    return _eventSubjects[examId]!.stream;
  }

  void _startExamStream(int examId, int userId) async {
    final client = http.Client();
    _clients[examId] = client;

    try {
      final uri = Uri.parse('${AppConfig.streamUrl}/exams/$examId?userId=$userId');
      final request = http.Request('GET', uri);
      request.headers['Accept'] = 'text/event-stream';
      request.headers['Cache-Control'] = 'no-cache';

      final response = await client.send(request);

      if (response.statusCode == 200) {
        _addEvent(examId, ExamEvent(
          type: ExamEventType.userJoined,
          examId: examId,
          userId: userId,
          timestamp: DateTime.now(),
          data: {'message': 'Connected to exam stream'},
        ));

        _activeStreams[examId] = response.stream
            .transform(utf8.decoder)
            .transform(const LineSplitter())
            .listen(
              (line) => _parseServerSentEvent(examId, line),
          onError: (error) => _handleStreamError(examId, userId, error),
          onDone: () => _handleStreamDone(examId, userId),
        );
      } else {
        throw Exception('Failed to connect: ${response.statusCode}');
      }
    } catch (e) {
      _handleStreamError(examId, userId, e);
    }
  }

  void _parseServerSentEvent(int examId, String line) {
    if (line.startsWith('data: ')) {
      try {
        final jsonData = line.substring(6);
        if (jsonData.trim().isNotEmpty && jsonData != 'keep-alive') {
          final eventData = json.decode(jsonData);
          final event = ExamEvent.fromJson(eventData);
          _addEvent(examId, event);
        }
      } catch (e) {
        print('Error parsing SSE event: $e');
      }
    }
  }

  void _addEvent(int examId, ExamEvent event) {
    if (_eventSubjects.containsKey(examId) && !_eventSubjects[examId]!.isClosed) {
      _eventSubjects[examId]!.add(event);
    }
  }

  void _handleStreamError(int examId, int userId, dynamic error) {
    print('Stream error for exam $examId: $error');

    _addEvent(examId, ExamEvent(
      type: ExamEventType.timeWarning,
      examId: examId,
      userId: userId,
      timestamp: DateTime.now(),
      data: {'error': 'Connection lost', 'message': 'Attempting to reconnect...'},
    ));

    _scheduleReconnect(examId, userId);
  }

  void _handleStreamDone(int examId, int userId) {
    print('Stream ended for exam $examId');
    _scheduleReconnect(examId, userId);
  }

  void _scheduleReconnect(int examId, int userId) {
    _cleanupStream(examId);

    _reconnectTimers[examId] = Timer(const Duration(seconds: 5), () {
      if (_eventSubjects.containsKey(examId) && !_eventSubjects[examId]!.isClosed) {
        print('Attempting to reconnect to exam $examId');
        _startExamStream(examId, userId);
      }
    });
  }

  void _cleanupStream(int examId) {
    _activeStreams[examId]?.cancel();
    _activeStreams.remove(examId);

    _clients[examId]?.close();
    _clients.remove(examId);
  }

  void disconnectFromExam(int examId) {
    _reconnectTimers[examId]?.cancel();
    _reconnectTimers.remove(examId);

    _cleanupStream(examId);

    _eventSubjects[examId]?.close();
    _eventSubjects.remove(examId);
  }

  void disconnectAll() {
    final examIds = List<int>.from(_eventSubjects.keys);
    for (final examId in examIds) {
      disconnectFromExam(examId);
    }
  }

  bool isConnected(int examId) {
    return _activeStreams.containsKey(examId) &&
        _eventSubjects.containsKey(examId) &&
        !_eventSubjects[examId]!.isClosed;
  }
}