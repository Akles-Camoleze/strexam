import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:exam_app/mixins/service_mixin.dart';
import 'package:exam_app/transformers/sse_transformer.dart';

mixin SSEServiceMixin on ServiceMixin {
  StreamTransformer<Uint8List, List<int>> unit8Transformer = StreamTransformer.fromHandlers(
    handleData: (data, sink) {
      sink.add(List<int>.from(data));
    },
  );

  Stream<T> connectToSSE<T>({
    required String endpoint,
    required T Function(dynamic json) parser,
    Map<String, dynamic>? queryParams,
    Map<String, String>? headers,
  }) async* {
    String url = endpoint;
    if (queryParams?.isNotEmpty == true) {
      final params = queryParams!.entries
          .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value.toString())}')
          .join('&');
      url += '?$params';
    }

    final defaultHeaders = {
      'Accept': 'text/event-stream',
      'Cache-Control': 'no-cache',
      'Connection': 'keep-alive',
    };

    final response = await dio.get<ResponseBody>(
      url,
      options: Options(
        headers: {...defaultHeaders, ...?headers},
        responseType: ResponseType.stream,
        receiveTimeout: const Duration(minutes: 5)
      ),
    );

    if (response.data == null) {
      throw Exception('Falha ao conectar com o stream SSE');
    }

    yield* response.data!.stream
        .transform(unit8Transformer)
        .transform(const Utf8Decoder())
        .transform(const LineSplitter())
        .transform(const SseTransformer())
        .map((event) {
      try {
        return parser(jsonDecode(event.data));
      } catch (e) {
        throw FormatException('Erro ao parsear dados SSE: $e');
      }
    });
  }

}